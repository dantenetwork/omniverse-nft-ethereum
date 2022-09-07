// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./OmniverseNFT.sol";
import "@hthuang/contracts/ContractBase.sol";

contract OmniverseNFT is ContractBase {
    struct NFTInfo {
        string uuid;
        string domain;
        uint64 id;
        string tokenURL;
        address receiver;
        bytes32 hashValue;
    }

    OmniverseNFT public nftContract;
    NFTInfo[] public pendingNFTList;

    constructor(address _address) {
        nftContract = OmniverseNFT(_address);
    }

    /**
     * @dev Mints a token to a user, it is cross-chain invoked.
     */
    function ccMint(Payload calldata _payload) public onlyCC returns (uint256) {
        if (msg.sender != address(crossChainContract)) {
            return CALLER_NOT_CROSS_CHAIN_CONTRACT;
        }

        SimplifiedMessage memory context = getContext();

        NFTInfo storage nftInfo = pendingNFTList.push();
        (nftInfo.uuid) = abi.decode(_payload.items[0].value, (string));
        (nftInfo.domain) = abi.decode(_payload.items[0].value, (string));
        (nftInfo.id) = abi.decode(_payload.items[0].value, (uint64));
        (nftInfo.tokenURL) = abi.decode(_payload.items[0].value, (string));
        (nftInfo.receiver) = abi.decode(_payload.items[0].value, (address));
        (nftInfo.hashValue) = abi.decode(_payload.items[0].value, (bytes32));

        return 0;
    }
}