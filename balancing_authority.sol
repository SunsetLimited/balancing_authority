
    //real-time dispatch and true-up functions
        ///save day-ahead bids and offers, check against meter for each account, credit/debit based on real production

    //islanding function



contract SystemMeter is GenMeter{
    ///the system meter is a gen meter that can island
}



///0: ESTABLISH INTERFACES FOR BALANCING AUTHORITY TO DRAW DATA FROM METERS
contract MeterInterface {
function readMeter() external view returns(uint);
}

contract AddMeterInterface {
    function getMeterSpecs() external view returns(
    uint _maxLoad,
    bool _gen,
    uint _nameplate,
    uint _storageCapacity);
} //interface to add a meter to the system and record its specifications

contract HourAheadBidInterface{
    function readHourAheadBid() external view returns(
        uint quantity,
        uint year,
        uint month,
        uint day,
        uint hour);
} //interface to read the day ahead bid from a load meter

contract GenMeterInterface {
    function readGen() external view returns(uint);
}

contract HourAheadOfferInterface {
    function readHourAheadOffer() external view  returns(
        uint price,
        uint quantity,
        uint year,
        uint month,
        uint day,
        uint hour);
}

/// BALANCING AUTHORITY CONTRACT
contract BalancingAuthority{
   ///FOUNDATIONAL INTERFACES AND VARIABLES FOR INTERACTING WITH THE METERED POWER SYSTEM
    ///1(a): define variables and associated functions to interact with the above-defined interfaces
    mapping (uint => address) meterMap;
    mapping (uint => address) genMeterMap;

    struct MeteredAccount{
        address accountAddress; ///the location of the relevant meter contract on the blockchain
        uint maxLoad; ///maximum load of the account (watts)
        bool gen; /// true/false whether this is a generation account
        uint nameplate; ///the maximum generation output of the account (watts); 0 if gen = false
        uint storageCapacity; ///the maximum storage capacity of the account (watt-hours)
    }

    MeteredAccount[] systemAccounts;
    MeteredAccount[] generationAccounts;
    uint meterCount = 0;
    uint genMeterCount = 0;


    function addMeter(address _address)  { //core function to admit new meters to the balancing authority
         uint _maxLoad;
         bool _gen;
         uint _nameplate;
         uint _storageCapacity;
       AddMeterInterface meterAdder = AddMeterInterface(_address);
       (_maxLoad,_gen,_nameplate,_storageCapacity) = meterAdder.getMeterSpecs();
       uint _id = systemAccounts.push(MeteredAccount(_address, _maxLoad, _gen, _nameplate, _storageCapacity)) -1;
       meterMap[_id] = _address;
       meterCount++;
       if(_gen == true){ //setting a separate mapping of generation accounts for use in reading offers
           genMeterMap[genMeterCount] = _address;
           genMeterCount++;
       }

    }
//  1(b): functions to pull descriptive data about the current (instantaneous) state of the balancing authority system
    function getMeterCount() returns(uint){
        return meterCount;
    }   //returns total count of meters on the system

    function getGenMeterCount() returns(uint){
        return genMeterCount;
    }

    function _readMeter(address _address) returns (uint){
        MeterInterface meterReader = MeterInterface(_address);
        return meterReader.readMeter();
    } //returns the current load of a given meter

    function getSystemLoad() returns(uint) {
       uint _cumulativeLoad = 0;
       for(uint i = 0; i < meterCount; i++){
            _cumulativeLoad += _readMeter(systemAccounts[i].accountAddress);
       }
       return _cumulativeLoad;
    }


    ///Gen meter interaction functions

    function _readGen(address _address) returns(uint){ // reads instantaneous generation from a given meter
        GenMeterInterface genReader = GenMeterInterface(_address);
        return genReader.readGen();
    }

    function _getSystemGen() returns(uint){//returns the instantaneous generation within the control area
        uint _cumulativeGen = 0;
        for (uint i = 0; i < genMeterCount; i++){
            _cumulativeGen += _readGen(genMeterMap[i]);
        }
        return _cumulativeGen;
    }
  //2: MARKET CLEARING FUNCTIONS
    //2(a) functions to read bids for hour-ahead load

    function _readHourAheadBid(address _address) returns(uint, uint, uint, uint, uint){
        HourAheadBidInterface hourAheadBids = DayAheadBidInterface(_address);
        return hourAheadBids.hourDayAheadBid();
    }

    function getHourAheadBids(uint _year, uint _month, uint _day, uint _hour) returns(uint){
        uint memory _cumulativeBids;
        for(uint i = 0; i < meterCount; i++){
            uint _bidQuantity;
            uint _bidYear;
            uint _bidMonth;
            uint _bidDay;
            uint _bidHour;
            (_bidQuantity, _bidYear, _bidMonth, _bidDay, _bidHour) = _readDayAheadBid(systemAccounts[i].accountAddress);
            if(_bidYear == _year && _bidMonth == _month && _bidDay == _day && bidHour == _hour){
                    _cumulativeBids += _bidQuantity;
                }
                                    }
        return _cumulativeBids;
    }

    //2(b) functions to read hour-ahead offers
    function _readHourAheadOffer(address _address) returns (uint, uint, uint, uint, uint, uint){//reads hour-ahead offer from a given meter
        HourAheadOfferInterface hourAheadOffer = HourAheadOfferInterface(_address);
        return hourAheadOffer.readHourAheadOffer();
    }

    //2(c) Market clearing functions

    uint hourAheadLoad = getHourAheadBids(); //first step of auction clearing: set the hour-ahead load (power demand)

    address[] _validOffers; ///map of valid offers for the hour-ahead auction, to be deleted/reset after market clears

    function _setValidOffers(uint _year, uint _month, uint _day, uint _hour) {
            for(uint i = 0; i < genMeterCount; i++){
                uint _offerYear;
                uint _offerMonth;
                uint _offerDay;
                uint _offerHour;
                (,, _offerYear, _offerMonth, _offerDay, _offerHour) = _readHourAheadOffer(genMeterMap[i]);
                if(_offerYear == _year && _offerMonth == _month && _offerDay == _day && _offerHour == _hour){
                    _validOffers.push(genMeterMap[i]); //adds compliant offers to the current auction
            }
            }
            }

    function viewValidOffers() returns(address[]){
        return _validOffers;
    }


    function _getLowestAboveX(uint[] _array, uint _x) returns(uint){ //for iterating through to find marginal prices
    uint _lowestIndex = 0;
    while(_array[_lowestIndex] =< _x){ //first iterate through array until finding next higher price
        _lowestIndex++; //bug in this prototype: handling identical offers, and offers == 0;
    }
    for(uint i = _lowestIndex; i < _array.length; i++){
        if(_array[i] > _x){
            if(_array[_lowestIndex] > _array[i]){
                _lowestIndex = i;
            }
        }
    }
    return _lowestIndex;
}


    function clearHourAhead() returns (uint, address[]){
        uint memory _hourlyPrice; //declare variable for the prices we're returning
        uint[] memory _hourlyOfferPrices; //create an array of prices offered for the hour
        uint[] memory _hourlyOfferQuantities; //create an array of quantities offered for the hour
        for(uint i = 0; i < _validOffers.length; i++){
            uint _price;
            uint _offerQuantity;
            (_price, _offerQuantity,,,,) = _readDayAheadOffer(_validOffers[i]);
            _hourlyOfferPrices[i] = _price;
            _hourlyOfferQuantities[i] = _offerQuantity;
            }
        uint _genCounter = 0;
        uint[] _marginalPrices;
        address[] _clearedOffers;
        uint _marginalIndex = 0;
        while(_genCounter < hourAheadLoad){
            _marginalIndex = _getLowestAboveX(_hourlyOfferPrices, _hourlyOfferPrices[_marginalIndex]);//note, this is an implicit MOPR of zero
            _marginalPrices.push(_hourlyOfferPrices[_marginalIndex]);
            _clearedOffers.push(_validOffers[_marginalIndex]);
            _genCounter += _hourlyOfferQuantities[_marginalIndex];
                    } //iterates throgh the supply curve until gen > load;
        _hourlyPrice[h] = _marginalPrices[_marginalPrices.length -1];

        delete _validOffers; //clears out the array of offers

        return (_hourlyPrice, _clearedOffers);
        }

    uint clearingPrice;
    address[] winningGenerators;

    (clearingPrice, winningGenerators) = clearHourAhead();

    ///NEXT:  test in REMIX, then rewards winners;
    ///TRUE UP FUNCTIONS;
    }






























