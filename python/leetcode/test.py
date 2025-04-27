def subarraySum(nums: list[int], k: int) -> int:
    L = R = ans = 0
    n = len(nums)
    temp = nums[0]
    while L < n:
        if temp < k:
            R += 1
            temp += nums[R]
        elif temp > k:
            temp -= nums[L]
            L += 1
            if L > R:
                R = L
        else:
            ans += 1
    return ans

nums = [1,2,3]
k = 3
subarraySum(nums, k)
