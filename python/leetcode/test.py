# the sum of k numbers is n
def combinationSum3(k, n):
    ans = []
    path = [0]*k
    def dfs(i):
        if i == k:
            if sum(path) == n:
                ans.append(path.copy())
            return
        for x in range(i, 10):
            path[i] = x
            dfs(i+1)
    dfs(0)
    return ans

combinationSum3(2, 3)