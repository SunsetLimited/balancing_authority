import pandas as pd
import numpy as np
import calendar as cal
#using the objectins in meters.py, this creates an auction simulation
#Purpose: determine battery cost necessary for autuarky given market conditions

#input: ecosystem of meters
    #create meters (loop through, function should generate meters and capacity within random parameters)
    #solar shape, load patterns
    #initiating bids and offers (bids from load meters, offers from gen meters)
        #offerss will be set at the LCOE
        #wholesale prices will be based on EIA forecasts
        #gen shape from the EIA
        #battery efficiency can come from the Lazard, EIA, etc
    #use affiliances to track sub-markets
#operations: balancing, creating clearing price
    #sort bids and offers within relevant markets
    #create clearing price, update ledger to reflect payments/receipts
        #ledger: separate object, likely within a dataframe (reflect .sol potentiality)
    #benchmark clearing price within a market against the index of pure wholesale prices
#output
    #total systemwide savings/loss vs index, over time
    #net position of gen/load vs LCOE
    #report output by autark-affiliance, and by gen project

#create lots of meters

#need to get this hourly data
    ##solar data
    #power price data
    #power usage data
    #

def mintMeter(quantity, meanCapacity = 10, stdCapacity = 3):
    for i in np.arange(0, quantity):
        varName = 'm' + str(i)
        capacity =np.random.normal( meanCapacity, stdCapacity, 1)[0]
        print(capacity)
        globals()[varName] = meter(capacity)


monthDict = {}
for month in np.arange(1,13):
    monthDict[cal.month_abbr[month]] = pd.Period(cal.month_abbr[month]).days_in_month

monthSeries = pd.Series()
daySeries = pd.Series()
hourSeries = pd.Series()

for month in monthDict.keys():
    for day in np.arange(1,monthDict[month] + 1):
        for hour in np.arange(0, 24):
            monthSeries = monthSeries.append(pd.Series([month]))
            daySeries = daySeries.append(pd.Series([day]))
            hourSeries = hourSeries.append(pd.Series([hour]))


ledger = pd.DataFrame({'month':monthSeries, 'day':daySeries, 'hour':hourSeries})

