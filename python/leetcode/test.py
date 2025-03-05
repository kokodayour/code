def longestConsecutive(nums: list[int]) -> int:
    nums = set(sorted(nums))
    ans = temp = 1
    for x in nums:
        if x+1 not in nums:
            ans = max(ans, temp)
            temp = 1
        else:
            temp += 1
    return 0 if nums == set() else ans

nums = [0,3,7,2,5,8,4,6,0,1]
nums = [0,-1]
longestConsecutive(nums)
