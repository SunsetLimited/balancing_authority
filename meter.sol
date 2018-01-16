pragma solidity ^0.4.0;


contract Meter is Ownable {

    struct Meter {
        bool export; ///determines if meter is net load or generation
        bool powerFlow; ///net power flow in or out of the meter
    }

    struct Meter meter;

    function setMeter(bool _export, uint _powerFlow) private {
        meter.export = _export;
        meter.powerFlow = _powerFlow;
    } ///private function set by the actual account meter

}

contract genMeter is meter{
    ///create and offer structure
    ///make offers
    ///
}

contract loadMeter is meter {

}

contract storageMeter is meter {


}