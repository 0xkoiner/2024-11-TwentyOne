// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TwentyOne {
    /** Type Declarations */
    struct PlayersCards {
        uint256[] playersCards; /// @q - its nesseccery for Struct? check gas with and without
    }

    struct DealersCards {
        uint256[] dealersCards; /// @q - its nesseccery for Struct? check gas with and without
    }

    /** States */
    mapping(address => PlayersCards) playersDeck; // @q - after end of the game it delete the user key?
    mapping(address => DealersCards) dealersDeck; // @q - after end of the game it delete the dealer key?
    mapping(address => uint256[]) private availableCards; // @q - its should init somehow? what does it means availableCards?

    event PlayerLostTheGame(string message, uint256 cardsTotal);
    event PlayerWonTheGame(string message, uint256 cardsTotal);
    event FeeWithdrawn(address owner, uint256 amount); // @q - Fee? Nothing about fee on the spec!

    /** Functions */
    constructor() payable {}

    receive() external payable {}

    function addCardForPlayer(address player, uint256 card) internal {
        playersDeck[player].playersCards.push(card); // @q - Check if it push correct to the struct!
    }

    function addCardForDealer(address player, uint256 card) internal {
        // @q - Why Player? Why not dealer?
        dealersDeck[player].dealersCards.push(card); // @q - Check if it push correct to the struct!
    }

    function playersHand(address player) public view returns (uint256) {
        uint256 playerTotal = 0;
        for (uint256 i = 0; i < playersDeck[player].playersCards.length; i++) {
            // @q if im not in the game i can run it? and enter to for?
            // @gas optimize lenght
            /// @q - why % 13??? = 13 cards in total
            uint256 cardValue = playersDeck[player].playersCards[i] % 13; // why to do the logic of counting here?
            // a = 0 % 13 = 0
            if (cardValue == 0 || cardValue >= 10) {
                playerTotal += 10; // @q - why i should do +10?
            } else {
                playerTotal += cardValue;
            }
        }
        return playerTotal;
    }

    function dealersHand(address player) public view returns (uint256) {
        // @q - Why Player? Why not dealer?
        uint256 dealerTotal = 0;
        for (uint256 i = 0; i < dealersDeck[player].dealersCards.length; i++) {
            // @q if im not in the game i can run it? and enter to for?
            // @gas optimize lenght
            /// @q - why % 13??? = 13 cards in total
            uint256 cardValue = dealersDeck[player].dealersCards[i] % 13;
            if (cardValue >= 10) {
                dealerTotal += 10; // @q - why i should do +10?
            } else {
                dealerTotal += cardValue;
            }
        }
        return dealerTotal;
    }

    // Initialize the player's card pool when a new game starts
    function initializeDeck(address player) internal {
        require(
            availableCards[player].length == 0,
            "Player's deck is already initialized"
        );
        for (uint256 i = 1; i <= 54; i++) {
            // @q why 54 times to run it DOS??  in total 52 cards. but why not to init in constructor?
            availableCards[player].push(i);
        }
    }

    // Draw a random card for a specific player
    function drawCard(address player) internal returns (uint256) {
        require(
            availableCards[player].length > 0,
            "No cards left to draw for this player"
        );

        // Generate a random index
        /// @q - Bad randomness - use VRF
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, block.prevrandao)
            )
        ) % availableCards[player].length;

        // Get the card at the random index
        uint256 card = availableCards[player][randomIndex];

        // Remove the card from the player's available pool
        availableCards[player][randomIndex] = availableCards[player][
            availableCards[player].length - 1
        ];
        availableCards[player].pop();

        return card;
    }

    function startGame() public payable returns (uint256) {
        require(
            address(this).balance >= 2 ether,
            "Not enough ether on contract to start game"
        );
        /// @q - no checker for contract balance???
        /// @q - bad strategy for on going game!!!
        address player = msg.sender;
        require(msg.value == 1 ether, "start game only with 1 ether");
        /// @q - if player send more ether he still will win 2 ether and not more!!!!

        initializeDeck(player);
        uint256 card1 = drawCard(player);
        uint256 card2 = drawCard(player);
        addCardForPlayer(player, card1); /// @q Why the cards goin only for hand of player?
        addCardForPlayer(player, card2); /// @q Where the cards of dealer??
        return playersHand(player);
    }

    function hit() public {
        /// @q Why on Hit the player should draw a new card?
        require(
            playersDeck[msg.sender].playersCards.length > 0,
            "Game not started"
        );
        uint256 handBefore = playersHand(msg.sender);
        require(handBefore <= 21, "User is bust");
        uint256 newCard = drawCard(msg.sender);
        addCardForPlayer(msg.sender, newCard);
        uint256 handAfter = playersHand(msg.sender);
        if (handAfter > 21) {
            emit PlayerLostTheGame("Player is bust", handAfter);
            endGame(msg.sender, false);
        }
    }

    function call() public {
        require(
            playersDeck[msg.sender].playersCards.length > 0,
            "Game not started"
        );
        uint256 playerHand = playersHand(msg.sender);

        // Calculate the dealer's threshold for stopping (between 17 and 21)
        /// @q - why % 5? and + 17?
        uint256 standThreshold = (uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, block.prevrandao)
            )
        ) % 5) + 17; /// @q (between 17 and 21)???

        // Dealer draws cards until their hand reaches or exceeds the threshold
        while (dealersHand(msg.sender) < standThreshold) {
            /// @q why dealer should be msg.sender???
            uint256 newCard = drawCard(msg.sender);
            addCardForDealer(msg.sender, newCard);
        }

        uint256 dealerHand = dealersHand(msg.sender);

        // Determine the winner
        if (dealerHand > 21) {
            emit PlayerWonTheGame(
                "Dealer went bust, players winning hand: ",
                playerHand
            );
            endGame(msg.sender, true); // @q if the msg.sender who started the game and also a did call may he also dealer?
        } else if (playerHand > dealerHand) {
            emit PlayerWonTheGame(
                "Dealer's hand is lower, players winning hand: ",
                playerHand
            );
            endGame(msg.sender, true); // @q if the msg.sender who started the game and also a did call may he also dealer?
        } else {
            emit PlayerLostTheGame(
                "Dealer's hand is higher, dealers winning hand: ",
                dealerHand
            );
            endGame(msg.sender, false);
        }
    }

    // Ends the game, resets the state, and pays out if the player won
    function endGame(address player, bool playerWon) internal {
        delete playersDeck[player].playersCards; // Clear the player's cards
        delete dealersDeck[player].dealersCards; // Clear the dealer's cards
        delete availableCards[player]; // Reset the deck
        if (playerWon) {
            payable(player).transfer(2 ether); // Transfer the prize to the player
            emit FeeWithdrawn(player, 2 ether); // Emit the prize withdrawal event
        }
    }

    function getPlayerCards(
        address player
    ) public view returns (uint256[] memory) {
        return playersDeck[player].playersCards;
    }

    function getDealerCards(
        address player
    ) public view returns (uint256[] memory) {
        return dealersDeck[player].dealersCards;
    }
}
