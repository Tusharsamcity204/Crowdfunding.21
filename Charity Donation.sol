pragma solidity ^0.8.0;

contract CharityDonation {
    address public owner;
    uint public goal;
    uint public deadline;
    uint public totalRaised;

    mapping(address => uint) public contributions;

    constructor(uint _goal, uint _durationInDays) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Deadline passed");
        require(msg.value > 0, "Contribution must be greater than 0");

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(totalRaised >= goal, "Goal not reached");
        require(block.timestamp >= deadline, "Campaign still active");

        payable(owner).transfer(address(this).balance);
    }

    // Refund function: allows users to withdraw funds if the goal was not reached.
    function refund() external {
        require(block.timestamp >= deadline, "Campaign still active");
        require(totalRaised < goal, "Goal was reached, no refund");

        uint contribution = contributions[msg.sender];
        require(contribution > 0, "No contributions to refund");

        contributions[msg.sender] = 0;  // Reset the contribution to prevent double withdrawal
        payable(msg.sender).transfer(contribution);
    }

    // View function to check individual contribution
    function getContribution() external view returns (uint) {
        return contributions[msg.sender];
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
