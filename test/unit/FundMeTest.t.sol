// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

    // Create a fake new address to send all the transaction
    address USER = makeAddr("user");
    
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    FundMe fundMe;
    // setUp always run first
    function setUp() external {
        // Deploy contract
        // Us call FundMeTest and deploy fundMe
        // The fundMeTest contract is the owner of the fundMe contract
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // Give user fake money
    }

    function testMinimumDollarIsFive() public{
        console.log("min usd amount:", fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsDeployer() public{ 
        console.log("owner: ", fundMe.getOwner());
        console.log("msg.sender: ", msg.sender);
        console.log("adddress this: ", address(this));
        assertEq(fundMe.getOwner(), msg.sender);
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

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // hey, the next line, should revert!
        // assert(This tx fails/reverts)
        fundMe.fund(); // fund with 0 ETH, should fail as 5 USD is the minimum
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // fund with 0.1 ETH
        // Test that addressToAmountFunded mapping has been updated
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunder() public {
        vm.prank(USER); // The next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // fund with 0.1 ETH
        // Test that addressToAmountFunded mapping has been updated
        address funder = fundMe.getFunder(0); // Only have one funder
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerAndWithdraw() public funded{
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw(); // User withdraw money and expect this to fail
    }

    function testWithDrawWithSingleFunder() public funded{
        // Arrange
        // Our balance before withdraw
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // To see how much gas widthdraw spend, need to find gas left before and after withdraw
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE); // Set gas price
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // should have spend gas ? -> Yes but Anvil gas price is default to be zero
        // uint256 gasUsed = (gasStart - gasleft()) * tx.gasprice; // How much gas we used
        // console.log("gas used: ", gasUsed);

        // Assert
        // Our balance after withdraw
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // How about gas spent ?
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); // How about gas spent ?
    }

    function testWithdrawFromMultipleFunders() public funded{
        //Arrange
        // Use number to generate address, it must be uint160 as address is 20 bytes
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // Dont use address(0)
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE); // Both prank and deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded{
        //Arrange
        // Use number to generate address, it must be uint160 as address is 20 bytes
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // Dont use address(0)
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE); // Both prank and deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        console.log("fundMe balance: ", address(fundMe).balance);
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

}