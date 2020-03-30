pragma solidity >=0.4.25 <0.6.0;


contract SystemMeter is GenMeter{
    ///the system meter is a gen meter that can island
}

///0: ESTABLISH INTERFACES FOR BALANCING AUTHORITY TO DRAW DATA FROM METERS
contract MeterInterface {
function readMeter() external view returns(int);
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
        int quantity,
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
        int quantity,
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

    function _readMeter(address _address) returns (int){
        MeterInterface meterReader = MeterInterface(_address);
        return meterReader.readMeter();
    } //returns the current load of a given meter

    function getSystemLoad() returns(int) {
       int _cumulativeLoad = 0;
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

    function _readHourAheadBid(address _address) returns(int, uint, uint, uint, uint){
        HourAheadBidInterface hourAheadBids = HourAheadBidInterface(_address);
        return hourAheadBids.readHourAheadBid();
    }

    function getHourAheadBids(uint _year, uint _month, uint _day, uint _hour) returns(int){
        int _cumulativeBids;
        for(uint i = 0; i < meterCount; i++){
            int _bidQuantity;
            uint _bidYear;
            uint _bidMonth;
            uint _bidDay;
            uint _bidHour;
            (_bidQuantity, _bidYear, _bidMonth, _bidDay, _bidHour) = _readHourAheadBid(systemAccounts[i].accountAddress);
            if(_bidYear == _year && _bidMonth == _month && _bidDay == _day && _bidHour == _hour){
                    _cumulativeBids += _bidQuantity;
                }
                                    }
        hourAheadLoad = _cumulativeBids;
        return _cumulativeBids;
    }

    //2(b) functions to read hour-ahead offers
    function _readHourAheadOffer(address _address) returns (uint, int, uint, uint, uint, uint){//reads hour-ahead offer from a given meter
        HourAheadOfferInterface hourAheadOffer = HourAheadOfferInterface(_address);
        return hourAheadOffer.readHourAheadOffer();
    }

    //2(c) Market clearing functions




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

    function clearValidOffers(){
        delete _validOffers;
    } //function to clear valid offers before running a new auction

    function _getLowestAboveX(uint[] _array, uint _x) returns(uint){ //for iterating through to find marginal prices
    uint _lowestIndex = 0;
    while(_array[_lowestIndex] <= _x){ //first iterate through array until finding next higher price
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
        uint _hourlyPrice; //declare variable for the prices we're returning
        uint[] memory _hourlyOfferPrices; //create an array of prices offered for the hour
        uint[] memory _hourlyOfferQuantities; //create an array of quantities offered for the hour
        for(uint i = 0; i < _validOffers.length; i++){
            uint _price;
            int _offerQuantity;
            (_price, _offerQuantity,,,,) = _readHourAheadOffer(_validOffers[i]);
            _hourlyOfferPrices[i] = _price;
            _hourlyOfferQuantities[i] = uint(_offerQuantity);
            }
        uint _genCounter = 0;
        uint[] _marginalPrices;
        address[] _clearedOffers;
        uint _marginalIndex = 0;
        while(_genCounter < uint(-hourAheadLoad)){
            _marginalIndex = _getLowestAboveX(_hourlyOfferPrices, _hourlyOfferPrices[_marginalIndex]);//note, this is an implicit MOPR of zero
            _marginalPrices.push(_hourlyOfferPrices[_marginalIndex]);
            _clearedOffers.push(_validOffers[_marginalIndex]);
            _genCounter += _hourlyOfferQuantities[_marginalIndex];
                    } //iterates throgh the supply curve until gen > load;
        _hourlyPrice = _marginalPrices[_marginalPrices.length -1];

        delete _validOffers; //clears out the array of offers

        return (_hourlyPrice, _clearedOffers);
        }

    uint clearingPrice;
    address[] winningGenerators;



    ///NEXT:  test in REMIX, then rewards winners;
    ///TRUE UP FUNCTIONS;
    }

///following code is attempt to optimize auction clearing function in browser solidity

contract HourAheadOfferInterface {
    function readHourAheadOffer() external view  returns(
        uint price,
        int quantity,
        uint year,
        uint month,
        uint day,
        uint hour);
}
contract test{

    function _readHourAheadOffer(address _address) returns (uint, int, uint, uint, uint, uint){//reads hour-ahead offer from a given meter
        HourAheadOfferInterface hourAheadOffer = HourAheadOfferInterface(_address);
        return hourAheadOffer.readHourAheadOffer();
    }

address[] _validOffers = [0xbd9835ad1196cf677ceb121238dbb3e73aacbd2b, 0xf6e9e5a47cea2ec4ef1e2eb8307e783f1394817b,
                            0x368ad6328db21f181cace7787a3eb323bc76576d, 0x02992af1dd8140193b87d2ab620ca22f6e19f26c,
                            0xf2bd5de8b57ebfc45dcee97524a7a08fccc80aef];



    function _getLowestAboveX(uint[] _array, uint _x) returns(uint){ //for iterating through to find marginal prices
    uint _lowestIndex = 0;
    while(_array[_lowestIndex] <= _x){ //first iterate through array until finding next higher price
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

    function findMarginalPrice(uint _demand, uint[] _offerPrices, uint[] _offerQuantities) returns(uint, uint){
        //function returns the marginal price of the bid, as well as the partial dispatch of the last offer cleared
        uint _marginalIndex = _getLowestAboveX(_offerPrices, 0);
        uint _supplyCounter = 0;
        _supplyCounter += _offerQuantities[_marginalIndex];
        uint _marginalDispatch;
        while(_supplyCounter <= _demand){
            _marginalIndex = _getLowestAboveX(_offerPrices, _offerPrices[_marginalIndex]);
            _supplyCounter += _offerQuantities[_marginalIndex];
            }
        _marginalDispatch = _offerQuantities[_marginalIndex]-(_supplyCounter - _demand);
        return(_offerPrices[_marginalIndex], _marginalDispatch); //returns marginal price and the partial dispatch of the final offer
         }



    int hourAheadLoad = -40;
    address[] clearedOffers;

    function getClearedOffers() returns(address[]){
    return clearedOffers;
    }

    function clearHourAhead() returns (uint[], uint[]){
        uint _hourAheadLoad = uint(-hourAheadLoad);
        uint hourlyPrice; //declare variable for the prices we're returning
        uint marginalDispatch;
        uint[] _hourlyOfferPrices; //create an array of prices offered for the hour
        uint[]  _hourlyOfferQuantities; //create an array of quantities offered for the hour
        for(uint i = 0; i < _validOffers.length; i++){
            uint _price;
            int _offerQuantity;
            (_price, _offerQuantity,,,,) = _readHourAheadOffer(_validOffers[i]);
            _hourlyOfferPrices[i] = _price;
            _hourlyOfferQuantities[i] = uint(_offerQuantity);
            }
        return(_hourlyOfferPrices, _hourlyOfferQuantities);
    }
    //    (hourlyPrice, marginalDispatch) = findMarginalPrice(_hourAheadLoad, _hourlyOfferPrices, _hourlyOfferQuantities);
      //  for(uint j = 0; j < _validOffers.length; j++){
      //      if(_hourlyOfferPrices[j] <= hourlyPrice){
    //            clearedOffers.push(_validOffers[j]);
        //    } //populate array of cleared offers
        //}
   //     return (hourlyPrice, marginalDispatch);
     //   }





}
    ///cleared offers index needs to be integrated with the 'valid offer' array

