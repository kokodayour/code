from itertools import accumulate
def maxSubArray(nums: list[int]) -> int:
    pre_sum = list(accumulate(nums, initial=0))
    ptr = 0
    min_val = pre_sum[ptr]
    n = len(pre_sum)
    ans = pre_sum[1]
    while ptr < n-1:
        while nums[ptr+1] > nums[ptr] and ptr < n-1:
            ptr+=1
        ans = max(nums[ptr] - min_val, ans)
        ptr += 1
        min_val = nums[ptr]
    return ans

# nums = [5,4,-1,7,8]
nums = [-2,1,-3,4,-1,2,1,-5,4]
maxSubArray(nums)