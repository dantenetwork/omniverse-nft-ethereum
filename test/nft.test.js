const BN = require('bn.js');
const utils = require('./utils');
const web3 = require('web3');
const web3js = new web3(web3.givenProvider);

const RoutersCore = artifacts.require('@hthuang/contracts/RoutersCore');
const CrossChain = artifacts.require('@hthuang/contracts/CrossChain');
const Bytes = artifacts.require('@hthuang/contracts/Bytes');
const Verify = artifacts.require('@hthuang/contracts/Verify');
const OmniverseNFT = artifacts.require("OmniverseNFT");
const App = artifacts.require("App");

contract('OmniverseNFT', function(accounts) {
    let owner = accounts[0];
    let user1 = accounts[1];
    let receiver = accounts[2];

    let crossChain;
    let routersCore;
    let nft;
    let app;
    
    let initContract = async function() {
        routersCore = await RoutersCore.new();
        let bytes = await Bytes.new();
        await CrossChain.link(bytes);
        crossChain = await CrossChain.new('PLATONEVMDEV');
        await crossChain.setRouterCoreContractAddress(routersCore.address);

        // register cross-chain contract address
        app = await App.deployed();
        nft = await OmniverseNFT.deployed();
        await app.setCrossChainContract(crossChain.address);

        // register routers
        await routersCore.registerRouter(user1);
        await routersCore.setSelectedNumber(1);
        await routersCore.selectRouters();
    }

    before(async function() {
        await initContract();
    });

    describe('Receive minting message', function() {
        it('should execute successfully', async () => {
            let to = app.address;
            let action = '0x9bee6fc1';
            let item0 = {
                name: 'uuid',
                msgType: 4,
                value: web3js.eth.abi.encodeParameter('uint64', 111),
            };
            let item1 = {
                name: 'domain',
                msgType: 0,
                value: web3js.eth.abi.encodeParameter('string', 'asdf'),
            };
            let item2 = {
                name: 'id',
                msgType: 4,
                value: web3js.eth.abi.encodeParameter('uint64', 222),
            };
            let item3 = {
                name: 'tokenURL',
                msgType: 0,
                value: web3js.eth.abi.encodeParameter('string', 'www.baidu.com'),
            };
            let item4 = {
                name: 'receiver',
                msgType: 12,
                value: web3js.eth.abi.encodeParameter('bytes', receiver),
            };
            let item5 = {
                name: 'hashValue',
                msgType: 4,
                value: web3js.eth.abi.encodeParameter('bytes', '0x4c8f18581c0167eb90a761b4a304e009b924f03b619a0c0e8ea3adfce20aee64'),
            };
            let calldata = {items: [item0, item1, item2, item3, item4, item5]};
            let argument = [1, 'FLOW', 'PLATONEVMDEV', app.address, owner, [], to, action, calldata, [0, 0, '0x11111111', '0x', '0x'], 0];
            await crossChain.receiveMessage(argument, {from: user1});
            await crossChain.getExecutableMessageId('FLOW');
            let ret = await crossChain.executeMessage('FLOW', 1);
            if (ret.logs[0].event != 'MessageExecuted') {
                console.log(ret, ret.logs[0].args);
                assert(false);
            }
            let context = await crossChain.getCurrentMessage();
            assert(new BN(context.id.toString()).eq(new BN('1')));
        });
    });

    describe('Claim tokens', function() {
        describe('Token not exists', function() {
            it('should fail', async () => {
                await utils.expectThrow(app.claimToken(222, 'asdf', {from: receiver}), 'not exists');
            });
        });
        
        describe('Wrong answer', function() {
            it('should fail', async () => {
                await utils.expectThrow(app.claimToken(111, 'answer', {from: receiver}), 'Wrong answer');
            });
        });

        describe('Token not exists', function() {
            it('should fail', async () => {
                await utils.expectThrow(app.claimToken(111, 'asdf', {from: owner}), 'not the receiver');
            });
        });

        describe('All condition satisfied', function() {
            it('should execute successfully', async () => {
                await app.claimToken(111, 'asdf', {from: receiver});
                let tokenOwner = await nft.ownerOf(111);
                assert(tokenOwner == receiver);
            });
        });
    });

    describe('Unlock tokens', function() {
        describe('Caller not owner', function() {
            it('should fail', async () => {
                await utils.expectThrow(app.ccsUnlock(111, '0x12345678', '0x1234', {from: user1}), 'not owner');
            });
        });

        describe('All condition satisfied', function() {
            it('should execute successfully', async () => {
                await app.ccsUnlock(111, '0x12345678', '0x1234', {from: receiver});
                await utils.expectThrow(nft.ownerOf(receiver), 'invalid token ID');
            });
        });
    });

    describe('Transfer NFT contract ownership', function() {
        describe('Caller not owner', function() {
            it('should fail', async () => {
                await utils.expectThrow(app.transferNFTContractOwner({from: user1}), 'not the owner');
            });
        });

        describe('Caller is owner', function() {
            it('should execute successfully', async () => {
                let nftOwner = await nft.owner();
                assert(nftOwner == app.address);
                await app.transferNFTContractOwner({from: owner});
                nftOwner = await nft.owner();
                assert(nftOwner == owner);
            });
        });
    });
});