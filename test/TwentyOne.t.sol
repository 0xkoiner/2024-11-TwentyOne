// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TwentyOne} from "../src/TwentyOne.sol";
import {AttackTwentyOne} from "../src/AttackTwentyOne.sol";

contract TwentyOneTest is Test {
    TwentyOne public twentyOne;
    AttackTwentyOne public attackTwentyOne;

    address player1 = address(0x123);
    address player2 = address(0x456);
    uint256 public returnsCounter = 0;
    uint256 public wonsCounter = 0;

    function setUp() public {
        twentyOne = new TwentyOne();
        attackTwentyOne = new AttackTwentyOne(address(twentyOne), player1);
        vm.deal(player1, 10 ether); // Fund player1 with 10 ether
        vm.deal(player2, 10 ether); // Fund player2 with 10 ether
        vm.deal(address(twentyOne), 20 ether); // Fund Contract 10 ether
    }

    function test_StartGame() public {
        vm.startPrank(player1); // Start acting as player1

        uint256 initialBalance = player1.balance;

        // Start the game with 1 ether bet
        twentyOne.startGame{value: 1 ether}();

        // Check that the player's balance decreased by 1 ether
        assertEq(player1.balance, initialBalance - 1 ether);

        // Check that the player's hand has two cards
        uint256[] memory playerCards = twentyOne.getPlayerCards(player1);
        assertEq(playerCards.length, 2);

        vm.stopPrank();
    }

    function test_Hit() public {
        vm.startPrank(player1); // Start acting as player1

        twentyOne.startGame{value: 1 ether}();

        // Initial hand size should be 2
        uint256[] memory initialCards = twentyOne.getPlayerCards(player1);
        assertEq(initialCards.length, 2);

        // Player hits (takes another card)
        twentyOne.hit();

        // Hand size should increase to 3
        uint256[] memory updatedCards = twentyOne.getPlayerCards(player1);
        assertEq(updatedCards.length, 3);

        vm.stopPrank();
    }

    function test_Call_PlayerWins() public {
        /// @audit - The contract deposited only 1 ether of
        /// the player, but the contract not have any ether to send 2 after winning
        vm.startPrank(player1); // Start acting as player1
        console.log("player1: ", player1);
        console.log("twentyOne balance: ", address(twentyOne).balance);

        twentyOne.startGame{value: 1 ether}();

        // Mock the dealer's behavior to ensure player wins
        // Simulate dealer cards by manipulating state
        console.log("contract balance: ", address(twentyOne).balance);

        vm.mockCall(
            address(twentyOne),
            abi.encodeWithSignature("dealersHand(address)", player1),
            abi.encode(18) // Dealer's hand total is 18
        );

        uint256 initialPlayerBalance = player1.balance;
        console.log("initialPlayerBalance: ", initialPlayerBalance);
        // Player calls to compare hands
        twentyOne.call();

        // Check if the player's balance increased (prize payout)
        uint256 finalPlayerBalance = player1.balance;
        console.log("finalPlayerBalance: ", finalPlayerBalance);

        assertGt(finalPlayerBalance, initialPlayerBalance);

        vm.stopPrank();
    }

    function testCompareCardsOfDealerVSPlayer() public {
        uint256[] memory playerCardsArr = twentyOne.getPlayerCards(player1);
        uint256[] memory dealerCardsArr = twentyOne.getDealerCards(player1);

        assertEq(playerCardsArr, dealerCardsArr);
        vm.startPrank(player1);
        uint256 playerCards = twentyOne.startGame{value: 1 ether}();

        // uint256[] memory availableCards = twentyOne.getAvailableCards(player1);
        // console.log("availableCards L: ", availableCards.length);
        // for (uint256 i; i < availableCards.length; i++) {
        //     console.log("availableCard: ", availableCards[i]);
        // }

        console.log("playerCards: ", playerCards);
        vm.stopPrank();

        uint256[] memory playerCardsArrAfterCall = twentyOne.getPlayerCards(
            player1
        );
        uint256[] memory dealerCardsArrAfterCall = twentyOne.getDealerCards(
            player1
        );

        console.log(
            "dealerCardsArrAfterCall L: : ",
            dealerCardsArrAfterCall.length
        );
        uint256 sum;
        for (uint256 i; i < playerCardsArrAfterCall.length; i++) {
            console.log(
                "playerCardsArrAfterCall: ",
                playerCardsArrAfterCall[i]
            );
            sum = sum + (playerCardsArrAfterCall[i] % 13);
        }
        console.log("calc sum: ", sum);
        assertNotEq(playerCardsArrAfterCall, dealerCardsArrAfterCall);
    }
}
