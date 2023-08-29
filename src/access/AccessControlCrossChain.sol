// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControlCrossChain.sol)

pragma solidity ^0.8.4;

import "./AccessControl.sol";
import "../crosschain/CrossChainEnabled.sol";

/**
 * A 和 B 两条链，都有相同的地址x
    A链：x对合约有roleA，
    B链的x地址就自动有了roleA，为了防止这种漏洞，就有了 CROSSCHAIN_ALIAS 和 _crossChainRoleAlias
 */
abstract contract AccessControlCrossChain is AccessControl, CrossChainEnabled {
    bytes32 public constant CROSSCHAIN_ALIAS = keccak256("CROSSCHAIN_ALIAS");

    /**
     * @dev See {AccessControl-_checkRole}.
     */
    function _checkRole(bytes32 role) internal view virtual override {
        if (_isCrossChain()) {
            _checkRole(_crossChainRoleAlias(role), _crossChainSender());
        } else {
            super._checkRole(role);
        }
    }

    /**
     * @dev Returns the aliased role corresponding to `role`.
     */
    function _crossChainRoleAlias(bytes32 role) internal pure virtual returns (bytes32) {
        return role ^ CROSSCHAIN_ALIAS;
    }
}
