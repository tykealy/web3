import "@nomiclabs/hardhat-ethers"
import { ethers } from "hardhat"
import { expect } from "chai"

describe("GasReport", function(){
    it("should report gas", async function(){
        const GasReport = await ethers.getContractFactory("GasReport")
        const gasReport = await GasReport.deploy()
        await gasReport.deployed()

        for(let i = 0; i < 10; i++){
            await gasReport.test1()
            await gasReport.test2()
            await gasReport.test3()
            await gasReport.test4()
            await gasReport.test5()
        }
    })
})