install.packages("GWmodel")

install.packages("devtools")
library(devtools)

library(GWmodel)

###1.2.1基础数据类型
class(TRUE)
class(32.6)
class(2L)				
class('a')
class("aaaaa")
class(3+2i)
class(charToRaw("a"))

###1.2.2
#1.2.2.1向量
###普通向量的创建函数c
x <- c(1, 2, 3, 4, 5)
x
x<- c(1, 2, c(3, 4, 5)) 
x

###等差数值的向量
1:5
seq(5)
seq(1,5)
seq(1,10,2)

###重复序列
x = 1:3
rep(x, 2)
rep(x, c(2, 1, 2))
rep(x, each = 2, length.out = 4)
rep(x, times = 3, each = 2)

###1.2.2.2列表
list.1 <- list(name = "李明", age = 30, scores = c(85, 76, 90))
list.1[2]
list.1[[2]]
list.1$scores
list.1$age <- 45
list.1$age
list.1$age <- list(19, 29, 31)
list.1$age[1]
list.1$age[[1]]
list.2 <- as.list(c(a = 1, b = 2))
list.2
unlist(list.2)


###1.2.2.3矩阵
# 不按行填充
matrix(c(1, 2, 3,
         4, 5, 6,
         7, 8, 9), nrow = 3, byrow = FALSE)
# 按行填充
matrix(c(1, 2, 3,
         4, 5, 6,
         7, 8, 9), nrow = 3, byrow = TRUE)
# 为矩阵的行列命名
matrix(1:9, nrow = 3, byrow = TRUE,
       dimnames = list(c("r1","r2","r3"), c("c1","c2","c3")))
ml <- matrix(1:9, ncol = 3)
rownames(ml) = c("r1","r2","r3")
colnames(ml) = c("c1","c2","c3")
ml
# 特殊矩阵
diag(1:4, nrow = 4)


###读取矩阵中的元素
ml[1,2] 							# 提取第1行, 第2列的单个元素
ml[1:2, 2:3]						# 提取第1至2行, 第2至4列的元素
ml[c("r1","r3"), c("c1","c3")]		# 提取行名r1和r3, 列名为c1和c3的元素
# 如果一个维度空缺, 则选出该维度的所有元素
ml[1,]								# 提取第1行, 所有列元素
ml[,2:3]							# 提取所有行, 第2至3列的所有元素
# 负数表示排除该位置
ml[-1,]								# 提取除了第1行之外的所有元素
ml[,-c(2,3)]						# 提取除了第2和第4行之外的所有元素

as.vector(ml)

###1.2.2.4数据框
df <- data.frame(
  name = c("Zhang", "Li", "Lu"),
  age = c(25, 30, 35),
  score = c(85, 90, 95)
)

###访问dataframe中的元素
df$name  # 返回"name"列
df$age   # 返回"age"列
df["Alice", "age"]  # 返回"Alice"的年龄
df[1, "score"]      # 返回第一行的"score"值
df[1, ]    # 返回第一行
df[, 2]    # 返回第二列
df[1, 2]   # 返回第一行第二列的值
df[1:2, ]  # 返回前两行
df[, 1:2]  # 返回前两列

###tibble数据框
# 创建tibble法1
library(tibble)
person <- tibble(
  Name = c("Zhang", "Li", "Lu"),
  Gender = c("Female", "Male", "Male"),
  Age = c("20", "21", "27"),
  Major = c("Remote sensing", "Data science", "Physics"),
  ID = c("203", "301", "096")
)
person

###法2
tribble(
  ~Name, ~Gender, ~Age, ~Major, ~ID,
  "Zhang", "Female", "20", "Remote sensing", "203",
  "Li", "Male", "21", "Data science", "301",
  "Lu", "Male", "27", "Physics", "096")

###法3
as_tibble(df)

###数据框常用函数
###①合并数据框
# rbind() 增加行(样本数据), 要求宽度(列数一致)
person <- rbind(person,
                tibble(Name = "Jojo", Gender = "Male",
                       Age = 25, Major = "History", ID = 202))
# cbind() 增加列(属性变量), 要求高度一致
person <- cbind(person, 
                Registered = c(TRUE, TRUE, FALSE, TRUE),
                Class_ID = c(2, 3, 4, 1))


###②显示对象的结构
str(person)
glimpse(person)

###③汇总信息
summary(person)

###1.2.2.5因子
x = c(" 优", " 中", " 良", " 优", " 良", " 良") # 字符向量
x
sort(x)
###指定顺序
x1 = factor(x, levels = c(" 中", " 良", " 优")) # 转化因子型
x1
as.numeric(x1)


###识别错误
x <- c("优", "中", "良", "优", "良", "差")
print(x)
x1 <- factor(x, levels = c("中", "良", "优"))
print(x1)

###table函数
table(x)

###cut函数
Age = c(23,15,36,47,65,53)
# 参数 breaks 就是代表着切段的区间
Age_fac <- cut(Age, breaks = c(0,18,45,100),
               labels = c("Young","Middle","Old"))
class(Age_fac)


###gl函数
tibble(Sex = gl(2, 3, length=12, labels=c(" 男"," 女")),
       Class = gl(3, 2, length=12, labels=c(" 甲"," 乙"," 丙")),
       Score = gl(4, 3, length=12, labels=c(" 优"," 良"," 中", " 及格")))


###1.3.1变量
ls()
c(1, 2, 3, 4) -> V
print(V)
cat("The type of variable V is: ", class(V), "\n")
cat("The 3rd element of variable V is: ", V[3], "\n")
V[3] <- 10
cat("The 3rd element of variable V NOW is: ", V[3], "\n")


###1.3.2运算符号
2 + 3
2 * 3
2 / 3
2 - 3
2 + 3 * 4
2 + (3 * 4)
2^2
2^0.5
v <- c( 2,5.5,6)
s <- c(8, 3, 4)
v^s
v%%s
v%/%s
v <- c(2,5.5,6,9)
s <- c(8,2.5,14,9)
v>s
v>s
v>=s
v<=s
v==s
v!=s
(v>=s)&(v==s)
(v>s)|(v==s)
v <- 1:5
5 %in% v
v*t(v)
v%*%t(v)

###1.4.1判断体
x <- 30L
if(is.integer(x)) {
  print("X is an Integer")
}

x <- c("what","is","truth")
if("Truth" %in% x) {
  print("Truth is found")
}else {
  print("Truth is not found")
}
if("Truth" %in% x) {
  print("Truth is found the first time")
}else if ("truth" %in% x) {
  print("truth is found the second time")
}else {
  print("No truth found")
}
x <- switch(
  3,
  "first",
  "second",
  "third",
  "fourth"
)
print(x)



###1.4.2循环体
v <- c("Hello","loop")
cnt <- 2
repeat {
  print(v)
  cnt <- cnt+1
  if(cnt > 5) {
    break
  }
}

v <- c("Hello","while loop")
cnt <- 2
while (cnt < 7) {
  print(v)
  cnt = cnt + 1
}

v <- LETTERS[1:4]
for ( i in v) {
  print(i)
}


###1.4.3函数
new.function1 <- function() {
  for(i in 1: 5) {
    print(i^2)
  }
}
new.function1()

new.function2 <- function(a,b,c) {
  result <- a * b + c
  print(result)
}
new.function2(5,3,11)
new.function2(a = 11, b = 5, c = 3)

new.function2 <- function(a = 3, b = 6) {
  result <- a * b
  print(result)
}
new.function2()
new.function2(5)
new.function2(b=5)
