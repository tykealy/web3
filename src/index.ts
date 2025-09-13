import { ethers } from "ethers";
import Counter from "../artifacts/contracts/counter.sol/Counter.json"
function getEth(){
    //@ts-ignore
    const eth = window.ethereum;
    if(!eth){
        throw new Error("gret matamask")
    }

    return eth
}

async function hasAccount(){
    const eth = getEth()
    const accounts = await eth.request({method: 'eth_accounts'}) as string[]
    return accounts && accounts.length;
}

async function requestAccount() {
    const eth = getEth();
    const accounts = await eth.request({method: 'eth_requestAccounts'}) as string[]

    return accounts && accounts.length;
}

async function run(){
    if(!await hasAccount() && !await requestAccount()){
        throw new Error ("Please let me have you mnemonics")
    }
    const counter = new ethers.Contract(
        process.env.CONTRACT_ADDRESS as string,  
        Counter.abi,
        new ethers.providers.Web3Provider(getEth()).getSigner()
    )
    const element = document.createElement('div');
    async function setCounter() {
        element.innerHTML = await counter.getCounter()
    }

    setCounter()
    const button = document.createElement('button');

    button.innerText = 'increase'
    button.onclick = async function () {
        await counter.setCounter()
    }

    counter.on(counter.filters.CounterInc(), function(){
        setCounter()
    })
    document.body.appendChild(element)
    document.body.appendChild(button)

}

run()