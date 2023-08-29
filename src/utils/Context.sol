// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "forge-std/Test.sol";
/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function SLOG(string memory desc, bytes32 val) view canLog public {
        console2.logBytes32(val);
    }
    function SLOG(string memory desc, string memory val) view canLog public {
        console2.log(string(abi.encodePacked(getContractName(),'.',desc)), val);
    }
    function SLOG(string memory desc, uint256 val) view canLog public {
        console2.log(string(abi.encodePacked(getContractName(),'.',desc)), val);
    }
    function SLOG(string memory desc, bool val) view canLog public {
        console2.log(string(abi.encodePacked(getContractName(),'.',desc)), val?'true':'false');
    }
    function SLOG(string memory desc, address val) view canLog public {
        console2.log(string(abi.encodePacked(getContractName(),'.',desc)), val);
    }
    function SLOG(string memory desc) view canLog public {
        console2.log(string(abi.encodePacked(getContractName(),'.',desc)));
    }
    function getContractName() view public virtual returns(string memory){
        return '';
    }
    /*
        父类加slot， 存储的继承如果有assembly读存储可能有影响。
    */
    bool public DEBUG_TimelockController =true;//调用的不是view，因为有状态变量
    bool public DEBUG_Governor =false;//调用的不是view，因为有状态变量
    bool public DEBUG_GovernorCountingSimple =false;//调用的不是view，因为有状态变量
    bool public DEBUG_GovernorContract =false;//调用的不是view，因为有状态变量
    bool public DEBUG_AccessControl =true;//调用的不是view，因为有状态变量

    modifier canLog() virtual{
        _;
    }
}
