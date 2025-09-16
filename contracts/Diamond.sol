// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./counter.sol";

contract A {
    uint a;

    function setA(uint _a) public {
        a = _a;
    }

    function getA() public view returns (uint) {
        return a;
    }   
}

contract B {
    uint b;
    address ContractA;

    constructor(address _ContractA) {
        ContractA = _ContractA;
    }

    function setB(uint _a) public {
        (bool success, ) = ContractA.delegatecall(
            abi.encodeWithSignature("setA(uint256)", _a +1)
        );
        console.log(success);
    }
    
    function getB() public view returns (uint) {
        return b;
    }
}