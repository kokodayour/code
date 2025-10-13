import os
import math
import random
from itertools import permutations

import torch.nn as nn
import torchvision.models as models
from torch.utils.data import DataLoader
import torch.backends.cudnn as cudnn

from utils import *
from model import *
from dataloader import *

import warnings
warnings.filterwarnings(action='ignore')

def save_model(model, optimizer, epoch, save_file):
    print('==> Saving...')
    state = {
        'state_dict': model.state_dict(),
        'optimizer': optimizer.state_dict(),
        'epoch': epoch,
    }
    torch.save(state, save_file)
    del state
    
def make_data_loader(group_list, batch_sz, metadata_path):
    group_dataset = GroupDataset_RGB_DualZL(group_list,
                                     metadata_path = metadata_path,               
                                     dir_name_highZL = dir_name_highZL,
                                     dir_name_lowZL = dir_name_lowZL,
                                     transform = transforms.Compose([
                                       RandomRotate(),
                                       ToTensor(),
                                       Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
                                    ]))
    group_loader = torch.utils.data.DataLoader(group_dataset, batch_size=batch_sz, shuffle=True, num_workers=2, drop_last=True)
    return group_loader

def deactivate_batchnorm(model):
    for m in model.modules():
        if isinstance(m, nn.BatchNorm2d):
            m.reset_parameters()
            m.eval()
            with torch.no_grad():
                m.weight.fill_(1.0)
                m.bias.zero_()

def train(epoch, model, optimizer, loader_list, reg_loader, device):
    model.train()
    deactivate_batchnorm(model)
    
    train_loss_LST = AverageMeter()
    train_loss_CHELSA = AverageMeter()
    
    avg_loss = 0
    count = 0
    
    dataloaders = []
    epoch_id_list = group_id_list
    for group_id in epoch_id_list:
        dataloaders.append(loader_list[group_id])
    dataloaders.append(reg_loader)
        
    for batch_idx, data in enumerate(zip(*dataloaders)):
        group_num = 5
        
        for idx in range(group_num):
            if idx == 0:
                data_highZL_zip = data[idx][0].to(device)
                data_lowZL_zip = data[idx][1].to(device)
                geo_zip = torch.cat([data[idx][2].unsqueeze(1),data[idx][4].unsqueeze(1)],dim=1)
            else:
                data_highZL_zip = torch.cat([data_highZL_zip,data[idx][0].to(device)],dim=0)
                data_lowZL_zip = torch.cat([data_lowZL_zip,data[idx][1].to(device)],dim=0)
                geo_temp = torch.cat([data[idx][2].unsqueeze(1),data[idx][4].unsqueeze(1)],dim=1)
                geo_zip = torch.cat([geo_zip,geo_temp],dim=0)
        rgb_highZL_zip = data_highZL_zip.to(device)
        rgb_lowZL_zip = data_lowZL_zip.to(device)
        geo_zip = geo_zip.float().to(device)

        _, LST_scores = model(rgb_highZL_zip,rgb_lowZL_zip,geo_zip)
        LST_scores = LST_scores.squeeze()
        score_list = torch.split(LST_scores, batch_sz, dim = 0)
            
        rank_matrix = torch.zeros((batch_sz, group_num, group_num)).to(device)
        for itertuple in list(permutations(range(group_num), 2)):
            score1 = score_list[itertuple[0]]
            score2 = score_list[itertuple[1]]
            diff = lamb * (score2 - score1)
            results = torch.sigmoid(diff)
            rank_matrix[:, itertuple[0], itertuple[1]] = results
            rank_matrix[:, itertuple[1], itertuple[0]] = 1 - results

        rank_predicts = rank_matrix.sum(1)
        rank_temp = torch.Tensor(range(group_num))
        target_rank = rank_temp.unsqueeze(0).repeat(batch_sz, 1).to(device)
        loss_train_LST = ((rank_predicts - target_rank)**2).mean()
        
        idx = group_num
        data_highZL = data[idx][0].to(device)
        data_lowZL = data[idx][1].to(device)
        geo_info = torch.cat([data[idx][2].unsqueeze(1),data[idx][4].unsqueeze(1)],dim=1).float().to(device)
        chelsa_gt = data[idx][5].float().to(device)
        
        _, scores = model(data_highZL,data_lowZL,geo_info)
        loss_train_CHELSA = ((scores - chelsa_gt)**2).mean() 
       
        loss_LST = loss_train_LST
        loss_CHELSA = loss_train_CHELSA * (alpha)
        loss = loss_CHELSA + loss_LST

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        train_loss_LST.update(loss_LST.item(), batch_sz)
        train_loss_CHELSA.update(loss_CHELSA.item(), batch_sz)
        avg_loss += loss.item()
        count += 1
        
        if batch_idx % 10 == 0:
            print('Epoch: [{epoch}][{elps_iters}] \n'
                    'Train loss-LST : {train_loss_LST.val:.4f} ({train_loss_LST.avg:.4f}) '
                    'Train loss-CHELSA: {train_loss_CHELSA.val:.4f} ({train_loss_CHELSA.avg:.4f}) '.format(
                        epoch=epoch, elps_iters=batch_idx, train_loss_LST=train_loss_LST, train_loss_CHELSA=train_loss_CHELSA))
    
    scheduler.step()
    
    return avg_loss / count

