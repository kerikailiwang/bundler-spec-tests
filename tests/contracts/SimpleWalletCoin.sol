// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@account-abstraction/contracts/interfaces/IAccount.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "./TestCoin.sol";

contract SimpleWalletCoin is IAccount {
    address ep;
    uint256 public state;

    TestCoin public coin;

    constructor(address _ep, address _coin) payable {
        ep = _ep;
        (bool req, ) = address(ep).call{value: msg.value}("");
        require(req);
        coin = TestCoin(_coin);
    }

    function addStake(IEntryPoint _ep, uint32 delay) public payable {
        _ep.addStake{value: msg.value}(delay);
    }

    function setState(uint _state) external {
        state = _state;
    }

    function setCoinState(uint _state) external {
        coin.pause(_state);
    }

    function fail() external {
        revert("test fail");
    }

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32,
        uint256 missingWalletFunds
    ) external override returns (uint256 validationData) {
        if (missingWalletFunds > 0) {
            msg.sender.call{value: missingWalletFunds}("");
        }
        require(state++ == 0, "state is not 0");
        bytes2 sig = bytes2(userOp.signature);
        require(sig != 0xdead, "testWallet: dead signature");
        return sig == 0xdeaf ? 1 : 0;
    }
}
