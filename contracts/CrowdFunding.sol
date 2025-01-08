// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";
//we start at 41:20; keeping track of the state of our contract;

contract CrowdFunding {
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;

    struct Tier{
        string name;
        uint256 amount;
        uint256 backers;
        address funderAddress;
    }

    // store tier in an array
    Tier[] public tiers;

    constructor(string memory _name, string memory _description,
    uint256 _goal, uint256 _durationInDays){
        require(_goal > 0, "Goal must be greater than zero");
        name = _name;
        description = _description;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
        owner = msg.sender;
    }

    function addTier(string memory _name, uint256 _amount) public OnlyOwner{
        require(_amount > 0, "price must be greater than 0");
        tiers.push(Tier(_name, _amount, 0, msg.sender));
    }

    function removeTier(uint256 _index) public{
        require(_index < tiers.length, "tier does not exist");
        tiers[_index] = tiers[tiers.length - 1];
        tiers.pop();
    }

    function fund(uint256 _tierIndex) public payable {
        uint256 amountToFund = tiers[_tierIndex].amount;
        require(msg.value == amountToFund, "please amount must be eqaul to tier selected");
        require(block.timestamp < deadline, "campagin has ended");
        require(tiers.length > _tierIndex, "tier does not exist");
        require(msg.value == amountToFund, "please amount must be eqaul to tier selected");

        tiers[_tierIndex].backers += 1;
    
    }

    function widthraw() public OnlyOwner {
        require(address(this).balance >= goal, "goal has not been reached");
        uint256 balance = address(this).balance;

        payable(msg.sender).transfer(balance);
    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "must be owner to call this function");
        _;
    }
}