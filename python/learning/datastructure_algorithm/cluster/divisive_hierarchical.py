import numpy as np
from scipy.cluster.hierarchy import fcluster, linkage
import matplotlib.pyplot as plt

# 示例数据，生成一些二维的随机数据点
data = np.random.rand(100, 2)

# 使用ward方法计算聚类的层次结构（连接矩阵），这里使用欧氏距离
Z = linkage(data, method='ward', metric='euclidean')

# 设定分裂的条件，这里假设要分裂成3个类，通过maxclust参数指定
k = 3
clusters = fcluster(Z, k, criterion='maxclust')

# 获取不同的聚类标签
unique_clusters = np.unique(clusters)
# 为不同标签设置不同颜色，这里使用tab10颜色映射
colors = [plt.cm.tab10(each) for each in np.linspace(0, 1, len(unique_clusters))]

for cluster_id, col in zip(unique_clusters, colors):
    # 筛选出属于当前标签的数据点
    class_member_mask = (clusters == cluster_id)
    xy = data[class_member_mask]
    # 绘制散点图，用不同颜色表示不同簇
    plt.scatter(xy[:, 0], xy[:, 1], c=[col], label=f'Cluster {cluster_id}', s=50, edgecolors='k')

# 添加标题和坐标轴标签
plt.title("Divisive Hierarchical Clustering Result")
plt.xlabel("Feature 1")
plt.ylabel("Feature 2")
# 添加图例
plt.legend()
# 显示图形
plt.show()
