// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TwentyOne} from "../src/TwentyOne.sol";

contract TwentyOneScript is Script {
    TwentyOne public twentyOne;
    address CASINO = address(1);
    address USER = address(1);
    uint256 STARTING_AMOUNT = 20 ether;

    function setUp() public {
        // Deploy the TwentyOne contract
        twentyOne = new TwentyOne();
        console.log("TwentyOne contract deployed at:", address(twentyOne));
        vm.deal(CASINO, STARTING_AMOUNT);
        vm.deal(USER, STARTING_AMOUNT);
    }

    function run() public {
        vm.prank(CASINO);
        console.log("Casino Balance: ", CASINO.balance);
        // Fund the contract with some ether (simulate the casino's balance)
        // payable(address(twentyOne)).transfer(10 ether);
        (bool success, ) = payable(address(twentyOne)).call{value: 10 ether}(
            ""
        );
        if (!success) {
            return;
        }
        console.log("Funded contract with 10 ether.");
    }

    function startGameTest() public {
        vm.prank(USER);
        // Player starts a game with a bet of 1 ether
        twentyOne.startGame{value: 1 ether}();
        console.log("Game started for player:", USER);
    }
}
