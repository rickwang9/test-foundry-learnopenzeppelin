// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../src/access/Ownable.sol";
/*
    需要投票修改的合约，
    owner权限会修改为治理合约的timeLock合约
*/
contract TargetContract is Ownable{

    uint256 private fee;

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function getFee() public view returns(uint256) {
        return fee;
    }

    function getBytes(uint256 _num) public pure returns(bytes memory) {
        return abi.encodeWithSignature("setFee(uint256)", _num);
    }

    function getBytes32() public pure returns(bytes32) {
        return bytes32(0);
    }

}

