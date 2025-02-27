import os
import sys
import pickle
import numpy as np
from dataset.mnist import load_mnist
from common.functions import sigmoid, softmax

def get_data():
    (x_train, y_train), (x_test, y_test) = load_mnist()
    return x_train, y_train, x_test, y_test

def init_network():
    with open("sample_weight.pkl", "rb") as f:
        network = pickle.load(f)
    return network

def predict(network, x):
    W1, W2, W3 = network["W1"], network["W2"], network["W3"]
    b1, b2, b3 = network["b1"], network["b2"], network["b3"]
    a1 = x@W1 + b1
    z1 = sigmoid(a1)
    a2 = z1@W2 + b2
    z2 = sigmoid(a2)
    a3 = z2@W3 + b3
    y = softmax(a3)

    return y

_,_,x,t = get_data()
network = init_network()
accuracy_cnt = 0
for i in range(1000):
    y = predict(network, x[i])
    p = np.argmax(y)
    if p == t:
        accuracy_cnt += 1

print(f'Accuracy: {accuracy_cnt/len(x)*100:.2f}%')
