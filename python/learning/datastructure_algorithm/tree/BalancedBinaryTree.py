# 平衡二叉搜索树 也称AVL树
class TreeNode:
    def __init__(self, key):
        self.key = key
        self.left = None
        self.right = None
        self.height = 1  # 节点高度

class AVLTree:
    def get_height(self, node):
        if not node:
            return 0
        return node.height

    def get_balance(self, node):
        if not node:
            return 0
        return self.get_height(node.left) - self.get_height(node.right)

    def left_rotate(self, z):
        y = z.right
        T2 = y.left

        # 旋转
        y.left = z
        z.right = T2

        # 更新高度
        z.height = 1 + max(self.get_height(z.left), self.get_height(z.right))
        y.height = 1 + max(self.get_height(y.left), self.get_height(y.right))

        return y

    def right_rotate(self, z):
        y = z.left
        T3 = y.right

        # 旋转
        y.right = z
        z.left = T3

        # 更新高度
        z.height = 1 + max(self.get_height(z.left), self.get_height(z.right))
        y.height = 1 + max(self.get_height(y.left), self.get_height(y.right))

        return y

    def insert(self, root, key):
        # 1. 标准 BST 插入
        if not root:
            return TreeNode(key)
        elif key < root.key:
            root.left = self.insert(root.left, key)
        else:
            root.right = self.insert(root.right, key)

        # 2. 更新高度
        root.height = 1 + max(self.get_height(root.left), self.get_height(root.right))

        # 3. 获取平衡因子
        balance = self.get_balance(root)

        # 4. 如果不平衡，进行旋转
        # 左左情况
        if balance > 1 and key < root.left.key:
            return self.right_rotate(root)
        # 右右情况
        if balance < -1 and key > root.right.key:
            return self.left_rotate(root)
        # 左右情况
        if balance > 1 and key > root.left.key:
            root.left = self.left_rotate(root.left)
            return self.right_rotate(root)
        # 右左情况
        if balance < -1 and key < root.right.key:
            root.right = self.right_rotate(root.right)
            return self.left_rotate(root)

        return root

    def pre_order(self, root):
        if not root:
            return
        print("{0} ".format(root.key), end="")
        self.pre_order(root.left)
        self.pre_order(root.right)

# 示例用法
avl_tree = AVLTree()
root = None
keys = [10, 20, 30, 40, 50, 25]

for key in keys:
    root = avl_tree.insert(root, key)

print("前序遍历结果:")
avl_tree.pre_order(root)