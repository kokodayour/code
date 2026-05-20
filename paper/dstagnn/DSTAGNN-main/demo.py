import torch
import torch.nn.functional as F
import numpy as np
import pandas as pd
import torch
import time
import argparse
from scipy.optimize import linprog

np.seterr(divide='ignore', invalid='ignore')

def wasserstein_distance(p, q, D):
    A_eq = []
    for i in range(len(p)):
        A = np.zeros_like(D)
        A[i, :] = 1
        A_eq.append(A.reshape(-1))
    for i in range(len(q)):
        A = np.zeros_like(D)
        A[:, i] = 1
        A_eq.append(A.reshape(-1))
    A_eq = np.array(A_eq)
    b_eq = np.concatenate([p, q])
    D = np.array(D)
    D = D.reshape(-1)

    result = linprog(D, A_eq=A_eq[:-1], b_eq=b_eq[:-1])
    myresult = result.fun

    return myresult


p = [1,2,3]
q = [4,5,6]
d = [[1,1,1],
     [1,1,1],
     [1,1,1]]
wasserstein_distance(p,q,d)