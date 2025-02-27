# 堆是一种满足特定条件的完全二叉树 分为大顶堆和小顶堆
# 小顶堆: 任意节点的值<=其子节点的值
# 大顶堆: 任意节点的值>=其子节点的值
import heapq
class MaxHeap:
    def __init__(self, nums:list[int]):
        # 1.从第一个非叶节点开始 从上至下堆化
        # 2.反序遍历节点 因为后续的节点已经完成了堆化
        # 时间复杂度O(n)
        self.max_heap = nums
        for i in range(self.parent(self.size()-1),-1,-1):
            self.sift_down(i)
    
    # 获取左子节点的索引
    def left(self, i:int) -> int:
        return 2*i+1
    
    # 获取右子节点的索引
    def right(self, i:int) -> int:
        return 2*i+2
    
    # 获取父节点的索引
    def parent(self, i:int) -> int:
        return (i-1)//2
    
    def swap(self, i:int, j:int):
        """交换元素"""
        self.max_heap[i], self.max_heap[j] = self.max_heap[j], self.max_heap[i]
    
    def peek(self) -> int:
        """访问堆顶元素"""
        return self.max_heap[0]
    
    def size(self) -> int:
        """获取堆大小"""
        return len(self.max_heap)
    
    def push(self, val:int):
        """元素入堆"""
        self.sift_up(self.size()-1)

    def sift_up(self, i:int):
        """从节点i开始 从低至顶堆化"""
        while True:
            # 获取节点i的父节点
            p = self.parent(i)
            # 当"越过根节点"或"节点无需修复"时 结束堆化
            if p < 0 or self.max_heap[i] <= self.max_heap[p]:
                break
            # 交换两节点
            self.swap(i,p)
            # 循环向上堆化
            i = p
    
    def pop(self) -> int:
        """元素出堆"""
        # 1.交换堆顶和堆底元素
        self.swap(0, self.size()-1)
        # 2.删除堆底元素
        val = self.max_heap.pop()
        # 3.从顶至底进行堆化
        self.sift_down(0)
        return val
    
    def sift_down(self, i:int):
        """从节点i开始 从顶至底堆化"""
        while True:
            # 判断节点i j r中值最大的节点 记为ma
            l, r, ma = self.left(i), self.right(i), i
            if l < self.size() and self.max_heap[l] > self.max_heap[ma]:
                ma = l
            if r < self.size() and self.max_heap[r] > self.max_heap[ma]:
                ma = r
            if ma == i:
                break
            self.swap(i, ma)
            # 循环向下堆化
            i = ma


# TOP-K问题 给定一个长度为n的无序数组nums 请返回数组中最大的k个元素
# 可以使用排序 时间复杂度O(nlogn)
def top_k_heap(nums:list[int], k:int) -> list[int]:
    heap = []
    for i in range(k):
        heapq.heappush(heap, nums[i])
    for i in range(k, len(nums)):
        # 若当前元素大于堆顶元素 则将堆顶元素出堆 当前元素入堆 剩下的就是最大的k个元素
        # 时间复杂度O(nlogk)
        if nums[i] > heap[0]:
            heapq.heappop(heap)
            heapq.heappush(heap, nums[i])
    return heap
