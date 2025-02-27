x = 10
if(x<0){ # 同python
  -x
}else{
  x
}
ifelse(x<0,-x,x) # 三元运算符 (条件,真,假)
switch(as.character(10),"10" = "apple","20" = "banana","30" = "cherry") # 同c
library(tidyverse)
df = as_tibble(iris[,1:4])
output = vector("double", 4)
for(i in 1:4){
  output[i] = mean(df[[i]])
}
output













