# 每次在未排序序列中找到最小的元素放在序列的起始位置
def select_sort(nums: list[int]) -> list[int]:
    for i in range(len(nums) - 1):
        for j in range(i + 1, len(nums)):
            if nums[j] < nums[i]:
                nums[i], nums[j] = nums[j], nums[i]
    return nums

a = [12, 3, 4, 1, 2, 3, 12, 3, 5, 8]
print(select_sort(a))
