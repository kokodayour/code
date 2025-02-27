import random
import math

def objective_function(x):
    return x ** 2

# 初始温度
T = 100
# 温度衰减率
alpha = 0.99
# 迭代次数
iterations = 1000
# 解空间范围
lower_bound = -10
upper_bound = 10

# 随机生成初始解
current_solution = random.uniform(lower_bound, upper_bound)
current_energy = objective_function(current_solution)

while T > 1e-8 and iterations > 0:
    # 产生新的候选解
    new_solution = current_solution + random.uniform(-0.1, 0.1) * T
    new_solution = max(min(new_solution, upper_bound), lower_bound)
    new_energy = objective_function(new_solution)
    delta_energy = new_energy - current_energy
    if delta_energy < 0 or random.random() < math.exp(-delta_energy / T):
        current_solution = new_solution
        current_energy = new_energy
    # 降低温度
    T *= alpha
    iterations -= 1

print("最终解:", current_solution)
print("最终目标函数值:", objective_function(current_solution))
