install.packages("tidyverse")
install.packages("readr")
install.packages("readxl")
install.packages("heaven")
install.packages("jsonlite")
install.packages("readtext")
install.packages("magrittr")
install.packages("dplyr")
install.packages("tidyr")
install.packages("rlist")
install.packages("lubridate")

library(tidyverse)
library(readr)
library(readxl)
library(haven)
library(jsonlite)
library(readtext)
library(magrittr)
library(dplyr)
library(tidyr)
library(rlist)
library(lubridate)


#约定工作目录，根据具体情况更改
file_path<-"E:/R_course/Chapter2/Data"
setwd(file_path)
getwd()

###2.2.1读入基础数据
cp<-read_delim("comp.csv")
cp.csv<-read_csv("comp.csv")
summary(cp.csv)
spec(cp.csv)
cp.xl<-read_excel("comp.xlsx")
summary(cp.xl)

system.time(read_csv("data.csv"))
system.time(read.csv("data.csv"))

##写入基础数据
#创建包含多列的数据框
df <- data.frame(
  x <- c(1, NA, 2, 3, NA),
  y <- c("A", "B", "C", NA, "D"),
  z <- c(TRUE, FALSE, TRUE, TRUE, NA)
)
#将数据框写入文本文件 "df.txt"，缺失值用 "*" 表示，分隔符为逗号
write_delim(df, "df.txt", na = "*", delim = ",")
#将数据框写入 CSV 文件
write_csv(df, "df.csv")


###2.3基础数据存储
#逐行运行以检查效果
history(5)
setwd(file_path)
save.image(".RData")
savehistory(".Rhistory")
ls()
rm(x)
ls()
rm(list=ls())
ls()
load(".RData")
loadhistory(".Rhistory")
ls()
save(cp, y, file="objectlist.rda")
rm(list=ls())
ls()
load("objectlist.rda")
ls()


###2.4
###2.4.1 
element_2_3 <- cp[2, 3]
element_2_3

element_2_Dame <- cp[2, 'Dame']
element_2_Dame

selected_dame_column <- select(cp, Dame)
selected_dame_column

#ifelse()函数
data <- data.frame(values = c(1, NA, 3, NA, 5))
data$values <- ifelse(is.na(data$values), 0, data$values)
data

#select() filter()
cp[2,3]
cp[2,'Dame']
select(cp,Dame)
select(cp,starts_with("p"))
filter(cp,Dame==0)

#多列值筛选数据
set.seed(123) 
data <- tibble(
  id = 1:10,
  age = sample(18:60, 10, replace = TRUE),
  salary = sample(30000:80000, 10, replace = TRUE),
  department = sample(c("HR", "IT", "Finance", "Marketing"), 10, replace = TRUE),
  start_date = sample(seq(as.Date('2010-01-01'), as.Date('2020-01-01'), by="day"), 10),
  score = round(runif(10, 1, 10), 0),
  bonus = c(NA, runif(9, 500, 2000)),
  hours_worked = c(40, 35, NA, 45, 50, 38, 42, 47, 33, NA),
  region = sample(c("North", "South", "East", "West"), 10, replace = TRUE),
  performance = c(rnorm(8), -5, 15) 
)
selected_data <- data %>%
  select(id, age, salary, department)
selected_data

filtered_data <- data %>%
  filter(age > 30, salary > 50000)
filtered_data

arranged_data <- data %>%
  arrange(salary)
arranged_data

mutated_data <- data %>%
  mutate(salary_per_hour = salary / hours_worked)
mutated_data

summarized_data <- data %>%
  group_by(department) %>%
  summarize(average_salary = mean(salary, na.rm = TRUE))
summarized_data

###2.4.2管道操作
numbers <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
#使用管道操作进行数据处理，包括转换为数据框、平方、筛选偶数、求和
result <- numbers %>%
  # 转换为数据框
  as.data.frame() %>%
  # 平方
  mutate(squared = .^2) %>%
  # 筛选偶数
  filter(squared %% 2 == 0) %>%
  # 求和
  summarise(sum = sum(squared))
#提取结果
result <- result$sum
result


