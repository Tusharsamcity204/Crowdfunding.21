// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharityDonation {
    address public owner;
    uint public goal;
    uint public deadline;
    uint public totalRaised;
    bool public paused;

    mapping(address => uint) public contributions;
    address[] public contributors;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Campaign is paused");
        _;
    }

    constructor(uint _goal, uint _durationInDays) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
        paused = false;
    }

    function contribute() external payable whenNotPaused {
        require(block.timestamp < deadline, "Deadline passed");
        require(msg.value > 0, "Contribution must be greater than 0");

        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
    }

    function withdraw() external onlyOwner {
        require(totalRaised >= goal, "Goal not reached");
        require(block.timestamp >= deadline, "Campaign still active");

        payable(owner).transfer(address(this).balance);
    }

    function refund() external {
        require(block.timestamp >= deadline, "Campaign still active");
        require(totalRaised < goal, "Goal was reached, no refund");

        uint contribution = contributions[msg.sender];
        require(contribution > 0, "No contributions to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contribution);
    }

    function getContribution() external view returns (uint) {
        return contributions[msg.sender];
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    // New Function: Extend the campaign deadline
    function extendDeadline(uint _extraDays) external onlyOwner {
        deadline += _extraDays * 1 days;
    }

    // New Function: Get remaining time in seconds
    function getTimeLeft() external view returns (uint) {
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    // New Function: Pause and Resume the campaign
    function togglePause() external onlyOwner {
        paused = !paused;
    }

    // New Function: View all contributors and their contributions
    function getAllContributors() external view returns (address[] memory, uint[] memory) {
        uint[] memory amounts = new uint[](contributors.length);
        for (uint i = 0; i < contributors.length; i++) {
            amounts[i] = contributions[contributors[i]];
        }
        return (contributors, amounts);
    }
}
