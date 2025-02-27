# 向量 相当于array 但元素要统一
numeric(10) # 长度为10的全0向量
c(1, 2, 3, 4, 5) # 合并多个对象
1:5 # 创建等差数列 相当于切片 同seq(5) range
seq(3, length.out = 10) # 从3开始生成10个数
seq(1, 10, 2) # 从1开始 到10结束 步长为2
rep(1:3, 2) # 重复向量 rep(x, each, times, length.out)
rep(1:3, each = 2) # 重复元素
rep(1:3, each = 2, length.out = 4) # 只出4个元素
rep(1:3, c(2, 1, 2)) # 按规则重复元素
rep(1:3, times = 3, each = 2) # 总体重复3次
2:3 + 1:5 # 向量可以做四则运算 短的向量会循环补齐以配合长的
1:2 > 2:1 # 向量做逻辑运算得到的结果是逻辑向量
c(1, 4) %in% c(1, 2, 3) # 相当于python中的in
writeLines("is 'you' a Chinese name?") # 输出纯字符串内容
v1 = c(11, 2, 32, 4)
# 总而言之 中括号内的相当于过滤筛选条件
v1[2]
v1[2:4]
v1[-3] # 访问除第3个元素
v1[3:6]
v1[c(1, 3)] # 访问第1个和第3个元素
v1[c(T, F, T, F)] # 通过逻辑向量决定符号是否被获取
v1[v1 <= 20]
v1[v1 ^ 2 - v1 >= 100]
max(v1) # v1中的最大值
which.min(v1) # v1中最小值的索引
v1[c(T, F, T, F)] = c(3, 2) # 先访问到向量子集 再赋值
v1[6] = 8 # 若对不存在的位置赋值, 前面将用NA补齐
v2 = c(a = 1, b = 2, c = 3) # 创建向量时可以对每个元素命名
v2[c("a", "c")] # 命名后可以通过名字来访问元素
names(v2) # 获取v2的名字
names(v2) = NULL # 移除元素的名字
names(v2) = c("x", "y", "z") # 更改元素的名字
v2["x"] # []提取对象的子集 取出标签为x的糖果盒(同类型对象)
v2[["x"]] # [[]]提取对象内的元素 取出标签为a的糖果盒里的糖果(下一级元素)
v3 = c(1, 5, 8, 2, 9, 7, 4)
sort(v3) # 这里返回拍好的序 但并没有改变v3
order(v3) # 返回元素排好序的索引
rev(v3) # 翻转向量

# 矩阵是用两个维度表示和访问的向量
matrix(1:9, nrow = 3, byrow = T) # byrow是否按行排列元素
m1 = matrix(1:9, nrow = 3, 
       dimnames = list(c("r1","r2","r3"),c("c1","c2","c3"))) # 命名行列
# rownames(m1)  = c('r1','r2','r3') 可以创建后再命名

diag(1:4, nrow=4) # 对角矩阵
m1[-1,] # 提取除了第一行的所有元素
m1[3:7] # 看成是一个向量 从上往下 从左往右索引
m1>3 # 逻辑运算 返回一个逻辑矩阵
m1[m1>3] # 根据逻辑矩阵进行元素筛选

# 多维数组
a1 = array(1:24, dim=c(3,4,2), 
      dimnames=list(c("r1","r2","r3"), c("c1","c2","c3","c4"), c("k1","k2")))
# 在想象多维数组时 将各维度依次想象为"书"相关的概念 行列页本层架室
a1["r1","c2","k2"]
a1[1,2:4,1:2]

# 列表相当于list
l0 = list(1,c(T, F),c('a','b','c')) # 也可以为各元素指定名字
names(l0) = c('x', 'y', 'z')
l0$y # 使用$+元素名字来提取内容
l0[["y"]] = 0 # 使用[[]]来提取内容并赋值
l0[c("x", "z")] = list(2333, c("w","d","k"))
l0$a = "a" # 对不存在的成分命名时, 会自动添加成分
as.list(c(a=1,b=2)) # 将向量转换为列表
unlist(list(1:9)) # 列表转向量

# 数据框
library(tidyverse)
library(conflicted)
conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")
df = tibble(
  id = 1:4,
  lever = c(0, 2, 1, -1),
  score = c(0.5, 0.2, 0.1, 0.5)
)
names(df) = c("id", "x", "y")
person = tribble(
  ~Name, ~Gender, ~Age, ~Major,
  "Ken", "Male", 24, "Finance",
  "Ashley", "Female", 25, "Statistics"
)  # 按行创建数据框 这里是tribble 不是tibble!!!
df$x # 相当于df[['x']]
df[df$y >= 0.5, c("id","y")] # 根据条件筛选数据
df[1:2, names(df) %in% c("x","y","w")]
df$z = df$x+df$y # 列运算 
df$z = as.character(df$z) # 转换列类型
summary(df) # 相当于describe
# 添加行
person = rbind(person, tibble(Name = "John", Gender = "male", Age=25, Major="Statistics")) 
# 添加列
cbind(person, Registered = c(T, T, F), Projects = c(3,2,3))
expand.grid(type=c("A","B"), class = c("M","L","XL")) # 生成笛卡尔积
person['Name'] # 获取糖果盒(series)
person[['Name']] # 获取糖果盒里的糖果
person$Name[3]
person[1:2] # 返回一二列
person[[1,]] # 返回第一行
person[1][1]
