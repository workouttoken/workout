// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WorkoutToken", function () {
  it("test initial value", async function () {
    const WT = await ethers.getContractFactory("WorkoutToken");
    const wt = await WT.deploy();
    await wt.deployed();
    console.log('WorkoutToken deployed at:'+ wt.address)
  });
   it("start distribution", async function () {
    const Storage = await ethers.getContractFactory("WorkoutToken");
    const storage = await Storage.deploy();
    await storage.deployed();
    const storage2 = await ethers.getContractAt("WorkoutToken", storage.address);
    storage2.startDistribution();
  });
});