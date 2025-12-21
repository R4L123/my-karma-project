// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {KarmaVesting} from "../src/KarmaVesting.sol";
import {KarmaToken} from "../src/KarmaToken.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; // Import nécessaire

contract DeployVesting is Script {
    using SafeERC20 for KarmaToken; // Utilisation de SafeERC20 pour KarmaToken

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        KarmaToken token = new KarmaToken("Karma", "KRM", 1000000);

        KarmaVesting vesting =
            new KarmaVesting(address(token), beneficiaryAddress, uint64(block.timestamp), 90 days, 365 days);

        token.safeTransfer(address(vesting), 100000 * 10 ** 18);

        vm.stopBroadcast();
    }
}
