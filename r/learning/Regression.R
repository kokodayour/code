# 加载必要的库
library(datasets)

# 加载iris数据集
data(iris)

# 将问题转换为二分类问题：选择"setosa"和"versicolor"两类
iris_binary <- subset(iris, Species %in% c("setosa", "versicolor"))

# 将目标变量转换为因子类型
iris_binary$Species <- factor(iris_binary$Species)

# 检查数据
head(iris_binary)

# 拆分数据集为训练集和测试集
set.seed(42)
train_indices <- sample(1:nrow(iris_binary), size = 0.7 * nrow(iris_binary))
train_data <- iris_binary[train_indices, ]
test_data <- iris_binary[-train_indices, ]

# 训练逻辑回归模型
model <- glm(Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
             data = train_data, family = binomial)

# 查看模型摘要
summary(model)


