pragma solidity ^0.8.7;
import "forge-std/Test.sol";
import "./GovernorToken.sol";
import "./TargetContract.sol";
import "./TimeLock.sol";
import "./Utilities.sol";
import "./GovernorContract.sol";
import {Vm} from "forge-std/Vm.sol";
/*

*/
// forge test --contracts ./test/testgovernance/TestGovernanceContract.sol -vvvv
contract TestGovernanceContract  is DSTest{
    Utilities utilities;
    address deployer;
    address addr1;
    address addr2;
    Vm internal vm = Vm(HEVM_ADDRESS);
    uint8 VOTE_FOR = 1;
    uint8 VOTE_AGAINST = 0;
    uint8 VOTE_ABSTAIN = 2;
    string reason = "just for practice";

    //投票通过后，最少延长120(秒),才能执行任务
    uint MIN_DELAY = 120;

    //需要总投票人数的2%才能通过，否则放弃提案
    uint QUORUM_PERCENTAGE = 2;
    //投票在3个区块内完成，以区块为单位，而不是时间
    uint VOTING_PERIOD = 3;
    //发起提案后，经过1个区块后才能投票
    uint VOTING_DELAY = 1;
    uint PROPOSAL_THRESHOLD = 10000;

    //修改参数的方法
    string FUNC = "setFee(uint256)";
    //修改参数的值
    uint NEW_FEE_VALUE = 5;
    //修改提案的描述
    string PROPOSAL_DESCRIPTION = "Change target age";
//    string PROPOSAL_DESCRIPTION = "Change target age#proposer=0x3333333333333333333333333333333333333333";

    address ADDRESS_ZERO = 0x0000000000000000000000000000000000000000;
    string[] userLabels;


    GovernorToken tokenContract;
    TimeLock timeLockContract;
    TargetContract targetContract;
    GovernorContract governorContract;
    function setUp() public {
        utilities = new Utilities();

        uint userCount = 3;
        uint userInitialFunds = 100 ether;

        userLabels = new string[](3);//Member "push" is not available in string[] memory outside of storage.
        userLabels.push("Owner");
        userLabels.push("addr1");
        userLabels.push("addr2");

        address payable[] memory users = utilities.createUsers(userCount, userInitialFunds, userLabels);
        deployer = users[0];
        addr1 = users[1];
        addr2= users[2];

        console.log("address(this):", address(this));
        console.log("deployer:", deployer);
        console.log("addr1:", addr1);
        console.log("addr2:", addr2);

        console.log("addr1 balance",addr1.balance);
        console.log("addr2 balance",addr2.balance);
        console.log("deployer balance",deployer.balance);

        //部署mytoken合约
        tokenContract = new GovernorToken();
        console.log("tokenContract deployed to:", address(tokenContract));

        // timelock
        // 部署timelock合约
        // 投票通过后，最少延长MIN_DELAY时间(秒)再执行任务
        address[] memory proposers;
        address[] memory executors;
        timeLockContract = new TimeLock(MIN_DELAY, proposers, executors, deployer);
        console.log("TimeLockContract deployed to:", address(timeLockContract));

        //Target
        //部署Target合约
        targetContract = new TargetContract();
        console.log("TargetContract deployed to:", address(targetContract));

        //governor
        //部署governor合约, js不传对象，还是传地址
        governorContract = new GovernorContract(tokenContract, timeLockContract,
            QUORUM_PERCENTAGE, VOTING_PERIOD, VOTING_DELAY, PROPOSAL_THRESHOLD);
        console.log("GovernorContract deployed to:", address(governorContract));

        //给其他账号授权才能投票，address(this)给deployer
        tokenContract.delegate(deployer);
        //
        targetContract.transferOwnership(address(timeLockContract));
        console.log('targetContract.owner', targetContract.owner());

        bytes32 proposerRole = timeLockContract.PROPOSER_ROLE();//提案角色，实测不生效
        bytes32 executorRole = timeLockContract.EXECUTOR_ROLE();//执行提案角色
        bytes32 adminRole = timeLockContract.TIMELOCK_ADMIN_ROLE();//角色的管理员角色
        console.logBytes32(proposerRole);
        console.logBytes32(executorRole);
        console.logBytes32(adminRole);

        //在timeLock中，给governorContract分配提案角色
        vm.startPrank(deployer);
        timeLockContract.grantRole(proposerRole, address(governorContract)); //timeLockC给给自己分配执行角色
        timeLockContract.grantRole(executorRole, ADDRESS_ZERO);//任何人都可以执行
        timeLockContract.grantRole(executorRole, address(governorContract));
        timeLockContract.revokeRole(adminRole, deployer);//撤回部署人管理员角色
        vm.stopPrank();
    }

    function moveBlocks(uint amount) public{
        console.log("Moving blocks...................", amount);
        utilities.mineBlocks(amount);
    }

    function moveTime(uint amount) public{
        console.log("Moving moveTime.................",amount);
        utilities.mineTime(amount);
    }


    function testRightWay() public{

        // 发起调用Target setFee方法的提案
        address[] memory targetContractAddress = new address[](1);
        targetContractAddress[0] = address(targetContract);

        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature(FUNC, NEW_FEE_VALUE);

        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        moveBlocks(2);
        /*
            1 创建提案
        */
        vm.startPrank(deployer);
//        vm.prank(deployer);
        uint256 proposalId = governorContract.propose(targetContractAddress ,values, calldatas,PROPOSAL_DESCRIPTION);
//        vm.startPrank(deployer);
        //获取提案的状态
        governorContract.SLOG("proposalState after propose :" ,governorContract.state(proposalId));

        //发起提案后的状态的pendding,这时候还不能投票，我们新增1个区块后才能投票(VOTING_DELAY=1),所以我们给addr1在转1000
        moveBlocks(2);

        //proposalId状态会变成active,这种情况下就可以投票 active
        governorContract.SLOG("proposalState after 2 block :" ,governorContract.state(proposalId));

        //投票
        //VOTE_Against 0 反对,VOTE_FOR 1 赞同,VOTE_Abstain 2弃权

        governorContract.castVoteWithReason(proposalId, VOTE_FOR, reason);
        //**这里讲解投反对、赞成、弃权 **/
        governorContract.SLOG("proposalState after castVoteWithReason :" ,governorContract.state(proposalId));

        //从投票开始的区块算起，后面的3个区块是投票时间,我们做4个交易走完投票 js和remix都是默认transfer一次走一个区块，
        moveBlocks(4);

        //这时候提案状态为投票成功 success
        governorContract.SLOG("proposalState after 4 block:" ,governorContract.state(proposalId));

        //将提案成功后才放入队列，才开始加时间。
        bytes32 descriptionHash = keccak256(bytes(PROPOSAL_DESCRIPTION));
        uint queueTx = governorContract.queue(targetContractAddress, values, calldatas, descriptionHash);

        moveTime(MIN_DELAY +1);
//        moveBlocks(1);
//        moveBlocks(1);

        //这时候状态提案为5(Queued)
        governorContract.SLOG("proposalState after moveTime:" ,governorContract.state(proposalId));

        //执行提案execute
        console.log("Executing...");
        governorContract.execute(targetContractAddress, values, calldatas, descriptionHash);
        //这时候状态提案为6(Executed)
        governorContract.SLOG("proposalState after execute:" ,governorContract.state(proposalId));

        //获取target的age值
        uint fee = targetContract.getFee();
        console.log('fee ', fee);
        //        expect(await targetContract.getAge()).to.equal(NEW_FEE_VALUE);
        vm.stopPrank();
    }



}



















