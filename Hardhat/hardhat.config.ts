import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import 'dotenv/config';

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    polygon: {
      url: process.env.URL_ALCHEMY,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
};

// goflow deployed to:  0x8A128E3148C61849AD0faA619d69d8bE311a4152
// forum deployed to:  0xc24f9a8082f7BC1ec076ec9869837a52521D2F66
// matic deployed to:  0x21B0b3a265fEfC1A76B46E538D74dC92814dA8cB
// AMM deployed to:  0x5Cc784BDC84A26676A92ad389714B0c7a25B4d33

export default config;