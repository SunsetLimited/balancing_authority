pragma solidity ^0.4.0;


contract balancingAuthority is Ownable {
    //receive meter data
    struct SystemMeter {
        bool export; ///indicates if the local balacning authority is net importing or exporting with larger electric system
        uint powerFlow; ///indicates the net inflow/outflow (determined by status of export variable)
        uint systemBid; ///spot price the distribution system pays for exports, e.g.; time-of-use net metered rate
        uint systemOffer; ///spot price the distribution system charges for imports
    }

    SystemMeter systemMeter; ///define the actual system meter

    function setSystemMeter(bool _export, uint _powerFlow, uint _systemBid, uint _systemOffer) private{
        systemMeter.export = _export;
        systemMeter.powerFlow = _powerFlow;
        systemMeter.systemBid = _systemBid;
        systemMeter.systemOffer = _systemOffer;
    } ///private function called by the balancing authority account owner, reads the physical meter



    //system balancing
        //read offers from meters
            //iterate through a mapping of accounts
            //-loadMeters[], genMeters[], storageMeters[]
            //mappings:
	            //(uint => address)///match meters to address
				//	loadAccounts, genAccounts, storageAccounts

    //balancing function
        //read data from metered accounts
    //islanding function



    }
}

