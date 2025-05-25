def calculate(s):
    nums, ops = [0], []
    lookup = {
        '+': lambda x1, x2: x1 + x2,
        '-': lambda x1, x2: x1 - x2
    }

    def calc():
        b = nums.pop()
        a = nums.pop()
        op = ops.pop()
        nums.append(lookup[op](a, b))

    s = s.replace(' ', '')
    i, n = 0, len(s)
    while i < n:
        x = s[i]
        if x == '(':
            ops.append(x)
        # 处理多位数
        elif x.isdigit():
            u, j = 0, i
            while j < n and s[j].isdigit():
                u = u * 10 + int(s[j])
                j += 1
            nums.append(u)
            i = j - 1
        elif x in ['+', '-']:
            if i > 0 and s[i - 1] == '(':
                nums.append(0)
            while ops and ops[-1] != '(':
                calc()
            ops.append(x)
        # 右括号
        else:
            while ops and ops[-1] != '(':
                calc()
            if ops:
                ops.pop()
        i += 1
    while ops:
        calc()
    return nums.pop()


s = "2 + (1+1) +1"
calculate(s)
