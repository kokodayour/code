import glob
import torch
import random
import numpy as np
import pandas as pd

from skimage import io, transform
from PIL import Image
from torchvision import transforms
import torchvision.transforms.functional as F 
from torch.utils.data import Dataset

class RegressionDataset_RGB_DualZL(Dataset):
    def __init__(self, metadata_path,dir_name_highZL, dir_name_lowZL, transform=None):
        self.dir_name_highZL = dir_name_highZL
        self.dir_name_lowZL = dir_name_lowZL
        self.metadata = pd.read_csv(metadata_path,index_col=0)
        self.transform = transform

    def __len__(self):
        return len(self.metadata)

    def __getitem__(self, idx):
        one_yx = self.metadata.iloc[idx,0]
        
        rgbimg_highZL = io.imread('{}/{}.png'.format(self.dir_name_highZL,one_yx)) / 255.0
        image_highZL = np.expand_dims(rgbimg_highZL,axis=0)
        
        rgbimg_lowZL = io.imread('{}/{}.png'.format(self.dir_name_lowZL,one_yx)) / 255.0
        image_lowZL = np.expand_dims(rgbimg_lowZL,axis=0)
        
        latitude = self.metadata.iloc[idx,1]
        longitude = self.metadata.iloc[idx,2]
        elevation = self.metadata.iloc[idx,3]
        CHELSA = self.metadata.iloc[idx,4]
        
        if self.transform:
            image_bothZL = np.vstack([image_highZL,image_lowZL])
            image_bothZL = self.transform(image_bothZL)
            image_highZL = image_bothZL[0]
            image_lowZL = image_bothZL[1]
        
        return image_highZL,image_lowZL,latitude,longitude,elevation,CHELSA

class GroupDataset_RGB_DualZL(Dataset):
    def __init__(self, group_list, metadata_path, dir_name_highZL, dir_name_lowZL, transform=None):
        self.file_list = []
        self.dir_name_highZL = dir_name_highZL
        self.dir_name_lowZL = dir_name_lowZL
        self.metadata = pd.read_csv(metadata_path,index_col=0)
        self.transform = transform      
        for group_num in group_list:
            self.file_list.extend(self.metadata[(self.metadata['LSTlabel'] == group_num)].index)
        self.metadata = self.metadata.iloc[self.file_list,:].reset_index(drop=True)

    def __len__(self):
        return len(self.metadata)

    def __getitem__(self, idx):
        one_yx = self.metadata.iloc[idx,0]
        
        rgbimg_highZL = io.imread('{}/{}.png'.format(self.dir_name_highZL,one_yx)) / 255.0
        image_highZL = np.expand_dims(rgbimg_highZL,axis=0)
        
        rgbimg_lowZL = io.imread('{}/{}.png'.format(self.dir_name_lowZL,one_yx)) / 255.0
        image_lowZL = np.expand_dims(rgbimg_lowZL,axis=0)
        
        latitude = self.metadata.iloc[idx,1]
        longitude = self.metadata.iloc[idx,2]
        elevation = self.metadata.iloc[idx,3]
        
        if self.transform:
            image_bothZL = np.vstack([image_highZL,image_lowZL])
            image_bothZL = self.transform(image_bothZL)
            image_highZL = image_bothZL[0]
            image_lowZL = image_bothZL[1]
        
        return image_highZL,image_lowZL,latitude,longitude,elevation
    
class RandomRotate(object):
    def __call__(self, images):
        rand_num = np.random.randint(0, 4)
        rotated = np.stack([self.random_rotate(x,rand_num) for x in images])
        return rotated
    
    def random_rotate(self, image, rand_num):
        if rand_num == 0:
            return np.rot90(image, k=1, axes=(0, 1))
        elif rand_num == 1:
            return np.rot90(image, k=2, axes=(0, 1))
        elif rand_num == 2:
            return np.rot90(image, k=3, axes=(0, 1))   
        else:
            return image
        
class Normalize(object):
    def __init__(self, mean, std, inplace=False):
        self.mean = mean
        self.std = std
        self.inplace = inplace

    def __call__(self, images):
        normalized = np.stack([F.normalize(x, self.mean, self.std, self.inplace) for x in images])

        return normalized
        
class ToTensor(object):
    def __call__(self, images):
        images = images.transpose((0, 3, 1, 2))
        
        return torch.from_numpy(images).float()
    