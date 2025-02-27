# 类似于插扑克 把下一张牌(nums[i])依次与前面已经排好序的牌(nums[j])比较
# 如果比它小 则将下一张牌拿出(pop[i]) 并插入到(insert)j的位置 后面的牌自动退一格
def insert_sort(nums: list[int]) -> list[int]:
    for i in range(len(nums)):
        for j in range(i):
            if nums[i] < nums[j]:
                # pop会返回第i个元素 同时insert插入时会把所有的元素往后挪一位
                nums.insert(j, nums.pop(i))
                # 插入之后后续的数就不用再比了
                break
    return nums

a = [12, 3, 4, 1, 2, 3, 12, 3, 5, 8]
print(insert_sort(a))
