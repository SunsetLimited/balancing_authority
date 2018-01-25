pragma solidity ^0.4.0;

contract Meter{
 ///0: DEFINE BASIC VARIABLES AND FUNCTIONS OF A LOAD-ONLY METER
    ///0(a): Setting load and defining meter specs

    int load; //current power usage
    uint maxLoad; //(kW)maximum capacity of the meter
    bool gen = false; //indicates whether or not the meter has associated generation


    function _setMeterSpecs(uint _maxLoad){
        maxLoad = _maxLoad;
    } //meter owner sets its maximum power usage

    function setLoad(int _load) {
        load = _load;
    } //function for the physical meter to record instantaneous power usage

  ///0(b) functions for reading basic load data from the meter
    function getMeterSpecs() public view returns(uint, bool, uint, uint){
        return (maxLoad, gen, 0, 0);
    } //allows Balancing Authority to call information on the load meter; returns 0 for generation specs

    function readMeter() public view returns(int){
        return(load);
    } //function for balancing authority or other external contracts to read the current load

    ///1: MARKET FUNCTIONS
        //1(a)setting hour-ahead bids

    int hourAheadBidQuantity;///array of hourly load forecast, hour-beginning convention for indexing
    uint hourAheadBidYear;
    uint hourAheadBidMonth;
    uint hourAheadBidDay;
    uint hourAheadBidHour;
        //define the variables for a day ahead bid to purchase power from the metered account
            ///generally, load accounts are price takers, though they may choose to curtail in the real-time



    function _setHourAheadBid(int _quantity, uint _year, uint _month, uint _day, uint _hour) {
        hourAheadBidQuantity = _quantity;
        hourAheadBidYear = _year;
        hourAheadBidMonth = _month;
        hourAheadBidDay = _day;
        hourAheadBidHour = _hour;
    }///function to make a bid that becomes readable by the balancing authority

    //1(b) allowing balancing authority to read the hour-ahead bid

    function readHourAheadBid() external returns(int, uint, uint, uint, uint){
        return (hourAheadBidQuantity, hourAheadBidYear, hourAheadBidMonth, hourAheadBidDay, hourAheadBidHour);
    }///external function to allow the balancing authority to read the day-ahead bid from the load account

}
///2: GENERATION METER
contract GenMeter is Meter{
    //2(a) defining the basic variables and inputfunctions of a generation meter
    int generation; //the instantaneous generation, set by the physical meter
    bool gen = true;
    uint nameplate; //(kW)nameplate capacity of the generation associated with the meter
    uint storageCapacity; //(kWh)maximum storage capacity associated with the meter
    uint availableStorage; //(kWh) currently available storage

    function _setMeterSpecs(uint _maxLoad, uint _nameplate, uint _storageCapacity){//establishing distributed generation specifications
        maxLoad = _maxLoad;
        nameplate = _nameplate;
        storageCapacity = _storageCapacity;
    }

    function setGeneration(int _generation) {
        generation = _generation;
    } //function for the physical meter to record instantaneous power usage

    //2(b) functions to allow balancing authority to read meter data
    function getMeterSpecs() public view returns(uint, bool, uint, uint){
        return (maxLoad, gen, nameplate, storageCapacity);
    }

    function readGen() public view returns(int){
        return(generation);
    } //function for balancing authority or other external contracts to read the current load

    //3: GENERATION MARKET ACTIVITIES
    //3(a) functions to interact with the balancing authority and make offers into the day-ahead market

        uint hourAheadOfferPrice; //($/kWh) price at which the generation is offered
        int hourAheadOfferQuantity;//(kWh)array of hourly generation offer, hour-beginning convention for indexing
        uint hourAheadOfferYear;
        uint hourAheadOfferMonth;
        uint hourAheadOfferDay;
        uint hourAheadOfferHour;
        ///define the variables for a day ahead offer to sell power


    function _setHourAheadOffer(uint _price, int _quantity, uint _year, uint _month, uint _day, uint _hour) {
        hourAheadOfferPrice = _price;
        hourAheadOfferQuantity = _quantity;
        hourAheadOfferYear = _year;
        hourAheadOfferMonth = _month;
        hourAheadOfferDay = _day;
        hourAheadOfferHour = _hour;
    }

    //3(b) Function to allow balancing authority to read offer data

    function readHourAheadOffer() external returns(uint, int, uint, uint, uint, uint){
        return (hourAheadOfferPrice, hourAheadOfferQuantity, hourAheadOfferYear, hourAheadOfferMonth, hourAheadOfferDay, hourAheadOfferHour);
    }///external function to allow the balancing authority to read the day-ahead bid from the load account

}
