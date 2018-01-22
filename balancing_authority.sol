pragma solidity ^0.4.0;

import "./meter.sol";

contract BalancingAuthority {
    ///the following variables are descriptive of the system; functions for updating them are included below
    uint totalMeters; ///number of individual metered accounts in the balancing authority
    uint totalGenMeters; ///number of metered accounts with associated distributed generation
    uint systemMaxLoad; ///total power-usage capacity of all metered accounts on the system
    uint systemMaxGen; ///total power-production capacity of all distributed generation
    uint systemMaxStorage; ///total storage capacity

    ///
    ///the first purpose of the balancing authority account is to maintain the microgrid's metered state vis-a-vis the
    ///larger electric power distribution system

    struct SystemMeter {
        bool export; ///indicates if the local balancing authority is net importing or exporting with distribution system
        uint powerFlow; ///indicates the net inflow/outflow (determined by status of export variable)
        uint systemBid; ///spot price the distribution system pays for exports, e.g.; time-of-use net metered rate
        uint systemOffer; ///spot price the distribution system charges for imports
    }

    SystemMeter systemMeter; ///declare the system meter

    function setSystemMeter(bool _export, uint _powerFlow, uint _systemBid, uint _systemOffer) private{
        systemMeter.export = _export;
        systemMeter.powerFlow = _powerFlow;
        systemMeter.systemBid = _systemBid;
        systemMeter.systemOffer = _systemOffer;
    } ///private function called by the balancing authority account owner, reads the physical meter at the point of
        ///interconnection to the larger power distribution system

    ////
    ///the second purpose of the balancing authority account is to facilitate the interaction of all metered accounts

    ///first, create an indexing of all the metered accounts

    struct MeteredAccount{
        address accountAddress; ///the location of the relevant meter contract on the blockchain
        uint load; ///maximum load of the account (watts)
        bool gen; /// true/false whether this is a generation account
        uint nameplate; ///the maximum generation output of the account (watts); 0 if gen = false
        uint storageCapacity; ///the maximum storage capacity of the account (watt-hours)
    }

    MeteredAccount[] systemAccounts;
    MeteredAccount[]  generationAccounts;

    mapping (uint => address) meterMap; ///all metered accounts
    mapping (uint => address) genMeterMap; ///all metered accounts with associated distributed generation

    function _addAccount(address _address, uint _load, bool _gen, uint _nameplate, uint _storageCapacity) internal {
        uint id = systemAccounts.push(MeteredAccount(_address, _load, _gen, _nameplate, _storageCapacity)) - 1;
            //adds the new account to the systemAccounts array, and generates an id by which to map it
        meterMap[id] = _address; //address of the new metered account added by the balancing authority
        totalMeters++; //update the system count of meters
        systemMaxLoad += _load; //update the system total load

        if(_gen){
            uint genId = generationAccounts.push(MeteredAccount(_address, _load, _gen, _nameplate, _storageCapacity))- 1;
                //adds the new account to the genAccount array, and generates an id for mapping
            genMeterMap[genId] = _address;
            totalGenMeters++; //update the count of gen meters
            systemMaxGen += _nameplate; //update the update the total distributed generation capacity of the system
            systemMaxStorage += _storageCapacity; //update the total storage capacity of the system
        }
    }

    //with the mapping of all metered accounts, it's now possible to hold an auction by iterating through bids/offers

    struct MarketDay {
        uint year;
        uint month;
        uint day;
        }

    struct DayAheadResults {
        MarketDay marketDay;
        uint[] hourlyLoad; ///the total day-ahead demand, including from the external meter
        uint[] clearingPrice; ///the cleared offer price in the day-ahead market, by hour
    }///structure to save the results of the day-ahead auction; r

    function clearDayAheadAuction() internal returns(DayAheadResults){
        //iterate through meterMap, calling the dayAheadBid
                //check that market days match
                //if so, compile bids and add up load
        //iterate though genMeterMap, compiling offers
            ///the trick is to sort the offers; back end function?
                ///SHOW IT CAN BE DONE IN EVM
        //Must record the results; do so in metered accounts?
            //this is probably right, we can then true-up in teh accounts, and a record of
            //commitments can be easily kept
    }

    //system balancing
        //read offers from meters
            //iterate through a mapping of accounts
            //-loadMeters[], genMeters[], storageMeters[]
            //mappings:
	            //(uint => address)///match meters to address
				//	loadAccounts, genAccounts, storageAccounts
        //balance: could be done internal, or on the back-end
            //first, just add up the
            //need to create a supply curve
        //write the cleared offers into the meter accounts?

    //real-time dispatch and true-up functions
        ///save day-ahead bids and offers, check against meter for each account, credit/debit based on real production

    //islanding function



    }
}

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

    function getDayAheadOffers(uint _year, uint _month, uint _day) returns (uint[3]){
        ///this is where we need to balance the load and gen offers
    }

    }



























