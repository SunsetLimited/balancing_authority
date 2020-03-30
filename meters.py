##creating the meters objects in python in anticipating of a market simulation

class meter(): #foundational object, each other type will branch from this
    def __init__(self, capacity):
        self.capacity = capacity
        self.bidPrice = 0.0
        self.bidQuantity = capacity
    def bid(self, bidPrice, bidQuantity):
        self.bidPrice = bidPrice
        if bidQuantity > self.capacity:
            self.bidQuantity = self.capacity ##obviously, can't buy beyond meter capacity
        else:
            self.bidQuantity = bidQuantity

class genMeter(meter):
    def _init_(self, capacity, technology):
        self.technology = technology
        meter.__init__(self, name)



class generation():
    def _init_(self, capacity,  technology, ):