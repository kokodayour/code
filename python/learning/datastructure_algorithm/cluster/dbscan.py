# 1. 将所有的点分为核心点和非核心点 核心点是指该点的邻域内所包含的其它点的数量大于预设阈值
# 2. 随即指定一个核心点 将核心点周围的所有核心点指定成一个簇(如果A是一个核心点 则将邻域内的B和C核心点拉进这个簇 对B和C进行同样的操作)
# 3. 如果一个非核心点的邻域内包含核心点 则它被拉近这个簇
# 4. 如果一个非核心点的周围没有核心点 则它是离群点(噪音点)
# 5. 剩下的核心点都不靠近之前的簇 开始一个新的簇 重复234 直到所有核心点都被指定到某个簇
import matplotlib.pyplot as plt
from sklearn.cluster import DBSCAN
from sklearn.datasets import make_blobs

# 生成样本数据
X, _ = make_blobs(n_samples=300, centers=4, cluster_std=0.60, random_state=0)
# 创建DBSCAN模型
db = DBSCAN(eps=0.3, min_samples=10)
# 训练DBSCAN模型
labels = db.fit_predict(X)

# 可视化结果
plt.figure(figsize=(8, 6))
plt.scatter(X[:, 0], X[:, 1], c=labels, cmap='viridis')
plt.title('DBSCAN Clustering')
plt.xlabel('X1')
plt.ylabel('X2')
plt.show()
