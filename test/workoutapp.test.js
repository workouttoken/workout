// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WorkoutToken", function () {
    let contract;

    beforeEach(async function () {
      const WT = await ethers.getContractFactory("WorkoutToken");
      const token = await WT.deploy();
      contract = await token.waitForDeployment();
    });
    
    it("start distribution - should returns 'Caller is not super owner' information", async function () {
        await expect(contract.startDistribution()).to.be.reverted;
    });

    it("checks distribution status - should returns 'Caller is not super owner' information", async function () {
        await expect(contract.getDistributionStatus()).to.be.reverted;   
    });

    it('transfer test', async () => {
        const account = '0x1234567890123456789012345678901234567890'; // Example address

        // Initial balances
        const initialBalance = await contract.balanceOf(account);

        // Perform transfer
        const amount = 200;
        await contract.transfer(account, amount);

        // Updated balances
        const newBalance = await contract.balanceOf(account);

        expect(ethers.toNumber(newBalance)).to.be.equal(ethers.toNumber(initialBalance) + amount);
    });

    it('should allow spender to transfer tokens on behalf of owner', async () => {
        const [owner, spender, recipient] = await ethers.getSigners();
        const amount = 100;

        // Approve the spender to spend tokens on behalf of the owner
        await contract.connect(owner).approve(spender, amount);
        // Perform the transferFrom
        await contract.connect(spender).transferFrom(owner.address, recipient.address, amount);

        // Check recipient's balance
        const recipientBalance = await contract.balanceOf(recipient.address);
        
        expect(ethers.toNumber(recipientBalance)).to.equal(amount, 'Incorrect recipient balance after transferFrom');
    });

    it("add new owner address (should be reverted - not super owner)", async () => {
        const newOwner = '0x1234567890123456789012345678901234567890'; // Example address

        // Add the new owner address
        await expect(contract.addAddress(newOwner)).to.be.reverted;
    });

    it("delete owner address (should be reverted - not super owner)", async () => {
        const owner = '0x1234567890123456789012345678901234567890'; // Example address

        // delete owner address
        await expect(contract.deleteAddress(owner)).to.be.reverted;
    });

    it("checks if address is owner", async () => {
        const owner = '0xa60a4fe0591017233Ab3b3B7de028Db23Fa48300';
        const notOwner = '0x1234567890123456789012345678901234567890';

        expect(await contract.hasOwner(owner)).to.be.equal(true);
        expect(await contract.hasOwner(notOwner)).to.be.equal(false);
    });

    it("checks if caller is super owner", async () => {
        expect(await contract.checkSuperOwner()).to.be.equal(false);
    });

    it("checks confirmation data", async () => {
        expect(await contract.getWaitingConfirmationsList()).to.be.equal('');
    });

    it("addRole (should be reverted)", async () => {
        const owner = '0x1234567890123456789012345678901234567890'; // Example address

        // delete owner address
        await expect(contract.addRole(2, owner)).to.be.reverted;
    });

    it("deleteRole (should be reverted)", async () => {
        const owner = '0x1234567890123456789012345678901234567890'; // Example address

        // delete owner address
        await expect(contract.deleteRole(3, owner)).to.be.reverted;
    });

    it("has role test", async () => {
        const owner = '0xa60a4fe0591017233Ab3b3B7de028Db23Fa48300'; // owner address
        const notOwner = '0x1234567890123456789012345678901234567890'; // Example address

        // check roles
        expect(await contract.hasRole('MAIN_OWNER', owner)).to.be.equal(true);
        await expect(contract.hasRole('MAIN_OWNER', notOwner)).to.be.reverted;
    });
});
