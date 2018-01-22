pragma solidity ^0.4.0;

///meters are associated with specific addresses on the blockchain virtual machine
contract MeteredAccount {

    struct Meter { ///receives real-time updates from the physical meter
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

//code below is validated in Remix
contract Meter{
    uint load; //current power usage

    uint maxLoad; //(kW)maximum capacity of the meter
    bool gen; //indicates whether or not the meter has associated generation
    uint nameplate; //(kW)nameplate capacity of the generation associated with the meter
    uint storageCapacity; //(kWh)total storage capacity associated with the meter

    function setMeter(uint _load) {
        load = _load;
    } //function for the physical meter to record instantaneous power usage


    function readMeter() public view returns(uint){
        return(load);
    } //function for balancing authority or other external contracts to read the current load

    function getMeterSpecs() public view returns(uint, bool, uint, uint){
        return (maxLoad, gen, nameplate, storageCapacity);
    } //function for balancing authority to get meter specs to populate the account

    struct MarketDay {
        uint year;
        uint month;
        uint day;
        } ///designation of the market day for which the offers are made

    struct DayAheadBid {
        uint[3] quantities;///array of hourly load forecast, hour-beginning convention for indexing
        MarketDay marketDay; ///the day for which the offers are made
        }///define the datatype for a day ahead bid to purchase power from the metered account
            ///generally, load accounts are price takers, though they may choose to curtail in the real-time

    DayAheadBid dayAheadBid;///declare the day-ahead bids

    function _setDayAheadBid(uint[3] _quantities, uint _year, uint _month, uint _day) {
        dayAheadBid.quantities = _quantities;
        dayAheadBid.marketDay.year = _year;
        dayAheadBid.marketDay.month = _month;
        dayAheadBid.marketDay.day = _day;
    }///function to make a bid that becomes readable by the balancing authority

    function readDayAheadBid() external returns(uint[3], uint, uint, uint){
        return (dayAheadBid.quantities, dayAheadBid.marketDay.year, dayAheadBid.marketDay.month, dayAheadBid.marketDay.day);
    }///external function to allow the balancing authority to read the day-ahead bid from the load account

}

contract GenMeter is Meter{
    uint generation; //the instantaneous generation, set by the physical meter
    bool gen = true;

    function _setGenSpecs(uint _nameplate, uint _storageCapacity){
        nameplate = _nameplate;
        storageCapacity = _storageCapacity;
    }

    function getMeterSpecs() public view returns(uint, bool, uint, uint){
        return (maxLoad, gen, nameplate, storageCapacity);
    } //need to add this function, supersedes the previous, incorporates new variables

    function setGen(uint _generation) {
        generation = _generation;
    } //function for the physical meter to record instantaneous power usage


    function readGen() public view returns(uint){
        return(generation);
    } //function for balancing authority or other external contracts to read the current load

    struct DayAheadOffer {
        uint price; //($/kWh) price at which the generation is offered
        uint[3] quantities;//(kWh)array of hourly generation offer, hour-beginning convention for indexing
        MarketDay marketDay; ///the day for which the offers are made
        }///define the datatype for a day ahead offer to sell power

    DayAheadOffer dayAheadOffer; //declare the day-ahead offers

    function _setDayAheadOffer(uint _price, uint[3] _quantities, uint _year, uint _month, uint _day) {
        dayAheadOffer.price = _price;
        dayAheadOffer.quantities = _quantities;
        dayAheadOffer.marketDay.year = _year;
        dayAheadOffer.marketDay.month = _month;
        dayAheadOffer.marketDay.day = _day;
    }///function to make an offer that becomes readable by the balancing authority

    function readDayAheadOffer() external returns(uint, uint[3], uint, uint, uint){
        return (dayAheadOffer.price, dayAheadOffer.quantities, dayAheadOffer.marketDay.year, dayAheadOffer.marketDay.month, dayAheadOffer.marketDay.day);
    }///external function to allow the balancing authority to read the day-ahead bid from the load account

}