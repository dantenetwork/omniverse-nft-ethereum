# omniverse-nft-ethereum

This is the EVM version of Omniverse-NFT, which is under developing now and the functionality it provides is the flow of NFT between EVM-compatible chains and Flow.

## Experience
### Open Remix
Open [Remix](remix.ethereum.org/) with Google/Firefox brower.

### Import Code
Import the smart contract code in `contracts` into the project in *Remix*, or use the localhost workspace to load the code.

### Compile Contracts
Compile `App.sol` and `OmniverNFT.sol` seperately.

### Switch Network

### Load Contracts

### Contract Addresses
- App: 
- OmniverseNFT:

### Run
This function is used together with the [Omniverse NFT on Flow](https://github.com/dantenetwork/flow-sdk#/nft-bridgeomniverse-nft-coming-soon).

#### From PlatON to Flow
- Receive the NFT sent from Flow.

Firstly, send an NFT from Flow to PlatON, the tutorial is shown [here](https://github.com/dantenetwork/flow-sdk#/nft-bridgeomniverse-nft-coming-soon).

- Claim the NFT on PlatON

The receive must call the method `claimToken` to really get the NFT.

- Send an NFT from PlatON to Flow

Call the method `ccsUnlock` in the contract `App` on `PlatON`. Ensure the sender is the owner of the NFT which will be sent.

- Claim the NFT on Flow

The tutorial is shown [here](https://github.com/dantenetwork/flow-sdk#/nft-bridgeomniverse-nft-coming-soon).