df <- data.frame( x = 1:5,  y = c(2, 4, 6, 8, 10))
result <- df %>% mutate(z = y / x) %T>% print() %>% filter(z > 1) %$% x*10
print(result)
print(df)
df %<>% mutate(z = y / x) %<>% filter(z > 1)
print(df)

###2.4.3数据连接
###(1)合并行和合并列
# 示例数据框
df1 <- tibble(x = 1:3, y = c("a", "b", "c"))
df2 <- tibble(x = 4:6, y = c("d", "e", "f"))
# 合并行
combined_rows <- bind_rows(df1, df2)
combined_rows
# 合并列
combined_cols <- bind_cols(df1, df2)
combined_cols

###(2)根据值匹配合并数据框
# 创建员工数据框
employees_df <- tibble(
  emp_id = c(101, 102, 103),
  emp_name = c("Alice", "Bob", "Charlie"),
  dept_id = c(1, 2, 1)
)

# 创建部门数据框
departments_df <- tibble(
  dept_id = c(1, 2, 3),
  dept_name = c("HR", "Finance", "IT")
)

##左连接
left_join_df <- left_join(employees_df, departments_df, by = "dept_id")
left_join_df
##右连接
right_join_df <- right_join(employees_df, departments_df, by = "dept_id")
right_join_df
##全连接
full_join_df <- full_join(employees_df, departments_df, by = "dept_id")
full_join_df
##内连接
inner_join_df <- inner_join(employees_df, departments_df, by = "dept_id")
inner_join_df
##半连接
semi_join_df <- semi_join(employees_df, departments_df, by = "dept_id")
semi_join_df
##反连接
anti_join_df <- anti_join(employees_df, departments_df, by = "dept_id")
anti_join_df

###(3)集合运算
# 示例数据框
set1 <- tibble(x = 1:5)
set2 <- tibble(x = 4:8)
# 交集
intersect_result <- intersect(set1, set2)
intersect_result
# 并集
union_result <- union(set1, set2)
union_result
# 差集（在 set1 中但不在 set2 中）
setdiff_result <- setdiff(set1, set2)
setdiff_result

###2.4.4数据重塑
###(1)宽表变长表&长表变宽表
# 创建一个不整洁的数据框
messy_data <- tibble(
  subject = c("S1", "S2", "S3"),
  test1_score = c(80, 90, 85),
  test2_score = c(88, 92, 84)
)
##宽表变长表
long_data <- messy_data %>%
  pivot_longer(
    cols = starts_with("test"),
    names_to = "test",
    values_to = "score"
  )
long_data
##长表变宽表
wide_data <- long_data %>%
  pivot_wider(
    names_from = test,
    values_from = score
  )
wide_data

###(2)拆分列与合并列
#创建一个数据框
original_data <- tibble(
  subject = c("S1", "S2", "S3"),
  score = c("80-88", "90-92", "85-84")
)
##拆分列
separated_data <- original_data %>%
  separate(col = score, into = c("test1_score", "test2_score"), sep = "-")
separated_data
##合并列
united_data <- separated_data %>%
  unite(col = "combined_score", c("test1_score", "test2_score"), sep = "-")
united_data

###2.4.5基础数据处理
data_no_missing <- data %>%
  filter(complete.cases(.))

data_filled <- data %>%
  mutate(hours_worked = ifelse(is.na(hours_worked), mean(hours_worked, na.rm = TRUE), hours_worked))

data_no_outliers <- data %>%
  filter(performance >= -3 & performance <= 3)

median_performance <- median(data$performance, na.rm = TRUE)
data_replace_outliers <- data %>%
  mutate(performance = ifelse(performance < -3 | performance > 3, median_performance, performance))

data_processed <- data %>%
  mutate(
    hours_worked = ifelse(is.na(hours_worked), mean(hours_worked, na.rm = TRUE), hours_worked),
    bonus = ifelse(is.na(bonus), mean(bonus, na.rm = TRUE), bonus)
  ) %>%
  mutate(
    performance_error = ifelse(performance < -3 | performance > 3, TRUE, FALSE)
  )


