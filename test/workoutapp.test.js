// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WorkoutToken", function () {
    let contract;
    
    async function getSuperOwner(number) {
        switch(number) {
            case 1:
                return await ethers.provider.getSigner('0x1878fDF13b77546039Da7536046F386FE696890b');
                break;
            case 'test':
                return await ethers.provider.getSigner('0x0000000000000000000000000000000000000000');
                break;
            default:
                return await ethers.provider.getSigner('0x9AaC0e94c973a4C643E03BFeF0FE4b8063aa5B51');
                break;
        }
    }

    beforeEach(async function () {
      const WT = await ethers.getContractFactory("WorkoutToken");
      const token = await WT.deploy();
      contract = await token.waitForDeployment();
    });
    
    it("start distribution", async function () {
        await expect(contract.startDistribution()).to.be.reverted;
        const [owner] = await ethers.getSigners();
        let so = await getSuperOwner(1);
        let so2 = await getSuperOwner(2);
        await contract.connect(owner).transfer(so2.address,'15000000000000000000000000000');
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        
        await owner.sendTransaction({
              to: so.address,
              value: '12700000000000000',
            });
    
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        await owner.sendTransaction({
              to: so2.address,
              value: '12700000000000000',
            });
    
        await ethers.getImpersonatedSigner(so.address);
        await ethers.getImpersonatedSigner(so2.address);
        await contract.connect(so).startDistribution();
        await contract.connect(so).startDistribution();
        await contract.connect(so2).startDistribution();
        
    });

    it("checks distribution status", async function () {
        let so1 = await getSuperOwner(1);
        let result = await contract.connect(so1).getDistributionStatus();   
        expect(ethers.toNumber(result[0])).to.equal(0);   
        expect(result[1]).to.equal('0x0000000000000000000000000000000000000000');   
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

    it('approve. should allow spender to transfer tokens on behalf of owner', async () => {
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

    it("add new owner address", async () => {
        const newOwner = '0x1234567890123456789012345678901234567890'; // Example address
        const [owner] = await ethers.getSigners();
        let so = await getSuperOwner(1);
        let so2 = await getSuperOwner(2);
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        
        await owner.sendTransaction({
              to: so.address,
              value: '12700000000000000',
            });
    
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        await owner.sendTransaction({
              to: so2.address,
              value: '12700000000000000',
            });
    
        await ethers.getImpersonatedSigner(so.address);
        await ethers.getImpersonatedSigner(so2.address);
        await contract.connect(so).addAddress(newOwner);
        await contract.connect(so).addAddress(newOwner);
        await contract.connect(so2).addAddress(newOwner);

    });

    it("show roles", async () => {
        await contract.showRoles();
    });

    it("delete owner address", async () => {
        const _address = '0xa60a4fe0591017233Ab3b3B7de028Db23Fa48300'; // Example owner address

        const [owner] = await ethers.getSigners();
        let so = await getSuperOwner(1);
        let so2 = await getSuperOwner(2);
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        
        await owner.sendTransaction({
              to: so.address,
              value: '12700000000000000',
            });
    
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        await owner.sendTransaction({
              to: so2.address,
              value: '12700000000000000',
            });
    
        await ethers.getImpersonatedSigner(so.address);
        await ethers.getImpersonatedSigner(so2.address);
        await contract.connect(so).deleteAddress(_address);
        await contract.connect(so).deleteAddress(_address);
        await contract.connect(so2).deleteAddress(_address);
    });

    it("checks if address is owner", async () => {
        const owner = '0xa60a4fe0591017233Ab3b3B7de028Db23Fa48300';
        const notOwner = '0x1234567890123456789012345678901234567890';

        expect(await contract.hasOwner(owner)).to.be.equal(true);
        expect(await contract.hasOwner(notOwner)).to.be.equal(false);
    });

    it("checks if caller is super owner", async () => {
        let owner1 = await getSuperOwner(1);
        let owner2 = await getSuperOwner(2);
        expect(await contract.connect(owner1).checkSuperOwner()).to.equal(true);
        expect(await contract.connect(owner2).checkSuperOwner()).to.equal(true);
        
        expect(await contract.checkSuperOwner()).to.be.equal(false);
    });

    it("checks confirmation data", async () => {
        const [owner] = await ethers.getSigners();
        let so = await getSuperOwner(1);
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        
        await owner.sendTransaction({
              to: so.address,
              value: '12700000000000000',
            });
    
        await ethers.getImpersonatedSigner(so.address);
        await contract.connect(so).addAddress('0x1234567890123456789012345678901234567890');
        await contract.getWaitingConfirmationsList();
        await contract.connect(so).getWaitingConfirmationsList();
    });

    it("addRole", async () => {
        const _address = '0x1234567890123456789012345678901234567890'; // Example address

        const [owner] = await ethers.getSigners();
        let so = await getSuperOwner(1);
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        
        await owner.sendTransaction({
              to: so.address,
              value: '12700000000000000',
            });
            
        await ethers.getImpersonatedSigner(so.address);
        await contract.connect(so).addRole(4, _address, 'NEW_ROLE');
        await contract.connect(so).addRole(4, _address, 'NEW_ROLE');
        //expect(await contract.connect(so).addRole(4, _address, 'NEW_ROLE')).to.equal(true);
    });

    it("deleteRole", async () => {
        const address = '0xa60a4fe0591017233Ab3b3B7de028Db23Fa48300'; // Example owner address
        const address2 = '0x1234567890123456789012345678901234567890'; // Example address
        const [owner] = await ethers.getSigners();
        let so = await getSuperOwner(1);
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        
        await owner.sendTransaction({
              to: so.address,
              value: '12700000000000000',
            });
            
        await ethers.getImpersonatedSigner(so.address);

        // delete owner address
        await contract.connect(so).deleteRole(1, address);
        await contract.connect(so).deleteRole(1, address2);
    });

    it("has role test", async () => {
        const _owner = '0xa60a4fe0591017233Ab3b3B7de028Db23Fa48300'; // owner address
        const notOwner = '0x1234567890123456789012345678901234567890'; // Example address

        const [owner] = await ethers.getSigners();
        let so = await getSuperOwner(1);
        let so2 = await getSuperOwner(2);
        await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        
        await owner.sendTransaction({
              to: so.address,
              value: '12700000000000000',
            });
            
        //await ethers.provider.send('hardhat_impersonateAccount', [owner.address]); // get some eth from a miner
        await owner.sendTransaction({
              to: so2.address,
              value: '12700000000000000',
            });
            
        await ethers.getImpersonatedSigner(so.address);
        await ethers.getImpersonatedSigner(so2.address);
        // check roles
        expect(await contract.connect(so).hasRole(1, _owner)).to.equal(true);
        expect(await contract.connect(so2).hasRole(1, notOwner)).to.equal(false);
        expect(await contract.connect(so2).hasRole(1, so2.address)).to.equal(true);
    });
});
