// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {KarmaToken} from "../src/KarmaToken.sol";

contract KarmaTokenTest is Test {
    KarmaToken public karmaToken;
    address public deployer;
    address public user1;
    address public user2;

    function setUp() public {
        deployer = makeAddr("deployer");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // deployment et creation de 1 million de token
        vm.startPrank(deployer);
        karmaToken = new KarmaToken("KarmaToken", "KRM", 1000000);

        // distribution 
        bool s1 = karmaToken.transfer(user1, 1000 * 10 ** karmaToken.decimals());
        require(s1 == true, "Transfer failed");

        bool s2 = karmaToken.transfer(user2, 500 * 10 ** karmaToken.decimals());
        require(s2 == true, "Transfer failed");

        vm.stopPrank();
    }

    // --- Tests de succès ---

    function test_InitialState() public view {
        assertEq(karmaToken.totalSupply(), 1000000 * (10 ** karmaToken.decimals()));
        assertEq(karmaToken.balanceOf(user1), 1000 * (10 ** karmaToken.decimals()));
        assertEq(karmaToken.balanceOf(user2), 500 * (10 ** karmaToken.decimals()));
        assertEq(karmaToken.owner(), deployer);
    }

    function test_Transfer() public {
        vm.startPrank(user1);
        /* * Notes Test:
         * Verifie la reception des Tokens par l'user2 depuis l'user1
         */
        bool success = karmaToken.transfer(user2, 100 * (10 ** karmaToken.decimals()));
        assertTrue(success);
        vm.stopPrank();

        assertEq(karmaToken.balanceOf(user1), 900 * (10 ** karmaToken.decimals()));
        assertEq(karmaToken.balanceOf(user2), 600 * (10 ** karmaToken.decimals()));
    }

    function test_GiveKarma() public {
        vm.startPrank(user1);
        /* * Notes Test:
         * Verifie la reception des Tokens par l'user2
         */
        karmaToken.giveKarma(user2, 50);
        vm.stopPrank();

        assertEq(karmaToken.karmaScores(user2), 50);
    }

    // --- Tests d'erreur ---

    function test_Revert_GivingKarmaToUrself() public {
        vm.startPrank(user1);
        /* * Notes Test:
         * Doit retourner l'erreur car on ne peut pas s'envoyer soit meme des Tokens
         */

        vm.expectRevert("Vous ne pouvez pas vous donner du Karma a vous meme");

        karmaToken.giveKarma(user1, 10);
        vm.stopPrank();
    }

    function test_Revert_MintingAsNonOwner() public {
        vm.startPrank(user1);

        /* * Notes Test:
         * Doit retourner l'erreur car seulement l'Owner peut minter des nouveaux token
         */
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));

        karmaToken.mintNewTokens(100);
        vm.stopPrank();
    }
}
