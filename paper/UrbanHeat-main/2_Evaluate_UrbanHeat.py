import pandas as pd

import torch
import torch.nn as nn
import torchvision
import torchvision.models as models
import torchvision.transforms as transforms

from sklearn.metrics import mean_absolute_error
from dataloader import *
from model import *

import warnings
warnings.filterwarnings(action='ignore')

if __name__ == '__main__':
    
    eval_csv = pd.read_csv('./data/Seoul_Evaluation_normed.csv',index_col=0)
    
    seed = 0
    epoch = 20
    
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    highnet = models.resnet18(pretrained = True)
    highnet = torch.nn.Sequential(*list(highnet.children())[:-2])
    lownet = models.resnet18(pretrained = True)
    lownet = torch.nn.Sequential(*list(lownet.children())[:-2])
    model = ZoomNet_CrossAtt(highnet, lownet, hidden_dim=512, geo_dim=2)
    model.to(device)

    model_path = './model/seed{}/ckpt_epoch_{}.ckpt'.format(seed,epoch)
    if torch.cuda.device_count() > 1:
        model = nn.DataParallel(model, device_ids = [0,1])
    model.load_state_dict(torch.load(model_path)['state_dict'],strict=True)
    model.eval()
    print("MODEL LOADED")
    
    transform = transforms.Compose([ToTensor(),Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])])
    
    rgbpath_high = './data/Seoul_RGBalbum_evaluation_zl17'
    rgbpath_low = './data/Seoul_RGBalbum_evaluation_zl16'
    eval_csv['pred'] = -100
    for row in eval_csv.itertuples():
        rgbimg_high= io.imread("{}/{}.png".format(rgbpath_high,row.Serial_num))/255.0
        rgbimg_high = np.expand_dims(rgbimg_high,axis=0)
        rgb_input_high = torch.Tensor(transform(rgbimg_high)).to(device)

        rgbimg_low= io.imread("{}/{}.png".format(rgbpath_low,row.Serial_num))/255.0
        rgbimg_low = np.expand_dims(rgbimg_low,axis=0)
        rgb_input_low = torch.Tensor(transform(rgbimg_low)).to(device)

        geo_emb = torch.Tensor([row.Latitude,row.Elevation]).unsqueeze(0).to(device)

        _, score = model(rgb_input_high,rgb_input_low,geo_emb)
        eval_csv.iloc[row.Index,-1] = score.item()
        
    unnormcsv = pd.read_csv('./data/Seoul_Evaluation_unnormalize_data.csv',index_col=0)
    thismax, thismin = unnormcsv['CHELSA'].max(), unnormcsv['CHELSA'].min()
    eval_csv['pred'] = eval_csv['pred'] * (thismax-thismin) + thismin
    eval_csv['pred'] = (eval_csv['pred']/10) - 273 # CHELSA: unit of K/10
    
    print("Spearman: {}".format(eval_csv[['Summer_Temp','pred']].corr(method='spearman').iloc[0,1]))
    print("Pearson: {}".format(eval_csv[['Summer_Temp','pred']].corr(method='pearson').iloc[0,1]))
    print("MAE: {}".format(mean_absolute_error(eval_csv.pred,eval_csv.Summer_Temp)))

    