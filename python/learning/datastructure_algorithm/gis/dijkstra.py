import heapq


def dijkstra(graph, start):
    num_nodes = len(graph)
    # 初始化距离列表，用于存储从起始节点到每个节点的最短距离
    distance = [float('inf')] * num_nodes
    distance[start] = 0  # 起始节点到自身的距离为0

    # 用于跟踪已访问和未访问的节点
    visited = set()

    # 用于记录每个节点的父节点
    parents = [None] * num_nodes

    while len(visited) < num_nodes:
        # 从未访问的节点中选择距离最短的节点
        current_node = min((node for node in range(num_nodes) if node not in visited), key=lambda node: distance[node])
        visited.add(current_node)

        # 更新从当前节点到邻居节点的距离
        for neighbor in range(num_nodes):
            if graph[current_node][neighbor] > 0:  # 存在边
                new_distance = distance[current_node] + graph[current_node][neighbor]
                if new_distance < distance[neighbor]:
                    distance[neighbor] = new_distance
                    parents[neighbor] = current_node  # 记录父节点

    return distance, parents


def dijkstra_heap(graph, start):
    num_nodes = len(graph)
    # 初始化距离列表，用于存储从起始节点到每个节点的最短距离
    distance = [float('inf')] * num_nodes
    distance[start] = 0  # 起始节点到自身的距离为0

    # 用于记录每个节点的父节点
    parents = [None] * num_nodes

    # 使用堆来优化节点选择
    heap = [(0, start)]

    while heap:
        current_dist, current_node = heapq.heappop(heap)

        # 如果当前节点已经被访问过，跳过
        if current_dist > distance[current_node]:
            continue

        # 更新从当前节点到邻居节点的距离
        for neighbor, weight in enumerate(graph[current_node]):
            if weight > 0:  # 存在边
                new_distance = distance[current_node] + weight
                if new_distance < distance[neighbor]:
                    distance[neighbor] = new_distance
                    parents[neighbor] = current_node  # 记录父节点
                    heapq.heappush(heap, (new_distance, neighbor))

    return distance, parents


def backtrack_shortest_path(parents, start_node, target_node):
    path = []
    current_node = target_node

    while current_node != start_node:
        path.append(current_node)
        current_node = parents[current_node]

    path.append(start_node)
    path.reverse()  # 反转路径以获得正确的顺序
    return path


# 示例图的邻接矩阵表示，-1 表示节点之间没有直接连接
graph = [
    [0, 4, -1, -1, -1, -1],
    [4, 0, 8, 7, -1, -1],
    [-1, 8, 0, -1, 1, -1],
    [-1, 7, -1, 0, -1, 9],
    [-1, -1, 1, -1, 0, 6],
    [-1, -1, -1, 9, 6, 0]
]

start_node = 0  # 选择起始节点
target_node = 4  # 选择目标节点

shortest_distances, parents = dijkstra_heap(graph, start_node)
shortest_path = backtrack_shortest_path(parents, start_node, target_node)

print(f'从节点{start_node}到节点{target_node}的最短距离为{shortest_distances}')
print("最短路径:", shortest_path)
