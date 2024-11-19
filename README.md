# First Flight #29: TwentyOne

- Starts: November 21, 2024 Noon UTC
- Ends: November 28, 2024 Noon UTC

- nSLOC: 147

[//]: # (contest-details-open)

## About the Project

```

The "TwentyOne" protocol is a smart contract implementation of the classic blackjack card game, where users can wager 1 ETH to participate. The game involves a player competing against a dealer, with standard blackjack rules applied. A random card drawing mechanism is implemented to mimic shuffling, and players can choose to "hit" or "stand" based on their card totals. Winning players double their wager, while losing players forfeit their initial bet.


```

## Actors

```
Actors:
    Player: The user who interacts with the contract to start and play a game. A player must deposit 1 ETH to play, with a maximum payout of 2 ETH upon winning.
    Dealer: The virtual counterpart managed by the smart contract. The dealer draws cards based on game logic.
```

[//]: # (contest-details-close)

[//]: # (scope-open)

## Scope (contracts)

Example:
```
All Contracts in `src` are in scope.
```
```js
src/
└── TwentyOne.sol
```

## Compatibilities

```
Compatibilities:
Blockchains: - Ethereum
Tokens: - ETH

```

[//]: # (scope-close)

[//]: # (getting-started-open)

## Setup

Build:
```bash
git clone https://github.com/Cyfrin/2024-11-twentyone.git

cd 2024-11-twentyone
 
forge build
```

Tests:
```bash
Forge test
```

[//]: # (getting-started-close)

[//]: # (known-issues-open)

## Known Issues

`Known Issues:
- Randomness Manipulation: The randomness mechanism relies on block.timestamp, msg.sender, and block.prevrandao, which may be predictable in certain scenarios. Consider using Chainlink VRF or another oracle for more secure randomness.
`
[//]: # (known-issues-close)
