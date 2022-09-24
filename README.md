# omniverse-nft-ethereum

This is the EVM version of Omniverse-NFT, which is under developing now and the functionality it provides is the flow of NFT between EVM-compatible chains and Flow.

## Experience
### Open Remix
Open [Remix](remix.ethereum.org/) with Google/Firefox brower.

### Import Code
Import the smart contract code in the directory `contracts` into the project in *Remix*, or use the localhost workspace to load the code.

![image](https://user-images.githubusercontent.com/83757490/192097550-40307f7d-d58d-48d5-8629-1ac6fd235374.png)


### Compile Contracts
Compile `App.sol` and `OmniverNFT.sol` seperately.

![image](https://user-images.githubusercontent.com/83757490/192097561-3a6934cf-97d5-4039-968d-9b52c804a61d.png)


### Switch Network

Switch the network to **PlatON mainnet**, and get some tokens to pay gas fee.

- RPC: https://openapi2.platon.network/rpc
- 210425

### Load Contracts

We have deployed `App` and `OmniverseNFT` contracts for showcase, addresses of which are shown below:

- App: 0xAF43344A48EBC1629d7385B71086E067E73cEd63
- OmniverseNFT: 0x852F4bCE871FF6F256c3CdC779780ED64131A329

Load contracts with specified addresses.

![image](https://user-images.githubusercontent.com/83757490/192097839-dc93ca89-e21a-4dd0-9ecf-4ce060f98706.png)


### Run
This function is used together with the [Omniverse NFT on Flow](https://github.com/dantenetwork/flow-sdk#/nft-bridgeomniverse-nft-coming-soon).

#### From PlatON to Flow
- Receive the NFT sent from Flow.

Firstly, send an NFT from Flow to PlatON, the tutorial is shown [here](https://github.com/dantenetwork/flow-sdk#/nft-bridgeomniverse-nft-coming-soon).

- Claim the NFT on PlatON

The receiver must call the method `claimToken` to really get the NFT.

Parameters are shown below:

- tokenId: The id of the token that you want to claim
- answer: The answer to the hash which is set on Flow

![image](https://user-images.githubusercontent.com/83757490/192097866-2e14ace4-603a-4db2-ad09-8019b9dd87d9.png)


- Send an NFT from PlatON to Flow

Call the method `ccsUnlock` in the contract `App` on `PlatON`. Ensure the sender is the owner of the NFT which will be sent.

Parameters are shown below:

- tokenId: The id of the token that you want to send
- receiver: The address of the receiver which will receive the token on Flow
- hashValue: The hash of the answer which needs to be set when claiming the token on Flow

- Claim the NFT on Flow

The tutorial is shown [here](https://github.com/dantenetwork/flow-sdk#/nft-bridgeomniverse-nft-coming-soon).
