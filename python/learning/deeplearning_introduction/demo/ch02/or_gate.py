import numpy as np

def OR(x1, x2):
    x = np.array([x1, x2])
    w = np.array([0.5, 0.5])
    b = -0.4
    tmp = x@w + b
    return 0 if tmp <= 0 else 1

if __name__ == '__main__':
    for xs in [(0,0),(1,0),(0,1),(1,1)]:
        y = OR(xs[0], xs[1])
        print(f'{xs} -> {y}')
