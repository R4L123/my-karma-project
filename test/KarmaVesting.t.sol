// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {KarmaVesting} from "../src/KarmaVesting.sol";
import {KarmaToken} from "../src/KarmaToken.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract KarmaVestingTest is Test {
    using SafeERC20 for KarmaToken;
    KarmaToken token;
    KarmaVesting vesting;

    address beneficiary = makeAddr("beneficiary");
    uint64 startTime;
    uint64 duration = 365 days;
    uint64 cliffDuration = 90 days;
    uint256 totalAllocation = 100000 * 10 ** 18;

    function setUp() public {
        token = new KarmaToken("Karma", "KRM", 1000000);
        startTime = uint64(block.timestamp);

        vesting = new KarmaVesting(address(token), beneficiary, startTime, cliffDuration, duration);
        token.safeTransfer(address(vesting), totalAllocation);
    }

    function test_ReleaseAfterCliff() public {
        uint64 halfDuration = duration / 2;
        vm.warp(startTime + halfDuration);

        uint256 expected = totalAllocation / 2;

        assertApproxEqAbs(vesting.vestedAmount(uint64(block.timestamp)), expected, 1e18);

        vesting.release();
        assertEq(token.balanceOf(beneficiary), expected);
        assertEq(vesting.released(), expected);
    }
}
