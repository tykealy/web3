import "@nomiclabs/hardhat-ethers"
import { expect } from "chai";
import { ethers } from "hardhat"


describe("Hero", function(){
 
    async function createHeroContract() {
        const Hero = await ethers.getContractFactory("TestHero");
        const hero = await Hero.deploy();
        await hero.deployed();

        return hero;
    }

    let hero:any ;

    before(async function (){
        hero = await createHeroContract();
        await hero.setStubRandomNumber(100)
    })

    it("should fails due to not insufficient ether", async function () {
        let e: any;
        
        try{
            await hero.createHero(0,{ value: ethers.utils.parseEther("0.0499999") });
        }catch(err){
            e= err;
        };
        expect(e.message.includes("Not enough money")).to.equal(true);
    })


    it("should get a zero hero array.", async function () {
        expect(await hero.getHeroes()).to.deep.equal([]);
    })

    it("should get a hero array.", async function () {
        await hero.createHero(0,{ value: ethers.utils.parseEther("0.05") });
        let heroes = await hero.getHeroes();
        console.log(heroes[0])
        expect(heroes.length).to.eq(1)
    })

    it("should have strength = 11 ", async function () {
        await hero.createHero(0,{ value: ethers.utils.parseEther("0.05") });
        let h = (await hero.getHeroes())[0];
        expect(await hero.getStrength(h)).to.eq(11)
    })

    it("should have dexterity = 16 ", async function () {
        await hero.createHero(0,{ value: ethers.utils.parseEther("0.05") });
        let h = (await hero.getHeroes())[0];
        expect(await hero.getDexterity(h)).to.eq(16)
    })
        
    it("should have health = 5 ", async function () {
        await hero.createHero(0,{ value: ethers.utils.parseEther("0.05") });
        let h = (await hero.getHeroes())[0];
        expect(await hero.getHealth(h)).to.eq(5)
    })

    it("should have magic = 11 ", async function () {
        await hero.createHero(0,{ value: ethers.utils.parseEther("0.05") });
        let h = (await hero.getHeroes())[0];
        expect(await hero.getMagic(h)).to.eq(11)
    })

    it("should have Intellect = 3 ", async function () {
        await hero.createHero(0,{ value: ethers.utils.parseEther("0.05") });
        let h = (await hero.getHeroes())[0];
        expect(await hero.getIntellect(h)).to.eq(3)
    })
})