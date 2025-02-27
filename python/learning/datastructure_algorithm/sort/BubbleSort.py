
# 将后面的数与最前面的数比较 如果小的话则交换两个数的位置
# 这样可以保证每轮循环下来最前面的数都是后面数的最小值
# 在整个过程 最小值如同气泡一样浮出水面
def bubble_sort(nums: list[int]) -> list[int]:
    # 外层每循环一次都将最大的数沉到最下面 只需要循环n-1次
    # 内层循环只需要到n-i就行
    for i in range(1, n := len(nums)):
        for j in range(n - i):
            if nums[j] > nums[j + 1]:
                nums[j], nums[j + 1] = nums[j + 1], nums[j]
    return nums

a = [12, 3, 4, 1, 2, 3, 12, 3, 5, 8]
print(bubble_sort(a))
