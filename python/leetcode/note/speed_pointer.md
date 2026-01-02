# 快慢指针

#### 背景: 使用两个速度不一的指针遍历数据 利用速度差揭示位置关系

- 判断链表是否有环
- 寻找环的入口点
- 寻找链表中点

#### 具体步骤:

1. 初始化快慢指针
2. 快指针一次移动两个节点 慢指针一次移动一个节点
3. 是否满足退出条件


#### 反思:

`fast and fast.next`的顺序不能错  
`is`的速度要快于`==`

#### 模板:

```python
slow = fast = head
while fast and fast.next:
    fast = fast.next.next
    slow = slow.next
    # 退出条件
    if fast is slow:
```

#### 题目

1. 141
2. 287
