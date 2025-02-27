class Man(object):
    """示例类"""

    def __init__(self, name):
        self.name = name
        print("Initialized!")

    def hello(self):
        print(f"Hello {self.name}!")

    def goodbye(self):
        print("Goodbye "+self.name+"!")

m = Man("David")
m.hello()
m.goodbye()