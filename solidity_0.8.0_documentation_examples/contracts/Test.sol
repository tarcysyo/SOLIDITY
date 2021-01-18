// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Test {
    enum AuctionChoices { GoLeft, GoRight, GoStraight, SitStill }
    AuctionChoices choice;
    AuctionChoices constant defaultChoice = AuctionChoices.GoStraight;

    function setGoStraight() public {
        choice = AuctionChoices.GoStraight;
    }

    function getChoice() public view returns (AuctionChoices){
        return choice;
    }

    function getDefaultChoice() public pure returns (uint){
        return uint(defaultChoice);
    }
}