require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      forking: {
        url: "https://arb-mainnet.g.alchemy.com/v2/MqMIhbvaDzMjTluV-HsXVQK5p8_pUxmH",
        //blockNumber: 13060982
      }
    }
  }
};
