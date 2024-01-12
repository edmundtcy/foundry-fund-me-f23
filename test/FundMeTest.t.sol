// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    // setUp always run first
    function setUp() external {
        // Deploy contract
        // Us call FundMeTest and deploy fundMe
        // The fundMeTest contract is the owner of the fundMe contract
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public{
        console.log("min usd amount:", fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsDeployer() public{ 
        console.log("owner: ", fundMe.i_owner());
        console.log("msg.sender: ", msg.sender);
        console.log("adddress this: ", address(this));
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public{
        console.log("version: ", fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }
    //Work with address outside our system
    // 1. Unit
    //    - Test the specific part of code
    // 2. Integration
    //    - Test how our code works with other parts of our code
    // 3. Forked
    //    - Test how our code works in simulated environment
    // 4. Staging
    //    - Test how our code works in real environment that is not production


    // Modular deployment
}