class TreeNode:
    def __init__(self, key):
        self.left = None
        self.right = None
        self.val = key

# 插入操作logn
def insert(root, key):
    if root is None:
        return TreeNode(key)
    else:
        if root.val < key:
            root.right = insert(root.right, key)
        else:
            root.left = insert(root.left, key)
    return root

# 查找操作logn
def search(root, key):
    if root is None or root.val == key:
        return root
    if root.val < key:
        return search(root.right, key)
    return search(root.left, key)

# 删除操作
def delete(root, key):
    if root is None:
        return root
    if key < root.val:
        root.left = delete(root.left, key)
    elif key > root.val:
        root.right = delete(root.right, key)
    else:
        if root.left is None:
            return root.right
        elif root.right is None:
            return root.left
        temp = find_min(root.right)
        root.val = temp.val
        root.right = delete(root.right, temp.val)
    return root

# 找到最小值
def find_min(node):
    current = node
    while current.left is not None:
        current = current.left
    return current

# 示例用法
root = None
root = insert(root, 50)
insert(root, 30)
insert(root, 20)
insert(root, 40)
insert(root, 70)
insert(root, 60)
insert(root, 80)

# 查找节点
result = search(root, 40)
if result:
    print("找到节点:", result.val)
else:
    print("未找到节点")

# 删除节点
root = delete(root, 20)