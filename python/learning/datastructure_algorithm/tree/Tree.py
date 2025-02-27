from collections import deque
class TreeNode:
    """二叉树节点类"""
    def __init__(self, val:int):
        self.val:int = val
        self.left:TreeNode|None = None
        self.right:TreeNode|None = None

    # 层序遍历 广度优先
    def level_order(self) -> list[int]:
        # 初始化队列 加入根节点
        queue: deque[TreeNode] = deque()
        queue.append(self)
        # 初始化一个队列 用于保存遍历序列
        res = []
        while queue:
            node: TreeNode = queue.popleft() # 从左侧移除一个元素并返回
            res.append(node.val)
            if node.left is not None:
                queue.append(node.left)
            if node.right is not None:
                queue.append(node.right)
        return res

    # 前序遍历: 根节点 -> 左子树 -> 右子树
    def preorder_traversal(self):
        result = []
        def helper(node):
            if node:
                result.append(node.val)
                helper(node.left)
                helper(node.right)
        helper(self)
        return result

    # 中序遍历: 左子树 -> 中节点 -> 右子树
    def preorder_traversal(self):
        result = []
        def helper(node):
            if node:
                helper(node.left)
                result.append(node.val)
                helper(node.right)
        helper(self)
        return result

    # 后序遍历: 左子树 -> 右子树 -> 中节点
    def preorder_traversal(self):
        result = []
        def helper(node):
            if node:  
                helper(node.left)  
                helper(node.right)
                result.append(node.val)
        helper(self)
        return result

# 根节点: 位于二叉树顶层的节点 没有父节点
# 叶节点: 没有子节点的节点 其它两个指针均指向None
# 边: 连接两个节点的线段
# 节点的层: 从顶至底递增 根节点所在层为1
# 节点的度: 节点的子节点的数量
# 节点的深度: 从根节点到该节点所进过的边的数量
# 节点的高度: 从距离该节点最远的叶节点到该节点所经过的边的数量
# 二叉树的高度: 从根节点到最远叶节点所结果的边的数量

# 完美(满)二叉树: 所有层的节点被完全填满 叶节点的度为0
# 完全二叉树: 只有最底层的节点没被填满 且叶节点从左往右填充
# 完满二叉树: 除了叶节点 其它节点都有两个节点
# 平衡二叉树: 任意节点的左子树和右子树的高度之差的绝对值不超过1

# 初始化二叉树
# 初始化节点
n1 = TreeNode(val=1)
n2 = TreeNode(val=2)
n3 = TreeNode(val=3)
n4 = TreeNode(val=4)
n5 = TreeNode(val=5)
# 构建节点之间的引用
n1.left = n2
n1.right = n3
n2.left = n4
n2.right = n5

# 插入与删除节点
p = TreeNode(0)
n1.left = p
p.left = n2
# 删除节点p
n1.left = n2