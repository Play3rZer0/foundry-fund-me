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
    using PriceConverter for uint256;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner;
    uint256 public constant minimumUSD = 5e18;

    AggregatorV3Interface private s_priceFeed; //refactor 1

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed); //refactor 2
    }

    function fund() public payable {
        //Allow users to send eth
        //Have a minimum
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUSD,
            "Not enough ether"
        );
        //require(msg.value >= minimumUSD, "Not enough ether");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function withdraw() public onlyOwner {
        //require(msg.sender == owner, "Must be owner!");
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        //reset array
        s_funders = new address[](0);
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

    function getVersion() public view returns (uint256) {
        //return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
        /*return
            AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF)
                .version(); */
        /*return
            AggregatorV3Interface(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496); */
        return s_priceFeed.version(); //refactor 3
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

    //View pure functions (getters)

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
