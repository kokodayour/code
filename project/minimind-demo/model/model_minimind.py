import math
import torch
import torch.nn as nn
from transformers import PretrainedConfig

class MiniMindConfig(PretrainedConfig):
    model_type = "minimind"
    def __init__(self, hidden_size=768, num_hidden_layers=8, use_moe=False, **kwargs):
        super().__init__(**kwargs)
        ##### 核心配置 #####
        self.hidden_size = hidden_size # 隐藏层维度 即每个token被embedding后的维度
        self.num_hidden_layers = num_hidden_layers # Transformer层数
        self.num_attention_heads = kwargs.get("num_attention_heads", 8) # 注意力头数
        self.num_key_value_heads = kwargs.get("num_key_value_heads", 4) # KV头数 减少KV缓存 节省显存
        self.head_dim = kwargs.get("head_dim", self.hidden_size // self.num_attention_heads) # 每个头的维度
        self.hidden_act = kwargs.get("hidden_act", "silu") # 激活函数
        self.intermediate_size = kwargs.get("intermediate_size", math.ceil(hidden_size*math.pi/64)*64) # 前馈网络中间层维度
        ##### 词表与分词 #####
        self.vocab_size = kwargs.get("vocab_size", 6400)
        self.bos_token_id = kwargs.get("bos_token_id", 1)
        self.eos_token_id = kwargs.get("eos_token_id", 2)
        self.tie_word_embeddings = kwargs.get("tie_word_embeddings", True) # 是否将输入输出embedding绑定
        ##### 位置编码 #####
        self.max_position_embeddings = kwargs.get("max_position_embeddings", 32768) # 最大序列长度 即模型能够处理的最长token数(32k上下文)
        self.rope_theta = kwargs.get("rope_theta", 1e6) # RoPE基频 控制旋转位置编码的周期
        self.inference_rope_scaling = kwargs.get("inference_rope_scaling", False) # 是否启用推理时RoPE缩放(用于长度外推)
        self.rope_scaling = { # RoPE缩放配置
            "beta_fast": 32,
            "beta_slow": 1,
            "factor": 16,
            "original_max_position_embeddings": 2048,
            "attention_factor": 1.0,
            "type": "yarn"
        } if self.inference_rope_scaling else None
        ##### 其它设置 #####
        self.rms_norm_eps = kwargs.get("rms_norm_eps", 1e-6) # 归一化时防除零
        self.dropout = kwargs.get("dropout", 0.0)
        self.flash_attn = kwargs.get("flash_attn", True)
        ##### MOE #####
        self.use_moe = use_moe
        self.num_experts = kwargs.get("num_experts", 4)
        self.num_experts_per_tok = kwargs.get("num_experts_per_tok", 1)
        
class RMSNorm(nn.modules):
    def __init__(self, dim:int, eps:float=1e-5):
        super().__init__()
        self.eps = eps
        self.weight = nn.Parameter(torch.ones(dim))

    def norm(self, x):
        return x*torch.rsqrt(x.pow(2).mean(-1, keepdim=True)+self.eps)
    
    def forward(self, x):
        return (self.weight*self.norm(x.float())).type_as(x)
    
class Attention(nn.Module):
    def __init__(self, config: MiniMindConfig):
        super().__init__()