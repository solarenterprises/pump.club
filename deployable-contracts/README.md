# How to add blockchain support for pump.club 

## Requirements

- Must be a EVM compatible blockchain
- Must support Solidity
- Remix IDE
- Funds (either mainnet or testnet coins) on your desired blockchain

## Instructions

Deploy the implementations first on the blockchain using Remix IDE. On Remix IDE, select the main contract to compile (e.g. BondingCurve main contract to compile is in contract/BondingCurve.sol, etc.), then head to "Deploy & run transactions", for the environment dropdown select the Injected Provider - MetaMask. Here you can connect to Avalanche Fuji Testnet for example and it will "Custom (chainid of your network) network". Now click on "Deploy". (Dont forget to deploy Foundry.sol as the last one!)

Now open the explorer and find the transaction hash and copy your contract address.

Get the implementation contract addresses and modify the evm/BondingCurve.json, evm/Factory.json, evm/Foundry.json and evm/Lock.json.

Within each json, you need to add your blockchain chainid (e.g. 43114 for Avalanche) and the contract address.

Current (sepolia, already supported):

```
.."11155111":"0xB2A3d4E68276a08BcF35eB60c4F8E10cB6Ea9177"..
```

Avalanche (AVAX):

```
.."43114":"0x.."..
```

## Testnet Deployments

Here i deployed them for Avalanche Fuji Testnet:

Owner address: [0x81CEd07b6c1bD22061B4F80a5F778E592233d0fE](https://testnet.snowtrace.io/address/0x81CEd07b6c1bD22061B4F80a5F778E592233d0fE)

BondingCurve: [0x4c550e65B20691F92CfD3c6769805facF20C6776](https://testnet.snowtrace.io/address/0x4c550e65B20691F92CfD3c6769805facF20C6776)

Factory: [0x4DD970B1E2A43557dc1Db95c9cA3c3C1BA43680A](https://testnet.snowtrace.io/address/0x4DD970B1E2A43557dc1Db95c9cA3c3C1BA43680A)

Token: [0xB2AfbbE79168a82fBef048e75a10d0298b348AC7](https://testnet.snowtrace.io/address/0xB2AfbbE79168a82fBef048e75a10d0298b348AC7)

## NonfungiblePositionManager Address

Unfortunately, there is no NonfungiblePositionManager available for Avalanche Fuji Testnet, which is mentioned [here](https://github.com/Uniswap/docs/blob/main/docs/contracts/v3/reference/deployments/AVAX-Deployments.md). This is necessary for the Lock Solidity contract deployment. However, we can still use this NonfungiblePositionManager mainnet address as a placeholder to make it deploy.

Avalanche Mainnet NonfungiblePositionManager Address

NonfungiblePositionManager | 0x655C406EBFa14EE2006250925e54ec43AD184f8B

Lock deployment: [0x400d8249646F1560AB8A82200637eE6f2BC2aA37](https://testnet.snowtrace.io/address/0x400d8249646F1560AB8A82200637eE6f2BC2aA37)

## Foundry Inputs contract (settings)

| Implementation    | Address |
| -------- | ------- |
| getBondingCurveImplementation  | 0x4c550e65B20691F92CfD3c6769805facF20C6776 (contract address)    |
| getDeploymentFee | 18000000000000000 (uint256)     |
| getFactoryImplementation    | 0x4DD970B1E2A43557dc1Db95c9cA3c3C1BA43680A (contract address)    |
| getLockImplementation    | 0x400d8249646F1560AB8A82200637eE6f2BC2aA37 (contract address)    |
| getTokenImplementation    | 0xB2AfbbE79168a82fBef048e75a10d0298b348AC7 (contract address)    |
| isDeployedClone    | cloneAddress (address) -> (bool)    |
| owner    | 0x81CEd07b6c1bD22061B4F80a5F778E592233d0fE (contract address)    |
| paused    | False (bool)    |

Finally, the Foundry deployment:

Foundry: [0x8Cc2270308616eDC5b93B82f8386328110614254](https://testnet.snowtrace.io/address/0x8Cc2270308616eDC5b93B82f8386328110614254)