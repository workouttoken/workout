// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");


it("test initial token", async function () {
  const WT = await ethers.getContractFactory("WorkoutToken");
  const wt = await WT.deploy();
  await wt.deployed();
  console.log('WorkoutToken deployed at:'+ wt.address)
});

it("start distribution - should returns 'Caller is not super owner' information", async function () {
    const Storage = await ethers.getContractFactory("WorkoutToken");
    const storage = await Storage.deploy();
    await storage.deployed();
    await storage.startDistribution();    
});

it("checks distribution status - should returns 'Caller is not super owner' information", async function () {
    const Storage = await ethers.getContractFactory("WorkoutToken");
    const storage = await Storage.deploy();
    await storage.deployed();
    await storage.getDistributionStatus();    
});
