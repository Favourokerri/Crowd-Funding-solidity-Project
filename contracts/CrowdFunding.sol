// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";

contract CrowdFunding {
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;

    constructor(string memory _name, string memory _description,
    uint256 _goal, uint256 _durationInDays){
        require(_goal > 0, "Goal must be greater than zero");
        name = _name;
        description = _description;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value > 0, "not enough eth");
        require(block.timestamp < deadline, "campagin has ended");
    
    }

    function widthraw() public {
        require(msg.sender == owner, "you do not have permission");
        require(address(this).balance >= goal, "goal has not been reached");
        uint256 balance = address(this).balance;

        payable(msg.sender).transfer(balance);
    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }
}