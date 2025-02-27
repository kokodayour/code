import numpy as np
import matplotlib.pyplot as plt

def numerical_diff(f, x):
    h = 1e-4
    return (f(x + h) - f(x - h)) / (2 * h)

def func1(x):
    return 0.01*x**2 + 0.1*x

def tangent_line(f,x):
    d = numerical_diff(f,x)
    print(d)
    y = f(x) - d*x
    return lambda t: d*t + y

x = np.linspace(0,20,200)
y1 = func1(x)
y2 = tangent_line(func1,5)(x)
plt.plot(x, y1, label="func1")
plt.plot(x, y2, label="func2")
plt.legend()
plt.show()
