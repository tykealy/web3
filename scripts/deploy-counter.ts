import "@nomiclabs/hardhat-ethers";
import { Contract } from "ethers";
import { ethers } from "hardhat";


async function  deploy() {
    const Counter = await ethers.getContractFactory("Counter")
    const counter  = await Counter.deploy()
    await counter.deployed()

    return counter;
}

async function getCounter(counter: Contract) {
    await counter.setCounter();
    console.log(await counter.getCounter())
}

deploy().then(getCounter)