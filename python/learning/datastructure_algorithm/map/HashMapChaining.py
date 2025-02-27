class HashMapChaining:
    """链式地址哈希表"""

    def __init__(self):
        """构造方式"""
        self.size = 0 # 键值对数量
        self.capacity = 4 # 哈希表容量
        self.load_thres = 2.0/3.0 # 触发扩容的负载因子阈值
        self.extend_ratio = 2 # 扩容倍数
        self.buckets = [[] for _ in range(self.capacity)]

    def hash_func(self, key:int):
        """哈希函数"""
        return key % self.capacity
    
    def load_factor(self):
        """负载因子"""
        return self.size / self.capacity
    
    def get(self, key):
        """查询操作"""
        index = self.hash_func(key)
        bucket = self.buckets[index]
        # 遍历桶 若找到key 则返回对于val
        for pair in bucket:
            if pair.key == key:
                return pair.val
        # 若未找到key 则返回None
        return None
    
    def put(self, key, val):
        """添加操作"""
        # 当负载因子超过阈值时 执行扩容
        if self.load_factor() > self.load_thres:
            self.extend()
        index = self.hash_func(key)
        bucket = self.buckets[index]
        # 遍历桶 若遇到指定key 则更新对应val并返回
        for pair in bucket:
            if pair.key == key:
                return
        pair = (key, val)
        bucket.append(pair)
        self.size += 1
    
    def remove(self, key):
        """删除操作"""
        index = self.hash_func(key)
        bucket = self.buckets[index]
        for pair in bucket:
            if pair.key == key:
                bucket.remove(pair)
                self.size -= 1
                break

    def extend(self):
        """扩容哈希表"""
        # 暂存原哈希表
        buckets = self.buckets
        # 初始化扩容后的新哈希表
        self.capacity *= self.extend_ratio
        self.buckets = [[] for _ in range(self.capacity)]
        self.size = 0
        # 将键值对从原哈希表搬运至新哈希表
        for bucket in buckets:
            for pair in bucket:
                self.put(pair.key, pair.val)
