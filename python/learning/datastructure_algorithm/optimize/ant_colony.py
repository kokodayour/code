import numpy as np
import random
import matplotlib.pyplot as plt


# 计算两点之间的距离
def distance(city1, city2):
    return np.sqrt((city1[0] - city2[0]) ** 2 + (city1[1] - city2[1]) ** 2)


# 初始化信息素矩阵
def init_pheromone(n):
    return np.ones((n, n))


# 根据概率选择下一个城市
def select_next_city(current_city, unvisited_cities, pheromone, distance_matrix, alpha, beta):
    probabilities = []
    total = 0
    for city in unvisited_cities:
        pheromone_value = pheromone[current_city][city]
        dist = distance_matrix[current_city][city]
        # 计算选择该城市的概率部分
        prob_part = (pheromone_value ** alpha) * ((1 / dist) ** beta)
        probabilities.append(prob_part)
        total += prob_part

    # 归一化概率
    probabilities = [p / total for p in probabilities]
    # 根据概率随机选择下一个城市
    selected_index = np.random.choice(len(unvisited_cities), p=probabilities)
    return unvisited_cities[selected_index]


# 蚂蚁构建路径
def build_path(start_city, num_cities, pheromone, distance_matrix, alpha, beta):
    unvisited_cities = list(range(num_cities))
    unvisited_cities.remove(start_city)
    current_city = start_city
    path = [current_city]
    while unvisited_cities:
        next_city = select_next_city(current_city, unvisited_cities, pheromone, distance_matrix, alpha, beta)
        path.append(next_city)
        unvisited_cities.remove(next_city)
        current_city = next_city
    path.append(start_city)
    return path


# 计算路径的长度
def path_length(path, distance_matrix):
    total_length = 0
    for i in range(len(path) - 1):
        total_length += distance_matrix[path[i]][path[i + 1]]
    return total_length


# 更新信息素
def update_pheromone(pheromone, ants_path, distance_matrix, Q, rho):
    num_cities = len(pheromone)
    # 信息素挥发
    pheromone *= (1 - rho)
    for path in ants_path:
        path_length_value = path_length(path, distance_matrix)
        for i in range(num_cities):
            j = (i + 1) % num_cities
            pheromone[path[i]][path[j]] += Q / path_length_value
    return pheromone


# 蚁群算法主函数
def ant_colony_optimization(num_ants, num_cities, alpha, beta, rho, Q, max_iterations, distance_matrix):
    best_path = None
    best_length = float('inf')
    pheromone = init_pheromone(num_cities)
    for _ in range(max_iterations):
        ants_path = []
        for _ in range(num_ants):
            start_city = random.randint(0, num_cities - 1)
            path = build_path(start_city, num_cities, pheromone, distance_matrix, alpha, beta)
            ants_path.append(path)
            length = path_length(path, distance_matrix)
            if length < best_length:
                best_length = length
                best_path = path
        pheromone = update_pheromone(pheromone, ants_path, distance_matrix, Q, rho)
    return best_path, best_length


# 测试示例
# 生成随机城市坐标
num_cities = 10
city_coordinates = np.random.rand(num_cities, 2)
distance_matrix = np.zeros((num_cities, num_cities))
for i in range(num_cities):
    for j in range(num_cities):
        distance_matrix[i][j] = distance(city_coordinates[i], city_coordinates[j])

num_ants = 10
alpha = 1
beta = 5
rho = 0.1
Q = 1
max_iterations = 100

best_path, best_length = ant_colony_optimization(num_ants, num_cities, alpha, beta, rho, Q, max_iterations,
                                                 distance_matrix)
print("最佳路径:", best_path)
print("最佳路径长度:", best_length)

# 可视化路径
x = [city_coordinates[city][0] for city in best_path]
y = [city_coordinates[city][1] for city in best_path]
x.append(x[0])
y.append(y[0])
plt.plot(x, y, marker='o')
plt.show()
