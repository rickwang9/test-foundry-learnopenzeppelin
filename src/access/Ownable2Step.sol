// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 *
 */
abstract contract Ownable2Step is Ownable {
    //    owner候选人
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     *  返回owner候选人地址
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * owner 提名了owner候选人
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * 设置owner，并且删除owner候选人。 注意newOwner和_pendingOwner可能是同一人，也可能是两个不同的人
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * owner候选人接收了提名，成为owner
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}
