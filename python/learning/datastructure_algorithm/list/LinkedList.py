from Node import Node

class LinkedList:

    def __init__(self) -> None:
        self.head = None

    def append(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = new_node
        else:
            current = self.head
            # determine whether the next element is empty and
            # insert it until it is empty
            while current.next:
                current = current.next
            current.next = new_node

    def display(self):
        current = self.head
        while current:
            print(current.data, end=" -> ")
            current = current.next
        print("None")

    def search(self, target):
        current = self.head
        while current:
            if current.data == target:
                return True
            current = current.next
        # raise ValueError("there is no target!")
        return False
    
    def delete(self, target):
        if not self.head:
            raise ValueError(f"{self} is an empty array")
        if self.head.data == target:
            self.head = self.head.next
            return

        current = self.head
        while current.next:
            if current.next.data == target:
                current.next = current.next.next
                return
            current = current.next

linked_list = LinkedList()
linked_list.append(123)
linked_list.display()
