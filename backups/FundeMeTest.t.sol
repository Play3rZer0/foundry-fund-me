//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.minimumUSD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.i_owner());
        console.log(address(this));
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint version = fundMe.getVersion();
        assertEq(version, 4);
        //console.log(address(this));
    }
}
