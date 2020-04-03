##creating the meters objects in python in anticipating of a market simulation

class meter(): #foundational object, each other type will branch from this
    def __init__(self, capacity): #most basic data for a meter: max capacity for kW flow
        self.capacity = capacity
        self.bidPrice = 0.0
        self.bidQuantity = capacity
    def bid(self, bidPrice, bidQuantity):#all meters can purchase power
        self.bidPrice = bidPrice
        if bidQuantity > self.capacity:
            self.bidQuantity = self.capacity ##obviously, can't buy beyond meter capacity
        else:
            self.bidQuantity = bidQuantity


class genMeter(meter):
    def __init__(self, capacity, technology, genCapacity): #defining the generation behind the meter
        self.technology = technology
        meter.__init__(self, capacity)
        if genCapacity > self.capacity:
            self.genCapacity = capacity
        else:
            self.genCapacity = genCapacity
    def offer(self, offerPrice, offerQuantity):
        self.offerPrice = offerPrice
        if offerQuantity > self.genCapacity:
            self.offerQuantity = self.genCapacity
        else:
            self.offerQuantity = offerQuantity

class storageMeter(meter):
    def __init__(self, capacity,storageCapacity, duration, efficiency):
        self.technology = 'storage'
        self.capacity = capacity
        self.duration = duration
        self.storageCapacity = storageCapacity
        if storageCapacity > self.capacity:
            self.storageCapacity = self.capacity
        else:
            self.storageCapacity = storageCapacity
        self.maxCharge = self.storageCapacity * self.duration
        if (efficiency >1)|(efficiency < 0):
            self.efficiency = .85
        else:
            self.efficiency = efficiency
