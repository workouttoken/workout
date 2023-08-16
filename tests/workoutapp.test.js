// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");


it("initial deploy", async function () {
  const WT = await ethers.getContractFactory("WorkoutToken");
  const wt = await WT.deploy();
  await wt.deployed();
  console.log('WorkoutToken deployed at:'+ wt.address);
});

it("start distribution - should returns 'Caller is not super owner' information", async function () {
    const WT = await ethers.getContractFactory("WorkoutToken");
    const wt = await WT.deploy();
    await wt.deployed();
    await expect(wt.startDistribution()).to.be.reverted;
});

it("checks distribution status - should returns 'Caller is not super owner' information", async function () {
    const WT = await ethers.getContractFactory("WorkoutToken");
    const wt = await WT.deploy();
    await wt.deployed();
    await expect(wt.getDistributionStatus()).to.be.reverted;   
});

it('transfer test', async () => {
    const WT = await ethers.getContractFactory("WorkoutToken");
    const wt = await WT.deploy();
    await wt.deployed();

    const account = '0x1234567890123456789012345678901234567890'; // Example address

    // Initial balances
    const initialBalance = await wt.balanceOf(account);

    // Perform transfer
    const amount = 200;
    await wt.transfer(account, amount);

    // Updated balances
    const newBalance = await wt.balanceOf(account);

    expect(newBalance.toNumber()).to.be.equal(initialBalance.toNumber() + amount);
});


it('should allow spender to transfer tokens on behalf of owner', async () => {
    const WT = await ethers.getContractFactory("WorkoutToken");
    const wt = await WT.deploy();
    await wt.deployed();

    let owner = await ethers.getSigner(0);      // Owner's signer
    let spender = await ethers.getSigner(1);    // Spender's signer 
    let recipient = await ethers.getSigner(2);  // Recipient's signer

    const amount = 100;

    // Approve the spender to spend tokens on behalf of the owner
    await wt.connect(owner).approve(spender.address, amount);

    // Perform the transferFrom
    await wt.connect(spender).transferFrom(owner.address, recipient.address, amount);

    // Check recipient's balance
    const recipientBalance = await wt.balanceOf(recipient.address);
    expect(recipientBalance.toNumber()).to.equal(amount, 'Incorrect recipient balance after transferFrom');
});
