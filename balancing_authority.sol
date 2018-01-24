
    //real-time dispatch and true-up functions
        ///save day-ahead bids and offers, check against meter for each account, credit/debit based on real production

    //islanding function



contract SystemMeter is GenMeter{
    ///the system meter is a gen meter that can island
}



///VERIFIED IN REMIX
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

contract DayAheadBidInterface{
    function readDayAheadBid() external view returns(
        uint[3] quantities,
        uint year,
        uint month,
        uint day);
} //interface to read the day ahead bid from a load meter

contract GenMeterInterface {
    function readGen() external view returns(uint);
}

contract DayAheadOfferInterface {
    function readDayAheadOffer() external view  returns(
        uint price,
        uint[3] quantities,
        uint year,
        uint month,
        uint day);
}

contract BalancingAuthority{

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


    function addMeter(address _address)  {
         uint _maxLoad;
         bool _gen;
         uint _nameplate;
         uint _storageCapacity;
       AddMeterInterface meterAdder = AddMeterInterface(_address);
       (_maxLoad,_gen,_nameplate,_storageCapacity) = meterAdder.getMeterSpecs();
       uint _id = systemAccounts.push(MeteredAccount(_address, _maxLoad, _gen, _nameplate, _storageCapacity)) -1;
       meterMap[_id] = _address;
       meterCount++;
       if(_gen == true){
           genMeterMap[genMeterCount] = _address;
           genMeterCount++;
       }

    }

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

    function _readDayAheadBid(address _address) returns(uint[3], uint, uint, uint){
        DayAheadBidInterface dayAheadBids = DayAheadBidInterface(_address);
        return dayAheadBids.readDayAheadBid();
    }

    struct systemDayAheadLoad{
      uint year;
      uint month;
      uint day;
      uint[3] dayAheadLoad; ///hourly expected load
    }//structure to record the system-wide day ahead load

    function getDayAheadBids(uint _year, uint _month, uint _day) returns(uint[3]){
        uint[3] memory _cumulativeQuantities;
        for(uint i = 0; i < meterCount; i++){
            uint _bidYear;
            uint _bidMonth;
            uint _bidDay;
            (, _bidYear, _bidMonth, _bidDay) = _readDayAheadBid(systemAccounts[i].accountAddress);
            if(_bidYear == _year && _bidMonth == _month && _bidDay == _day){
                uint[3] memory _bidQuantities;
                (_bidQuantities,,,) = _readDayAheadBid(systemAccounts[i].accountAddress);
                for(uint j = 0; j < 3; j++){
                    _cumulativeQuantities[j] += _bidQuantities[j];
                }
            }
        }
        return _cumulativeQuantities;
    }

    function _readGen(address _address) returns(uint){
        GenMeterInterface genReader = GenMeterInterface(_address);
        return genReader.readGen();
    }

    function _getSystemGen() returns(uint){
        uint _cumulativeGen = 0;
        for (uint i = 0; i < genMeterCount; i++){
            _cumulativeGen += _readGen(genMeterMap[i]);
        }
        return _cumulativeGen;
    }

    function _readDayAheadOffer(address _address) returns (uint, uint[3], uint, uint, uint){
        DayAheadOfferInterface dayAheadOffers = DayAheadOfferInterface(_address);
        return dayAheadOffers.readDayAheadOffer();
    }


function _getLowestAboveX(uint[] _array, uint _x) returns(uint){ //function to get index of lowest value in an array, above zero
    uint _lowestIndex = 0;
    while(_array[_lowestIndex] <= _x){
        _lowestIndex++;
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

    ////
    uint[3] _hourlyLoad;
    function _setHourlyLoad(uint _year, uint _month, uint _day){
        _hourlyLoad = getDayAheadBids(_year, _month, _day);
    }

    address[] _validOffers;

    function _setValidOffers(uint _year, uint _month, uint _day) {
            for(uint i = 0; i < genMeterCount; i++){
                uint _offerYear;
                uint _offerMonth;
                uint _offerDay;
                (,, _offerYear, _offerMonth, _offerDay) = _readDayAheadOffer(genMeterMap[i]);
                if(_offerYear == _year && _offerMonth == _month && _offerDay == _day){
                    _validOffers.push(genMeterMap[i]);
            }
            }
            }

    function viewValidOffers() returns(address[]){
        return _validOffers;
    }

    function getDayAheadOffers() returns (uint[3]){
        uint[3] memory _hourlyPrice; //declare variable for the prices we're returning
        for(uint h; h < 3; h++){
            uint[] memory _hourlyOfferPrices; //create an array of prices offered for the hour
            uint[] memory _hourlyOfferQuantities; //create an array of quantities offered for the hour
            for(uint i = 0; i < _validOffers.length; i++){
                uint _price;
                uint[3] memory _meterOfferQuantities;
                (_price, _meterOfferQuantities,,,) = _readDayAheadOffer(genMeterMap[i]);
                _hourlyOfferPrices[i] = _price;
                _hourlyOfferQuantities[i] = _meterOfferQuantities[h];
            }
            uint _genCounter = 0;
            uint[] _marginalPrices;
            uint _marginalIndex;
            while(_genCounter < _hourlyLoad[h]){
                _marginalIndex = _getLowestAboveX(_hourlyOfferPrices, 0);//note, this is an implicit MOPR of zero
                _marginalPrices.push(_hourlyOfferPrices[_marginalIndex]);
                _genCounter += _hourlyOfferQuantities[_marginalIndex];
                }
            _hourlyPrice[h] = _marginalPrices[_marginalPrices.length -1];
            }
        return _hourlyPrice;
        }

    }






























