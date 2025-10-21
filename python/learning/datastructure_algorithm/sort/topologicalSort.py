# 拓扑排序是对有向无环图的所有顶点进行线性排序, 使得对于任何从顶点u到顶点v的有向边(u,v)在排序中u都出现在v之前
from collections import deque, defaultdict
def topological_sort_kahn(edges, n):
    # 构建邻接表和入度数组
    graph = defaultdict(list)
    indegree = [0]*n

    # 1. 计算每个顶点的入度
    for u, v in edges:
        graph[u].append(v)
        indegree[v] += 1

    # 2. 将所有入度为0的顶点加入队列
    queue = deque([i for i in range(n) if indegree[i]])
    result = []

    while queue:
        # 3. 从队列中取出顶点 将其加入拓扑排序结果
        node = queue.popleft()
        result.append(node)

        # 4. 将该顶点的所有邻居的入度减1 如果某个邻居的入度变为0 则加入队列
        for neighbor in graph[node]:
            indegree[neighbor] -= 1
            if indegree[neighbor] == 0:
                queue.append(neighbor)

    # 5. 如果结果中的顶点数不等于总顶点数 说明图中有环
    if len(result) != n:
        return []
    return result

def topological_sort_dfs(edges, n):
    graph = defaultdict(list)
    for u, v in edges:
        graph[u].append(v)

    visited = [0]*n # 0:未访问 1:访问中 2:已完成
    result = []

    def dfs(node):
        if visited[node] == 1: # 发现环
            return False
        if visited[node] == 2: # 已处理完毕
            return True
        
        visited[node] = 1 # 标记为访问中
        for neighbor in graph[node]:
            if not dfs(neighbor):
                return False
        
        visited[node] = 2 # 标记为已完成
        result.append(node)
        return True
    
    for i in range(n):
        if visited[i] == 0:
            if not dfs(i):
                return [] # 有环
    
    return result[::-1] # 需要反转 因为DFS是最后加入根节点

