def partition(nums, left, right):
    """哨兵划分"""
    # 以nums[left]为基准数
    i, j = left, right
    while i<j:
        while i<j and nums[left]:
            j -= 1 # 从右向左找首个小于基准数的元素
        while i <j and nums[i]<=nums[left]:
            i += 1 # 从左向右找首个大于基准数的元素
        # 元素交换
        nums[i], nums[j] = nums[j], nums[i]
    # 将基准数交换至两子数组的分界线
    nums[i], nums[left] = nums[left], nums[i]

def quick_sort(nums, left, right):
    """快速排序"""
    if left >= right:
        return
    # 哨兵划分
    pivot = partition(nums,left,right)
    quick_sort(nums, left, pivot-1)
    quick_sort(nums, pivot+1, right)