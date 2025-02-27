import numpy as np
import os
import sys
from dataset.mnist import load_mnist
from PIL import Image

sys.path.append(os.pardir)


def img_show(img):
    PIL_img = Image.fromarray(np.uint8(img))
    PIL_img.show()


(x_train, t_train), (x_test, t_test) = load_mnist(normalize=True, one_hot_label=True)

img = x_train[0]
label = t_train[0]
print(label)
print(img.shape)
img_show(img.reshape(28, 28))
