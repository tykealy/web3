import _ from "@nomiclabs/hardhat-ethers"
import { ethers } from "hardhat"


describe("Diamond", function(){
    it('Print Memory slot', async function(){
        const Storage = await ethers.getContractFactory("Storage")

        const a = await Storage.deploy(0x1f, 0x10, 10)
        await a.deployed()
        
        printContractStorage(a.address, "storage", 3);
    })
})


async function printContractStorage(address:string, name:string, count:number) {
    for(let i =0; i<count; i++){
        console.log(name, i, await ethers.provider.getStorageAt(address, i))
    }
}