###(4)非关系型数据的处理
#简单提取
person <- 
  list(
    p1=list(name="Ken",age=24,
            interest=c("reading","music","movies"),
            lang=list(r=2,csharp=4,python=3)),
    p2=list(name="James",age=25,
            interest=c("sports","music"),
            lang=list(r=3,java=2,cpp=5)),
    p3=list(name="Penny",age=24,
            interest=c("movies","reading"),
            lang=list(r=1,cpp=4,python=2)))
str(person)
list.map(person, age)
list.map(person, names(lang))
p.age25 <- list.filter(person, age >= 25)
str(p.age25)
p.py3 <- list.filter(person, lang$python >= 3)
str(p.py3)


#借助dplyr函数包的核心函数处理
# 创建一个数据框
person_df <- tibble(
  name = c("Ken", "James", "Penny"),
  age = c(24, 25, 24),
  interest = list(c("reading", "music", "movies"),
                  c("sports", "music"),
                  c("movies", "reading")),
  lang = list(list(r = 2, csharp = 4, python = 3),
              list(r = 3, java = 2, cpp = 5),
              list(r = 1, cpp = 4, python = 2))
)
# 查看数据框结构
print(str(person_df))
#映射和过滤
# 映射年龄列
person_df %>%
  mutate(age_list = map(age, ~ .x)) %>%
  select(age_list)

# 映射语言名称
person_df %>%
  mutate(lang_names = map(lang, names)) %>%
  select(lang_names)

# 过滤年龄大于等于25的人
p_age25 <- person_df %>%
  filter(age >= 25)
print(str(p_age25))

# 过滤Python等级大于等于3的人
p_py3 <- person_df %>%
  filter(map_lgl(lang, ~ ifelse("python" %in% names(.x), .x$python >= 3, FALSE)))
print(str(p_py3))


###(5)关系型数据
#创建人员信息数据框
people_df <- tibble(
  person_id = c(1, 2, 3),
  name = c("Ken", "James", "Penny"),
  age = c(24, 25, 24)
)
# 创建语言技能数据框
languages_df <- tibble(
  person_id = c(1, 1, 2, 2, 3, 3),
  language = c("R", "C#", "R", "Java", "C++", "Python"),
  skill_level = c(2, 4, 3, 2, 4, 2)
)
# 查看人员信息数据框结构
print(str(people_df))
# 查看语言技能数据框结构
print(str(languages_df))

#操作数据
#关联（连接）两个数据框
joined_df <- left_join(people_df, languages_df, by = "person_id")
#查看合并后的数据框结构
print(str(joined_df))
# 过滤特定条件的记录（例如，年龄大于24）
filtered_df <- joined_df %>%
  filter(age > 24)
print(str(filtered_df))
#汇总数据（例如，计算每个人掌握的语言数量）
summarized_df <- joined_df %>%
  group_by(name) %>%
  summarize(number_of_languages = n())
print(str(summarized_df))
#转换长格式为宽格式
wide_df <- joined_df %>%
  pivot_wider(
    names_from = language,
    values_from = skill_level,
    values_fill = list(skill_level = 0)
  )
print(str(wide_df))


###2.4.6lubridate包
# 创建时间点
begin1 <- ymd_hms("2015-09-03 12:00:00")
end1 <- ymd_hms("2016-08-04 12:30:00")
begin2 <- ymd_hms("2015-12-03 12:00:00")
end2 <- ymd_hms("2016-09-04 12:30:00")

# 创建时间间隔
date_1 <- interval(begin1, end1)
date_2 <- interval(begin2, end2)

# 检查时间间隔是否重叠
overlap <- int_overlaps(date_1, date_2)

# 输出时间间隔和重叠情况
print(date_1)
print(date_2)
print(overlap)

# 示例：提取日期组件
year(begin1) # 提取年份
month(end2) # 提取月份

# 示例：日期加减
one_week_later <- begin1 + weeks(1) # 在 begin1 上加一周
day_before_end2 <- end2 - days(1) # 在 end2 前减去一天

# 输出日期加减的结果
print(one_week_later)
print(day_before_end2)
