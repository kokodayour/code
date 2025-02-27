import numpy as np


def kmeans(X, k, max_iters=100):
    np.random.seed(0)
    centers = X[np.random.choice(len(X), k, replace=False)]

    for _ in range(max_iters):
        labels = np.argmin(np.linalg.norm(X[:, np.newaxis] - centers, axis=2), axis=1)
        new_centers = np.array([X[labels == i].mean(axis=0) for i in range(k)])
        if np.all(centers == new_centers):
            break
        return labels, centers


# 生成一些示例数据
np.random.seed(1)
X = np.concatenate([np.random.randn(50, 2), np.random.randn(50, 2) + [3, 3], np.random.randn(50, 2) + [3, -3]])

# 调用手动实现的K均值算法
k = 3
cluster_labels, cluster_centers = kmeans(X, k)

# 打印聚类结果和簇中心
print("Cluster Labels:", cluster_labels)
print("Cluster Centers:", cluster_centers)

"""
from sklearn import datasets
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
import matplotlib.pyplot as plt
import warnings

warnings.filterwarnings('ignore')

iris = datasets.load_iris()
X = iris.data
y = iris.target

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

kmeans = KMeans(n_clusters=4, random_state=12)
kmeans.fit(X_scaled)
# 在Scikit-Learn中，一些属性名的后面加上下划线（例如 labels_）是一种约定，用于表示这些属性是通过拟合（fitting）模型后获得的结果
cluster_labels = kmeans.labels_
print(silhouette_score(X_scaled, cluster_labels))

plt.figure(figsize=(10, 6))
# c=color表点的颜色 s=size表点的像素大小
scatter = plt.scatter(X_scaled[:, 0], X_scaled[:, 1], c=cluster_labels, cmap='viridis', s=50)
plt.colorbar(scatter, label='Cluster Labels')
plt.xlabel("Sepal Length(scaled)")
plt.ylabel("Sepal Width(scaled)")
cluster_centers = kmeans.cluster_centers_
plt.scatter(cluster_centers[:, 0], cluster_centers[:, 1], c='red', marker='x', s=200, label='Cluster Centers')
plt.title("kmeans clustering of iris data")
plt.legend()
plt.show()
"""
