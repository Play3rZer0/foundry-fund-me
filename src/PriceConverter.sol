//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed //refactor 1
    ) internal view returns (uint256) {
        //Address and ABI of contract
        //0x694AA1769357215DE4FAC081bf1f309aDC325306
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
        (, int256 price,,,) = priceFeed.latestRoundData();
        //Price of ETH in terms of USD
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); //refactor 2 as input parameter
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() public view returns (uint256) {
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
            //AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
            .version();
    }
}
