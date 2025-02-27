from collections import defaultdict
def smallestRange(nums: list[list[int]]) -> list[int]:
    # 记录每个值对应的列表索引
    interval_freq = defaultdict(list)
    for id, i in enumerate(nums):
        for ii in i:
            interval_freq[ii].append(id)

    # 将所有唯一值排序
    a = sorted(interval_freq.keys())
    n = len(nums)
    ans = [0, float('inf')]
    left = 0
    # 记录当前区间中每个列表的出现次数
    freq = defaultdict(int)
    for right in a:
        # 将当前值对应的列表索引加入频率统计
        for idx in interval_freq[right]:
            freq[idx] += 1

        while len(freq) == n and left <= right:
            # 更新最小区间
            if right - a[left] < ans[1] - ans[0]:
                ans = [a[left], right]

            # 移动左边界
            for idx in interval_freq[a[left]]:
                freq[idx] -= 1
                if freq[idx] == 0:
                    del freq[idx]
            left += 1

    return ans

nums = [[-5,-4,-3,-2,-1],[1,2,3,4,5]]
smallestRange(nums)
