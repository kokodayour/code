def longestPath(parent, s):
    ans = 0
    i = 0  # 节点编号
    n = len(parent)
    # 用于存放路径
    res = [(0, {s[0]})]
    while i < n:
        if not res:
            node, path = res.pop(0)
        else:
            break
        ans = len(path)
        # 找到所有node的子节点
        for x in parent[i + 1:]:
            if x == node:
                i += 1
                if s[i] not in path:
                    res.append((i, path | {s[i]}))
            else:
                break
    return ans
parent = [-1,0,0,1,1,2]
s = "abacbe"
longestPath(parent, s)