// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract KarmaVesting is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    address public immutable beneficiary;
    uint64 public immutable start;
    uint64 public immutable cliff;
    uint64 public immutable duration;
    
    uint256 public released;

    event TokensReleased(uint256 amount);

    constructor(
        address _token,
        address _beneficiary,
        uint64 _start,
        uint64 _cliffDuration,
        uint64 _duration
    ) Ownable(msg.sender) {
        require(_beneficiary != address(0), "Beneficiaire zero");
        require(_cliffDuration <= _duration, "Cliff plus long que duration");
        
        token = IERC20(_token);
        beneficiary = _beneficiary;
        start = _start;
        cliff = _start + _cliffDuration;
        duration = _duration;
    }

    function vestedAmount(uint64 timestamp) public view returns (uint256) {
        uint256 totalAllocation = token.balanceOf(address(this)) + released;

        if (timestamp < cliff) {
            return 0;
        } else if (timestamp >= start + duration) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }

    function release() public {
        uint256 amount = vestedAmount(uint64(block.timestamp)) - released;
        require(amount > 0, "Rien a liberer");

        released += amount;
        token.safeTransfer(beneficiary, amount);

        emit TokensReleased(amount);
    }
}