import random

# 种群大小
POPULATION_SIZE = 100
# 染色体长度(这里简单假设在一定范围的离散值，可根据实际精度需求调整)
CHROMOSOME_LENGTH = 10
# 基因取值范围(这里假设是0到1的离散值，可按需修改)
GENE_RANGE = [0, 1]
# 交叉概率
CROSSOVER_PROBABILITY = 0.8
# 变异概率
MUTATION_PROBABILITY = 0.1
# 最大迭代次数
MAX_GENERATIONS = 100


# 适应度函数(这里以简单的二次函数为例，可根据实际问题替换)
def fitness_function(chromosome):
    x = int("".join(map(str, chromosome)), 2) / (2 ** CHROMOSOME_LENGTH - 1) * (GENE_RANGE[1] - GENE_RANGE[0]) + \
        GENE_RANGE[0]
    return x ** 2


# 初始化种群
def initialize_population():
    population = []
    for _ in range(POPULATION_SIZE):
        chromosome = [random.randint(GENE_RANGE[0], GENE_RANGE[1]) for _ in range(CHROMOSOME_LENGTH)]
        population.append(chromosome)
    return population


# 选择操作(轮盘赌)
def selection(population):
    fitness_scores = [fitness_function(chromosome) for chromosome in population]
    total_fitness = sum(fitness_scores)
    probabilities = [score / total_fitness for score in fitness_scores]
    selected_population = []
    for _ in range(POPULATION_SIZE):
        r = random.random()
        cumulative_probability = 0
        for i in range(POPULATION_SIZE):
            cumulative_probability += probabilities[i]
            if cumulative_probability > r:
                selected_population.append(population[i])
                break
    return selected_population


# 交叉操作
def crossover(parent1, parent2):
    if random.random() < CROSSOVER_PROBABILITY:
        crossover_point = random.randint(1, CHROMOSOME_LENGTH - 1)
        child1 = parent1[:crossover_point] + parent2[crossover_point:]
        child2 = parent2[:crossover_point] + parent1[crossover_point:]
        return child1, child2
    return parent1, parent2


# 变异操作
def mutation(chromosome):
    for i in range(CHROMOSOME_LENGTH):
        if random.random() < MUTATION_PROBABILITY:
            chromosome[i] = 1 - chromosome[i]
    return chromosome


# 运行主函数
def genetic_algorithm():
    population = initialize_population()
    for generation in range(MAX_GENERATIONS):
        selected_population = selection(population)
        new_population = []
        for i in range(0, POPULATION_SIZE, 2):
            parent1 = selected_population[i]
            parent2 = selected_population[i + 1]
            child1, child2 = crossover(parent1, parent2)
            child1 = mutation(child1)
            child2 = mutation(child2)
            new_population.extend([child1, child2])
        population = new_population
    best_chromosome = max(population, key=fitness_function)
    best_fitness = fitness_function(best_chromosome)
    return best_chromosome, best_fitness


best_chromosome, best_fitness = genetic_algorithm()
print("最佳染色体:", best_chromosome)
print("最佳适应度:", best_fitness)
