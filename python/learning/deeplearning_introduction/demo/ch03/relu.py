import numpy as np
import matplotlib.pyplot as plt

def relu(x):
    return np.maximum(x, 0)

x = np.arange(-5.0, 5.0, 0.1)
y = relu(x)
plt.plot(x, y)
plt.show()
