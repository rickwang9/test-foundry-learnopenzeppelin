// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../src/token/ERC20/extensions/ERC20Votes.sol";
/*
  治理Token必须继承ERC20Votes
*/
contract GovernorToken is ERC20Votes {

  constructor() ERC20("GovernanceToken", "GT") ERC20Permit("GovernanceToken") {
    _mint(msg.sender, 10000 * 10 ** decimals());
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override(ERC20Votes) {
    super._afterTokenTransfer(from, to, amount);
  }

  function _mint(address to, uint256 amount) internal override(ERC20Votes) {
    super._mint(to, amount);
  }

  function _burn(address account, uint256 amount) internal override(ERC20Votes) {
    super._burn(account, amount);
  }
}


