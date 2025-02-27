import matplotlib.pyplot as plt
from sklearn.cluster import AgglomerativeClustering
import numpy as np

# 示例数据，这里生成一些二维的随机数据点
data = np.random.rand(100, 2)

# 创建层次聚类模型，设置聚类数量为3，使用欧氏距离和平均链接方法
clustering = AgglomerativeClustering(n_clusters=3, metric='euclidean', linkage='average')
clustering.fit(data)

# 获取聚类标签
labels = clustering.labels_

# 获取不同的聚类标签
unique_labels = np.unique(labels)
# 为不同标签设置不同颜色，这里使用tab10颜色映射
colors = [plt.cm.tab10(each) for each in np.linspace(0, 1, len(unique_labels))]

for k, col in zip(unique_labels, colors):
    # 筛选出属于当前标签的数据点
    class_member_mask = (labels == k)
    xy = data[class_member_mask]
    # 绘制散点图，用不同颜色表示不同簇
    plt.scatter(xy[:, 0], xy[:, 1], c=[col], label=f'Cluster {k}', s=50, edgecolors='k')

# 添加标题和坐标轴标签
plt.title("Hierarchical Clustering Result")
plt.xlabel("Feature 1")
plt.ylabel("Feature 2")
# 添加图例
plt.legend()
# 显示图形
plt.show()
