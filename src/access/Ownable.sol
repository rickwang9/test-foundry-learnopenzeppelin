// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
    一个帐户（所有者）对函数有访问权
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * 创建合约的用户作为owner
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev 检查调用者是否有owner权限
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev 返回owner的地址
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev 判断调用者是否是owner
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
        任何人都不再有owner权限，这个自杀操作只能owner自己调用
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
        将owner权限移交给不是非零地址的人
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
        将owner权限移交他人
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
