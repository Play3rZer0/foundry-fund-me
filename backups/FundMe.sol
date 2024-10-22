//SPDX-License-Identifier: MIT

//Get funds from users
//Withdraw funds
//Set a minimum funding value in USD

//xkSync testnet RPC
//https://zksync-era-sepolia.blockpi.network/v1/rpc/public

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint;

    address[] public funders;
    mapping(address => uint) public addressToAmountFunded;

    address public immutable i_owner;
    uint public constant minimumUSD = 5e18;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        //Allow users to send eth
        //Have a minimum
        require(
            msg.value.getConversionRate() >= minimumUSD,
            "Not enough ether"
        );
        //require(msg.value >= minimumUSD, "Not enough ether");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        //require(msg.sender == owner, "Must be owner!");
        for (
            uint funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //reset array
        funders = new address[](0);
        //withdraw funds

        //transfer
        //payable(msg.sender).transfer(address(this).balance);

        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send failed");

        //call is recommended
        //(bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        (bool callSuccess, ) = msg.sender.call{value: address(this).balance}(
            ""
        );
        require(callSuccess, "Call Failed");
    }

    function getVersion() public view returns (uint) {
        //return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
        return
            AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF)
                .version();
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Must be owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
