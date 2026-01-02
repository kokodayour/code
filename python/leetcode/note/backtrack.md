# 回溯问题

回溯有一个增量构造答案的过程 这个过程通常用递归实现

#### 背景: 暴力枚举 最多加一些剪枝
- 组合问题: N个数里面按一定规则找出K个数的集合
- 排列问题: N个数里面按一定规则全排列 有几种排列方式
- 切割问题: 一个字符串按一定规则有几种切割方式
- 子集问题: 一个N个数的集合里有多少符合条件的子集
- 棋盘问题: N皇后 解数独等等 

#### 反思：

`for循环`横向遍历 `递归`纵向遍历 回溯不断调整结果集![](https://pica.zhimg.com/v2-03908a0d3543b38759cd0cac358fc340_1440w.jpg "回溯")


#### 题目

1. 17


模板
```python
def dfs(i):
    if stop condition: # generally iterate the leaf node
        store result
        return
    for x in elements:
        process x
        dfs(i+1)
        backtrack and cancel process result
```