class Shape():
    
    def draw(self):
        raise NotImplementedError

class Circle(Shape):

    def draw(self):
        print('draw Circle')

class Rectangle(Shape):

    def draw(self):
        print('draw Rectangle')

class ShapeFactory(object):

    def create(self, shape):
        if shape == 'Circle':
            return Circle()
        elif shape == 'Rectangle':
            return Rectangle()
        else:
            raise ValueError("None")

factory = ShapeFactory()
obj = factory.create('Circle')
obj.draw()