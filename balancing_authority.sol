pragma solidity ^0.4.0;

import "./meter.sol";

contract balancingAuthority {
    //the first function of the balancing authority account is to maintain the microgrid's metered state vis-a-vis the
    //larger electric power distribution system
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
        ///interconnection to the larger system

    ///the second function of the balancing authority account is to facilitate the interaction of all metered accounts

    mapping (uint => address) meters; ///all metered accounts
    mapping (uint => address) genMeters; ///all metered accounts with associated distributed generation
///###NEED A FUNCTION TO ADD NEW ACCOUNTS###
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
        ///need to create a clearing function
            ///iterate through the mapping of meters and gen meters to record their supply
            ///this really could all be back-end, lets sleep on it
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
