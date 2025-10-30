def generateParenthesis(n: int) -> list[str]:
    ans = []
    left = right = n
    # judge whether it is correct
    st = []
    # store result
    path = []
    
    # 将括号i压入栈中
    def dfs(i):
        nonlocal left, right
        if (left == 0) & (right == 0):
            ans.append(''.join(path.copy()))
            return
        if i == 'left':
            if left == 0:
                return
            st.append(0)
            path.append('(')
            left -= 1
        else:
            # if it is empty, it has no matched 左括号 in the path
            if not st:
                return False
            else:
                st.pop()
                path.append(')')
                right -= 1
        if left:
            dfs('left')
            st.pop()
            path.pop()
            left += 1
        dfs('right')
        st.append(0)
        path.pop()
        right += 1
    
    dfs('left')
    return ans

generateParenthesis(2)