if __name__ == '__main__':
    
    seed = 0
    batch_sz = 10
    batch_sz_reg = 100
    learning_rate = 5e-4
    EPOCHS = 50
    lamb = 30
    alpha = 100
    
    dir_name_highZL = './data/Seoul_RGBalbum_zl17/'
    dir_name_lowZL = './data/Seoul_RGBalbum_zl16/'
    save_name = './model.ckpt'

    LST_path = './metadata/Seoul_metadata_cls5_LSTloss.csv'
    CHELSA_path = './metadata/Seoul_metadata_CHELSAloss.csv'
    
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.cuda.manual_seed(seed)
    np.random.seed(seed)
    cudnn.benchmark = False
    cudnn.deterministic = True
    random.seed(seed)
    
    group_id_list = list(range(5))

    loader_dict = {}
    for group_id in group_id_list:
        group_loader = make_data_loader([group_id], batch_sz, LST_path)
        loader_dict[group_id] = group_loader
    
    reg_dataset = RegressionDataset_RGB_DualZL(metadata_path = CHELSA_path,               
                                     dir_name_highZL = dir_name_highZL,
                                     dir_name_lowZL = dir_name_lowZL,
                                     transform = transforms.Compose([
                                       RandomRotate(),
                                       ToTensor(),
                                       Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
                                    ]))
    reg_loader = torch.utils.data.DataLoader(reg_dataset, batch_size=batch_sz_reg, shuffle=True, num_workers=2, drop_last=True)
    
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    highnet = models.resnet18(pretrained = True)
    highnet = torch.nn.Sequential(*list(highnet.children())[:-2])
    lownet = models.resnet18(pretrained = True)
    lownet = torch.nn.Sequential(*list(lownet.children())[:-2])
    model = ZoomNet_CrossAtt(highnet, lownet, hidden_dim=512, geo_dim=2, seed=seed)

    if torch.cuda.device_count() > 1:
        model = nn.DataParallel(model, device_ids = [0,1])
    model.to(device)

    optimizer = torch.optim.Adam(model.parameters(), lr = learning_rate)
    scheduler = torch.optim.lr_scheduler.LambdaLR(optimizer=optimizer,
                                            lr_lambda=lambda epoch: 0.99 ** epoch,
                                            last_epoch=-1,
                                            verbose=False)
    print("Model Loaded")
    
    best_loss = float('inf')

    thr = 0
    for epoch in range(EPOCHS):  
        epoch = epoch + 1
        loss = train(epoch, model, optimizer, loader_dict, reg_loader, device)
        print(loss)
        if epoch % 5 == 0 and epoch != 0:                
            if best_loss > loss:
                save_file = os.path.join(
                    './model/seed{}'.format(seed), 'ckpt_epoch_{epoch}.ckpt'.format(epoch=epoch))
                save_model(model, optimizer, epoch, save_file)
                best_loss = loss
                print("best loss: %.4f\n" % (best_loss))

    