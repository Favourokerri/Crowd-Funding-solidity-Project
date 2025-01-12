// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";
//we start at 1:07:52; keeping track of the state of our contract;

contract CrowdFunding {
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;
    bool public paused;

    enum CampaignState {Active, Successful, Failed}

    CampaignState public state;

    struct Tier{
        string name;
        uint256 amount;
        uint256 numberOfTimesUsed;
    }

    struct Backer {
        uint256 totalContribution;
        mapping(uint256 => bool) fundedTier;
    }

    // store tier in an array
    Tier[] public tiers;
    mapping(address => Backer) public backers;

    constructor(string memory _name, string memory _description,
    uint256 _goal, uint256 _durationInDays){
        require(_goal > 0, "Goal must be greater than zero");
        name = _name;
        description = _description;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
        owner = msg.sender;
        state = CampaignState.Active;
    }

    function addTier(string memory _name, uint256 _amount) public OnlyOwner{
        require(_amount > 0, "price must be greater than 0");
        tiers.push(Tier(_name, _amount, 0));
    }

    function removeTier(uint256 _index) public{
        require(_index < tiers.length, "tier does not exist");
        tiers[_index] = tiers[tiers.length - 1];
        tiers.pop();
    }

    function checkAndUpdateState() internal {
        if (state == CampaignState.Active) {
            if (block.timestamp >= deadline && address(this).balance < goal){
                state = CampaignState.Failed;
            } else if (address(this).balance >= goal) {
                state = CampaignState.Successful;
            }
        }
    }

    function fund(uint256 _tierIndex) public CampaignOpen notPaused payable {
        uint256 amountToFund = tiers[_tierIndex].amount;
        require(msg.value == amountToFund, "please amount must be eqaul to tier selected");
        require(tiers.length > _tierIndex, "tier does not exist");
        require(msg.value == amountToFund, "please amount must be eqaul to tier selected");

        tiers[_tierIndex].numberOfTimesUsed += 1;
        backers[msg.sender].totalContribution += msg.value;
        backers[msg.sender].fundedTier[_tierIndex] = true;

        checkAndUpdateState();
    
    }

    function TogglePause() public OnlyOwner {
        paused = !paused;
    }

    function unPause() public  OnlyOwner {
        paused = false;
    }

    function widthraw() public OnlyOwner {
        checkAndUpdateState();
        require(state == CampaignState.Successful, "goal has not been reached");
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

    modifier CampaignOpen() {
        require(state == CampaignState.Active, "campaign is not active");
        _;
    }

    modifier notPaused() {
        require(paused != true, "campaign is on hold");
        _;
    }

    function refund() public {
        checkAndUpdateState();
        require(state == CampaignState.Failed, "this campaign is still active");
        uint256 amount = backers[msg.sender].totalContribution;
        require(amount > 0, "amount must be grater than 0");

        backers[msg.sender].totalContribution = 0;
            payable(msg.sender).transfer(amount);
        }

    function hasFundedTier(address _backer, uint256 _tierIndex) public view returns (bool){
        return backers[_backer].fundedTier[_tierIndex];
    }

    function getTiers()public view returns (Tier[] memory) {
        return tiers;
    }

    function getCampaignState() public view returns (CampaignState) {
        if (state == CampaignState.Active) {
            if (block.timestamp >= deadline && address(this).balance < goal){
                return CampaignState.Failed;
            } else if (address(this).balance >= goal) {
                return CampaignState.Successful;
            }
        }

        return state;
    }

    function extendDeadline(uint256 _daysToAdd) public OnlyOwner CampaignOpen {
        deadline += _daysToAdd * 1 days;
    }

}