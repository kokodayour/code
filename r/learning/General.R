getwd() # 查看工作路径
setwd("D:/code/r/learning") # 设置工作路径
?getwd # 查看函数用法
install.packages("tidyverse") # 安装包
library("tidyverse") # 导入包
update.packages("tidyverse") # 升级指定包
update.packages() # 升级所有包

# 解决函数冲突
library("conflicted")
conflict_prefer("lag", "dplyr")
conflict_prefer("filter", "dplyr")

# 查看对象的类型
typeof()

# 查看对象地址
install.packages("pryr")
library(pryr)
x = 0.5
address(x)

# 保存加载数据
save("./data.Rda")
load("./data.Rda")
