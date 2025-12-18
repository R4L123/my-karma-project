// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Utilisation des "Named Imports" pour supprimer les notes du linter
import {Script} from "forge-std/Script.sol";
import {KarmaToken} from "../src/KarmaToken.sol";

contract DeployKarma is Script {
    function run() external returns (KarmaToken) {
        uint256 deployerPrivateKey =
            vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));

        vm.startBroadcast(deployerPrivateKey);

        KarmaToken karma = new KarmaToken("KarmaToken", "KRM", 1000000);

        vm.stopBroadcast();
        return karma;
    }
}
