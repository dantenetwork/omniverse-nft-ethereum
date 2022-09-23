// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@hthuang/contracts/ContractBase.sol";
import "./OmniverseNFT.sol";

contract App is ContractBase {
    struct NFTInfo {
        uint64 uuid;
        string domain;
        uint64 id;
        string tokenURL;
        address receiver;
        bytes32 hashValue;
    }

    struct FlowContract {
        string chainName;
        bytes contractAddress;
        bytes action;
    }

    // NFT contract
    OmniverseNFT public nftContract;
    // NFT list that are waiting for being claimed
    NFTInfo[] public pendingNFTList;
    // Destination chain contract information
    FlowContract public flowContract;

    constructor(address _address) {
        nftContract = OmniverseNFT(_address);
    }

    function setFlowContract(string calldata _chainName, bytes calldata _contract, bytes calldata _action) external onlyOwner {
        flowContract.chainName = _chainName;
        flowContract.contractAddress = _contract;
        flowContract.action = _action;
    }

    /**
     * @dev Mints a token to a user, it is cross-chain invoked.
     */
    function ccrMint(Payload calldata _payload) public returns (uint256) {
        if (msg.sender != address(crossChainContract)) {
            return 100;
        }

        NFTInfo storage nftInfo = pendingNFTList.push();
        (nftInfo.uuid) = abi.decode(_payload.items[0].value, (uint64));
        (nftInfo.domain) = abi.decode(_payload.items[1].value, (string));
        (nftInfo.id) = abi.decode(_payload.items[2].value, (uint64));
        (nftInfo.tokenURL) = abi.decode(_payload.items[3].value, (string));
        (bytes memory bReceiver) = abi.decode(_payload.items[4].value, (bytes));
        address receiver;
        assembly {
            receiver := mload(add(bReceiver, 20))
        }
        nftInfo.receiver = receiver;
        (bytes memory bHash) = abi.decode(_payload.items[5].value, (bytes));
        bytes32 hashValue;
        assembly {
            hashValue := mload(add(bHash, 32))
        }
        nftInfo.hashValue = hashValue;

        return 0;
    }

    /**
     * @dev Claims a token in the pending list
     */
    function claimToken(uint256 tokenId, string calldata answer) external {
        bool found = false;
        uint256 index = 0;
        for (uint256 i = 0; i < pendingNFTList.length; i++) {
            index = i;
            if (pendingNFTList[i].uuid == tokenId) {
                found = true;
                break;
            }
        }
        require(found, "Token not exists");

        bytes32 h = keccak256(abi.encodePacked(answer));
        require(h == pendingNFTList[index].hashValue, "Wrong answer");
        require(msg.sender == pendingNFTList[index].receiver, "Caller not the receiver");

        nftContract.mint(msg.sender, tokenId, pendingNFTList[index].tokenURL);
        pendingNFTList[index] = pendingNFTList[pendingNFTList.length - 1];
        pendingNFTList.pop();
    }

    /**
     * @dev Burns a token of a user, then a cross-chain call will be called to
     *      unlock a token on Flow.
     */
    function ccsUnlock(uint256 tokenId, bytes calldata receiver, bytes32 hashValue) external {
        address owner = nftContract.ownerOf(tokenId);
        require(owner == msg.sender, "Caller not owner");

        nftContract.burn(tokenId);

        // Construct payload
        Payload memory data;
        data.items = new PayloadItem[](3);
        PayloadItem memory item0 = data.items[0];
        item0.name = "uuid";
        item0.msgType = MsgType.EvmU64;
        item0.value = abi.encode(uint64(tokenId));
        PayloadItem memory item1 = data.items[1];
        item1.name = "receiver";
        item1.msgType = MsgType.Bytes;
        item1.value = receiver;
        PayloadItem memory item2 = data.items[2];
        item2.name = "hashValue";
        item2.msgType = MsgType.Bytes;
        item2.value = abi.encode(hashValue);

        ISentMessage memory message;
        message.toChain = flowContract.chainName;
        message.session = Session(0, 0, "", "", "");
        message.content = Content(flowContract.contractAddress, flowContract.action, data);

        crossChainContract.sendMessage(message);
    }

    function getPendingListNumber() external view returns (uint256) {
        return pendingNFTList.length;
    }

    function verify(
        string calldata /*_chainName*/,
        bytes4 /*_funcName*/,
        bytes calldata /*_sender*/
    ) public view virtual returns (bool) {
        return true;
    }
}