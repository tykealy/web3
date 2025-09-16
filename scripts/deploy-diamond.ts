import "@nomiclabs/hardhat-ethers";
import { Contract } from "ethers";
import { ethers } from "hardhat";

async function deploy() {
    const A = await ethers.getContractFactory("A")
    const B = await ethers.getContractFactory("B")

    const a = await A.deploy()
    await a.deployed()

    const b = await B.deploy(a.address)
    await b.deployed()

    console.log("=====================");
    console.log(await a.getA());
    console.log(await b.getB());


    await a.setA(42);
    console.log("=====================");
    console.log(await a.getA());
    console.log(await b.getB());

    await b.setB(60); 
    console.log("=====================");
    console.log(await b.getB());
    console.log(await a.getA());
}

deploy()
