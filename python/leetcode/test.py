def permute(nums):
    n = len(nums)
    ans = []
    path = [0]*n
    def dfs(i, s):
        if i == n:
            ans.append(path.copy())
            return
        for x in s:
            path[i] = x
            dfs(i+1, s-{x})
    dfs(0, set(nums))
    return ans

nums = [1,2,3]
permute(nums)