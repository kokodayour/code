import math

import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as transforms
import torch.utils.model_zoo as model_zoo

import torch.nn.functional as F

class ZoomNet_CrossAtt(nn.Module):
    def __init__(self, backbone_highZL, backbone_lowZL, hidden_dim=512, geo_dim=2, seed=0):
        super(ZoomNet_CrossAtt, self).__init__()
        self.backbone_highZL = backbone_highZL
        self.backbone_lowZL = backbone_lowZL
        
        self.norm1 = nn.LayerNorm(8,8)
        self.norm2 = nn.LayerNorm(8,8)
        torch.manual_seed(seed)
        self.key_trans = nn.Linear(hidden_dim, hidden_dim)
        torch.manual_seed(seed)
        self.query_trans = nn.Linear(hidden_dim, hidden_dim)
        torch.manual_seed(seed)
        self.value_trans = nn.Linear(hidden_dim, hidden_dim)
        
        self.max_pool = nn.MaxPool2d((64,1))
        self.avg_pool = nn.AdaptiveAvgPool2d(output_size=(1, 1))
        
        torch.manual_seed(seed)
        self.key_trans_inv = nn.Linear(hidden_dim, hidden_dim)
        torch.manual_seed(seed)
        self.query_trans_inv = nn.Linear(hidden_dim, hidden_dim)
        torch.manual_seed(seed)
        self.value_trans_inv = nn.Linear(hidden_dim, hidden_dim)
        
        self.max_pool_inv = nn.MaxPool2d((64,1))
        self.avg_pool_inv = nn.AdaptiveAvgPool2d(output_size=(1, 1))
        
        torch.manual_seed(seed)
        self.mlp = nn.Sequential(
            nn.Linear(hidden_dim+hidden_dim+geo_dim, 512),
            nn.ReLU(),
            nn.Linear(512, 1),
        )
        
    def forward(self, img_input_highZL, img_input_lowZL, geo_input):        
        img_embed_highZL = self.norm1(self.backbone_highZL(img_input_highZL))
        img_embed_lowZL = self.norm2(self.backbone_lowZL(img_input_lowZL))
        
        original_embed_highZL = self.avg_pool(img_embed_highZL).squeeze(-1).squeeze(-1)
        original_embed_lowZL = self.avg_pool_inv(img_embed_lowZL).squeeze(-1).squeeze(-1)
        
        batch_sz, inner_emb_dim, _, _ = img_embed_lowZL.shape
        img_embed_highZL = img_embed_highZL.view(batch_sz,inner_emb_dim,-1).transpose(-2,-1) 
        img_embed_lowZL = img_embed_lowZL.view(batch_sz,inner_emb_dim,-1).transpose(-2,-1) 
        
        img_embed_highZL_pooled = self.max_pool(img_embed_highZL)
        query = self.query_trans(img_embed_highZL_pooled)
        key = self.key_trans(img_embed_lowZL)
        value = self.value_trans(img_embed_lowZL)
        att_score = torch.softmax(torch.bmm(query,key.transpose(-2, -1))/ math.sqrt(inner_emb_dim),dim=-1)
        img_embed = torch.bmm(att_score,value)
        img_embed = img_embed.squeeze(1) + original_embed_lowZL
        
        img_embed_lowZL_pooled = self.max_pool_inv(img_embed_lowZL)
        query_inv = self.query_trans_inv(img_embed_lowZL_pooled)
        key_inv = self.key_trans_inv(img_embed_highZL)
        value_inv = self.value_trans_inv(img_embed_highZL)
        att_score_inv = torch.softmax(torch.bmm(query_inv,key_inv.transpose(-2, -1))/ math.sqrt(inner_emb_dim),dim=-1)
        img_embed_inv = torch.bmm(att_score_inv,value_inv)
        img_embed_inv = img_embed_inv.squeeze(1) + original_embed_highZL
        
        emb = torch.cat([img_embed, img_embed_inv, geo_input], dim=1)
        out = self.mlp(emb).squeeze(dim=-1)
 
        return img_embed, out

