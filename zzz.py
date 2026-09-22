def subsetWithDup(nums):
    ans = [[]]
    temp = []
    n = len(nums)
    def dfs(i, nums):
        if i<n:
            for x in nums:
                temp.append(x)
                ans.append(temp.copy())
                nums.remove(x)
                dfs(i+1, nums)
                nums.append(x)
    dfs(0, nums)
    return ans
subsetWithDup([1,2,2])