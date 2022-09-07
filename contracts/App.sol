// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./OmniverseNFT.sol";
import "@hthuang/contracts/ContractBase.sol";

contract OmniverseNFT is ContractBase {
    struct NFTInfo {
        string uuid;
        string tokenURL;
        address receiver;
        bytes32 hashValue;
        string domain;
        uint64 id;
    }

    OmniverseNFT public nftContract;
    // pendingNFTList

    // Only the cross-chain contract
    modifier onlyCC() {
        require(msg.sender == crossChainContract.address, "Caller not the CC");
        _;
    }

    constructor(address _address) {
        nftContract = OmniverseNFT(_address);
    }

    /**
     * @dev Mints a token to a user, it is cross-chain invoked.
     */
    function ccMint() external onlyCC {

    }
}