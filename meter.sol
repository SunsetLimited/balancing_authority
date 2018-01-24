pragma solidity ^0.4.0;

contract Meter{
 ///0: DEFINE BASIC VARIABLES AND FUNCTIONS OF A LOAD-ONLY METER
    ///0(a): Setting load and defining meter specs

    uint load; //current power usage
    uint maxLoad; //(kW)maximum capacity of the meter
    bool gen = false; //indicates whether or not the meter has associated generation


    function _setMeterSpecs(uint _maxLoad){
        maxLoad = _maxLoad;
    } //meter owner sets its maximum power usage

    function setLoad(uint _load) {
        load = _load;
    } //function for the physical meter to record instantaneous power usage

  ///0(b) functions for reading basic load data from the meter
    function getMeterSpecs() public view returns(uint, bool, uint, uint){
        return (maxLoad, gen, 0, 0);
    } //allows Balancing Authority to call information on the load meter; returns 0 for generation specs

    function readMeter() public view returns(uint){
        return(load);
    } //function for balancing authority or other external contracts to read the current load

    ///1: MARKET FUNCTIONS
        //1(a)setting hour-ahead bids
    struct HourAheadBid {
        uint quantity;///array of hourly load forecast, hour-beginning convention for indexing
        uint year;
        uint month;
        uint day;
        uint hour;
        }//define the datatype for a day ahead bid to purchase power from the metered account
            ///generally, load accounts are price takers, though they may choose to curtail in the real-time

    HourAheadBid hourAheadBid;///declare the day-ahead bids

    function _setHourAheadBid(uint _quantity, uint _year, uint _month, uint _day, uint _hour) {
        hourAheadBid.quantity = _quantity;
        hourAheadBid.year = _year;
        hourAheadBid.month = _month;
        hourAheadBid.day = _day;
        hourAheadBid.hour - _hour;
    }///function to make a bid that becomes readable by the balancing authority

    //1(b) allowing balancing authority to read the hour-ahead bid

    function readHourAheadBid() external returns(uint, uint, uint, uint, uint){
        return (hourAheadBid.quantity, hourAheadBid.year, hourAheadBid.month, hourAheadBid.day, hourAheadBid.hour);
    }///external function to allow the balancing authority to read the day-ahead bid from the load account

}
///2: GENERATION METER
contract GenMeter is Meter{
    //2(a) defining the basic variables and inputfunctions of a generation meter
    uint generation; //the instantaneous generation, set by the physical meter
    bool gen = true;
    uint nameplate; //(kW)nameplate capacity of the generation associated with the meter
    uint storageCapacity; //(kWh)maximum storage capacity associated with the meter
    uint availableStorage; //(kWh) currently available storage

    function _setMeterSpecs(uint _maxLoad, uint _nameplate, uint _storageCapacity){//establishing distributed generation specifications
        maxLoad = _maxLoad;
        nameplate = _nameplate;
        storageCapacity = _storageCapacity;
    }

    function setGeneration(uint _generation) {
        generation = _generation;
    } //function for the physical meter to record instantaneous power usage

    //2(b) functions to allow balancing authority to read meter data
    function getMeterSpecs() public view returns(uint, bool, uint, uint){
        return (maxLoad, gen, nameplate, storageCapacity);
    }

    function readGen() public view returns(uint){
        return(generation);
    } //function for balancing authority or other external contracts to read the current load

    //3: GENERATION MARKET ACTIVITIES
    //3(a) functions to interact with the balancing authority and make offers into the day-ahead market
    struct HourAheadOffer {
        uint price; //($/kWh) price at which the generation is offered
        uint quantity;//(kWh)array of hourly generation offer, hour-beginning convention for indexing
        uint year;
        uint month;
        uint day;
        uint hour;
        }///define the datatype for a day ahead offer to sell power

    HourAheadOffer hourAheadOffer; //declare the day-ahead offers

    function _setHourAheadOffer(uint _price, uint _quantity, uint _year, uint _month, uint _day, uint _hour) {
        hourAheadOffer.price = _price;
        hourAheadOffer.quantity = _quantity;
        hourAheadOffer.year = _year;
        hourAheadOffer.month = _month;
        hourAheadOffer.day = _day;
        hourAheadOffer.hour = _hour;
    }

    //3(b) Function to allow balancing authority to read offer data

    function readHourAheadOffer() external returns(uint, uint, uint, uint, uint, uint){
        return (hourAheadOffer.price, hourAheadOffer.quantity, hourAheadOffer.year, hourAheadOffer.month, hourAheadOffer.day, hourAheadOffer.hour);
    }///external function to allow the balancing authority to read the day-ahead bid from the load account

}
