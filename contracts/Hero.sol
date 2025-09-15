// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
/**
 * Design
        - We want to be able to generate random Hereos.
        - The user gets to put in their class of hereo on generation
            classes: Mage, Healer, Barbarian
            Class will not influence stats created, therefore getting an epic hero will be hard.
        - I want to be paid... 0.05 eth per hero!
        - I should be able to get my heroes I have generated.
        - Heroes should be stored on the chain.
        - stats are strength, health, intellect, magic, dexterity
        - stats are randomly generated
            A scale of 1 - 18
            The stats are randomly picked and their amplitude is randomly determined according to the following:
                Stat 1 can max at 18
                Stat 2 can max at 17
                Stat 3 can max at 16
...
 */

contract Hero {

    enum Class {Mage, Healer, Barbarian}

    mapping(address => uint[]) addressToHeroes;

    function getHeroes() public view returns (uint[] memory){
        return addressToHeroes[msg.sender];
    }

    function getStrength(uint hero) public pure returns(uint){
        return((hero >> 2) & 0x1f);
    }
    function getHealth(uint hero) public pure returns(uint){
        return((hero >> 7) & 0x1f);
    }    
    function getIntellect(uint hero) public pure returns(uint){
        return((hero >> 12) & 0x1f);
    }    
    function getMagic(uint hero) public pure returns(uint){
        return((hero >> 17) & 0x1f);
    }    
    function getDexterity(uint hero) public pure returns(uint){
        return((hero >> 22) & 0x1f);
    }

    function createHero(Class class) public payable{
        require( msg.value >= 0.05 ether, "Not enough money");
        uint len = 5;
        uint[] memory stats = new uint[](5);
        stats[0] = 2;
        stats[1] = 7;
        stats[2] = 12;
        stats[3] = 17;
        stats[4] = 22;
        uint hero = uint(class);
        do {
            /**
             * hero = 00000 01 
             * position = 2
             * value = 5 = 101, 10100(shifted by 2)
             * hero | value
             * 00000 01 
             * 00101 00
             * 00101 01
             */
            //randomly generate from 0 - len-1 (0-4)
            uint position = generateRandomNumber() % len;

            uint value = generateRandomNumber() % (13 + len) + 1;
            hero |= (value << stats[position]);

            len--;
            stats[position] = stats[len];
        } while (len > 0);
        addressToHeroes[msg.sender].push(hero);
    }

    function generateRandomNumber() internal virtual view returns (uint){
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp)));
    }
}
/**
 * [2 7 12 17 22 ] 5
 * [22 7 12 17 | 2] 4
 * [17 7 12 | 22 2] 3
 * [17 12 | 7 22 2] 2
 * [12 | 17  7 22 2] 1
 */