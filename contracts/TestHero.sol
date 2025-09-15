// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Hero.sol";

contract TestHero is Hero{
    uint stubRandomNumber;

    function setStubRandomNumber(uint _stubRandomNumber) public {
        stubRandomNumber = _stubRandomNumber;
    }

    function generateRandomNumber() override internal view returns (uint){
        return stubRandomNumber;
    }
}