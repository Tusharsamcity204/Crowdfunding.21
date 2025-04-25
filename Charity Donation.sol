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

    function extendDeadline(uint _extraDays) external onlyOwner {
        deadline += _extraDays * 1 days;
    }

    function getTimeLeft() external view returns (uint) {
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    function togglePause() external onlyOwner {
        paused = !paused;
    }

    function getAllContributors() external view returns (address[] memory, uint[] memory) {
        uint[] memory amounts = new uint[](contributors.length);
        for (uint i = 0; i < contributors.length; i++) {
            amounts[i] = contributions[contributors[i]];
        }
        return (contributors, amounts);
    }

    // ✅ New Function: Change the goal amount (only before deadline and when paused)
    function changeGoal(uint _newGoal) external onlyOwner {
        require(paused, "Pause the campaign to change goal");
        require(block.timestamp < deadline, "Campaign already ended");
        goal = _newGoal;
    }

    // ✅ New Function: Check if goal is reached
    function isGoalReached() external view returns (bool) {
        return totalRaised >= goal;
    }

    // ✅ New Function: Return percentage raised (in basis points: 10000 = 100%)
    function getPercentageRaised() external view returns (uint) {
        if (goal == 0) return 0;
        return (totalRaised * 10000) / goal;
    }

    // ✅ New Function: Owner can remove a contributor (for correction purposes)
    function removeContributor(address _contributor) external onlyOwner {
        require(contributions[_contributor] > 0, "No contributions from this address");
        totalRaised -= contributions[_contributor];
        contributions[_contributor] = 0;

        for (uint i = 0; i < contributors.length; i++) {
            if (contributors[i] == _contributor) {
                contributors[i] = contributors[contributors.length - 1];
                contributors.pop();
                break;
            }
        }
    }
}
