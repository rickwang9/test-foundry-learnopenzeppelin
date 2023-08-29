// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../src/governance/TimelockController.sol";

contract TimeLock is TimelockController {
  // 投票通过后，需要延长多少时间(秒)再执行任务
  // 提案地址，可以是合约的地址，也可以是钱包地址
  // 在DAO里,执行任务地址,通常是合约地址执行任务

  constructor(
    uint256 minDelay,
    address[] memory proposers,
    address[] memory executors,
    address admin
  ) TimelockController(minDelay, proposers, executors, admin) {}


  function getBlockTimestamp() public view returns(uint256) {
      return block.timestamp;
  }

}

