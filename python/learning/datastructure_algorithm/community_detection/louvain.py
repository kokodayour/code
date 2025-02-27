import networkx as nx
import community as community_louvain

# 创建一个简单的图示例
G = nx.karate_club_graph()

# 使用Louvain算法进行社区划分
partition = community_louvain.best_partition(G)

# 打印社区划分结果
print(partition)