import numpy as np
import random

# 粒子数量
num_particles = 30
# 问题维度
dim = 2
# 最大迭代次数
max_iterations = 100
# 惯性权重
omega = 0.5
# 个体学习因子
c1 = 1.5
# 社会学习因子
c2 = 1.5


# 目标函数
def objective_function(x):
    return x[0] ** 2 + x[1] ** 2


# 初始化粒子位置
particles_position = np.array([[random.uniform(-10, 10) for _ in range(dim)] for _ in range(num_particles)])
# 初始化粒子速度
particles_velocity = np.array([[random.uniform(-1, 1) for _ in range(dim)] for _ in range(num_particles)])
# 个体最优位置
personal_best_position = particles_position.copy()
# 个体最优值
personal_best_fitness = np.array([objective_function(pos) for pos in particles_position])
# 找到全局最优值对应的索引
global_best_index = np.argmin(personal_best_fitness)
# 全局最优位置
global_best_position = personal_best_position[global_best_index].copy()
# 全局最优值
global_best_fitness = personal_best_fitness[global_best_index]

for iteration in range(max_iterations):
    r1 = np.array([random.random() for _ in range(num_particles * dim)]).reshape(num_particles, dim)
    r2 = np.array([random.random() for _ in range(num_particles * dim)]).reshape(num_particles, dim)
    particles_velocity = omega * particles_velocity + c1 * r1 * (
                personal_best_position - particles_position) + c2 * r2 * (global_best_position - particles_position)
    # 更新粒子位置
    particles_position += particles_velocity
    # 计算新位置下的适应度值
    current_fitness = np.array([objective_function(pos) for pos in particles_position])
    # 更新个体最优位置和个体最优值
    update_indices = current_fitness < personal_best_fitness
    personal_best_position[update_indices] = particles_position[update_indices]
    personal_best_fitness[update_indices] = current_fitness[update_indices]
    # 更新全局最优位置和全局最优值
    global_best_index = np.argmin(personal_best_fitness)
    global_best_position = personal_best_position[global_best_index].copy()
    global_best_fitness = personal_best_fitness[global_best_index]

print("最终全局最优位置:", global_best_position)
print("最终全局最优值:", global_best_fitness)
