#using the objectins in meters.py, this creates an auction simulation
#Purpose: determine battery cost necessary for autuarky given market conditions

#input: ecosystem of meters
    #create meters (loop through, function should generate meters and capacity within random parameters)
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
