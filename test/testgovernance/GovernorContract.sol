// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../src/governance/Governor.sol";
import "../../src/governance/extensions/GovernorCountingSimple.sol";
import "../../src/governance/extensions/GovernorVotes.sol";
import "../../src/governance/extensions/GovernorVotesQuorumFraction.sol";
import "../../src/governance/extensions/GovernorTimelockControl.sol";
import "../../src/governance/extensions/GovernorSettings.sol";
/*
    Governor 是主流程类
    GovernorSettings 定义了参数， 发起后延长多少区块，提案后投票多长时间，投票是否需要门槛
    GovernorCountingSimple 统计投票的数量
    GovernorVotesQuorumFraction 定义了投票人数 百分比
    GovernorTimelockControl  调用构造函数传进来了的参数 _timelock
    GovernorVotes内部调用构造函数传进来了的参数 _token

*/
//contract GovernorContract is Governor,GovernorSettings,GovernorCountingSimple,GovernorVotes,GovernorVotesQuorumFraction,GovernorTimelockControl{
contract GovernorContract is GovernorSettings,GovernorCountingSimple,GovernorVotesQuorumFraction,GovernorTimelockControl{
    constructor(
        IVotes _token,
        TimelockController _timelock,
        uint256 _quorumPercentage,
        uint256 _votingPeriod,
        uint256 _votingDelay,
        uint256 _proposalThreshold
    )

        Governor("GovernorContract")
        GovernorSettings(
            _votingDelay, // 延迟几个区块，才开始投票
            _votingPeriod, // 45818, /* 1 week */ // voting period
            _proposalThreshold // 门槛
        )
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(_quorumPercentage)
        GovernorTimelockControl(_timelock)
    {}

    modifier canLog() override(Governor,GovernorCountingSimple) {
        if(DEBUG_GovernorContract){
            _;
        }
    }
    function getContractName() view public override(Governor,GovernorCountingSimple) returns(string memory){
        return 'GovernorContract';
    }

    function getBlock() public view returns (uint256) {
        return  block.number;
    }

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    // The following functions are overrides required by Solidity.

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function getVotes(address account, uint256 blockNumber)
        public
        view
        override(IGovernor, Governor)
        returns (uint256)
    {
        return super.getVotes(account, blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override(Governor, IGovernor) returns (uint256) {
        return super.propose(targets, values, calldatas, description);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
