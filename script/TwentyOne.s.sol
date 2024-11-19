// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TwentyOne} from "../src/TwentyOne.sol";

contract TwentyOneScript is Script {
    TwentyOne public twentyOne;
    address CASINO = address(1);
    address USER = address(1);

    function setUp() public {
        // Deploy the TwentyOne contract
        twentyOne = new TwentyOne();
        console.log("TwentyOne contract deployed at:", address(twentyOne));
    }

    function run() public {
        vm.prank(CASINO);
        // Fund the contract with some ether (simulate the casino's balance)
        payable(address(twentyOne)).transfer(10 ether);
        console.log("Funded contract with 10 ether.");
    }

    function startGameTest() public {
        vm.prank(USER);
        // Player starts a game with a bet of 1 ether
        twentyOne.startGame{value: 1 ether}();
        console.log("Game started for player:", USER);
    }
}
