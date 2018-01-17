pragma solidity ^0.4.0;

///meters are associated with accounts
contract MeteredAccount {

    struct Meter {
        bool export; ///determines if meter is net load or generation
        uint powerFlow; ///net power flow in or out of the meter, determined by export variable
    }

    Meter meter; ///declaring the meter for the account

    function setMeter(bool _export, uint _powerFlow) internal {
        meter.export = _export;
        meter.powerFlow = _powerFlow;
                    } ///function set by the actual account meter

    struct MarketDay {
        uint year;
        uint month;
        uint day;
        } ///designation of the market day for which the offers are made

    struct DayAheadBid {
        uint[] quantities;///array of hourly load forecast, hour-beginning convention for indexing
        MarketDay day; ///the day for which the offers are made
        }///define the datatype for a day ahead bid to purchase power from the metered account
            ///generally, load accounts are price takers, though they may choose to curtail in the real-time

    DayAheadBid dayAheadBid;///declare the day ahead bid variable

    function _setDayAheadBid(uint[], _quantities, uint[] _prices, MarketDay _day) internal{
        dayAheadBid.quantities = _quantities;
        dayAheadBid.prices = _prices;
        dayAhead.dayAhead = _day;
    }///function to make a bid that becomes readable by the balancing authority

    function readDayAheadBid external returns(DayAheadBid){
        return dayAheadBid;
    }///external function to allow the balancing authority to read the day-ahead bid from the load account

}

contract GenMeter is MeteredAccount {

    struct DayAheadOffer {
        uint[] quantities;///array of hourly generation quantities offered, hour-beginning convention for indexing
        uint[] prices;  ///array of offered prices corresponding to the 'quantities' array
        MarketDay day; ///the day for which the offers are made
        }///defines the datatype for a day ahead offer to sell power from the metered account

    DayAheadOffer dayAheadOffer; ///declares the day-ahead offer variable

    function _setDayAheadOffer(uint[], _quantities, uint[] _prices, MarketDay _day) internal{
        dayAheadOffer.quantities = _quantities;
        dayAheadOffer.prices = _prices;
        dayAheadOffer.day = _day;
    }///function to make an offer that becomes readable by the balancing authority

    ///GenMeter can make load offers

}

