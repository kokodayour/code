def partition(s: str) -> list[list[str]]:
    n = len(s)
    ans = []
    subs = []

    def dfs(comma, start):
        """
        Args:
            comma: the index of comma
            start: the index of first elem of 回文串
        """
        if comma == n:
            ans.append(subs.copy())
            return
        # not select
        # if comma < n-1:
        dfs(comma+1, start)
        # select
        substring = s[start: comma+1]
        if substring == substring[::-1]:
            subs.append(substring)
            dfs(comma+1, comma+1)
            subs.pop()
        
    dfs(0, 0)
    return ans

partition('aab')