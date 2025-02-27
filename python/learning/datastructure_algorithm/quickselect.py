import random

def quickselect(arr, k):
    if len(arr) == 1:
        return arr[0]
    
    # 随机选择一个基准元素
    pivot = random.choice(arr)
    # 分区操作
    lows = [x for x in arr if x < pivot]
    highs = [x for x in arr if x > pivot]
    pivots = [x for x in arr if x == pivot]

    if k < len(lows):
        return quickselect(lows, k)
    elif k < len(lows) + len(pivots):
        return pivots[0]
    else:
        return quickselect(highs, k-len(lows)-len(pivots))

# 示例用法
arr = [3,1,4,1,5,9,2,6,5,3,5]
k = 4
result = quickselect(arr,k-1) # 注意k是从1开始的
print(f"第{k}小的元素是: {result}")