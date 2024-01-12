// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{

    function run() external returns (FundMe){
        // Before startBroadcast -> Not a "real" tx
        HelperConfig helperConfig = new HelperConfig();
        // Use () to wrap a struct for multiple return values
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();
        // After startBroadcast -> "real" tx !
        vm.startBroadcast();
        FundMe fundME = new FundMe(ethUsdPriceFeed); //DeployfundMe will be the owner of FundMe ?
        vm.stopBroadcast();
        return fundME;
    }
}