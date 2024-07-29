// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PresidentVote is ReentrancyGuard {

    // MODIFIERS
    modifier isRegister {
        require(!presidents[msg.sender].isRegister, "");
        _;
    }

    struct President {
        string presidentName;
        address addresss;
        bool isRegister;
        uint balance;
    }

    struct ActiveVote {
        address addresss;
        uint lockAmount;
        string message;
        uint votes;
    }

    struct addressUsedVotes {
        bool isUsedVote;
    }

    mapping(address => President) public presidents;
    mapping(uint => ActiveVote) public activeVotes;
    mapping(address => mapping(uint => addressUsedVotes)) public voteUsedd;
    
    uint internal voteCount;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function retrieveBalance(uint id) external  {
        require(activeVotes[id].addresss == msg.sender, "");
        require(activeVotes[id].votes >= 5, "");

        presidents[msg.sender].balance += activeVotes[id].lockAmount;  
    
        activeVotes[id].lockAmount = 0;
        activeVotes[id].addresss = address(0);
        activeVotes[id].message = "";
        activeVotes[id].votes = 0;
        voteUsedd[msg.sender][id].isUsedVote = false;

        unchecked {
            voteCount--;
        }
    }

    function registerPresident(string memory name) external isRegister {
        presidents[msg.sender].presidentName = name;
        presidents[msg.sender].addresss = msg.sender;
        presidents[msg.sender].isRegister = true;
    }

    function activeVotess() external view returns(uint) {
        return voteCount;
    }

    function deposit() public payable nonReentrant {
        //require(msg.value >= 1 ether, "1 ethereum and above can be deposited");
        require(!presidents[msg.sender].isRegister == false, "please register first");
        require(msg.value != 0, "The amount you deposit must be greater than 0");
        presidents[msg.sender].balance += msg.value;
    }
    
    function withdraw(address _to, uint _amount) external nonReentrant {
        presidents[msg.sender].balance -= _amount;
        payable(_to).transfer(_amount);

        assert(presidents[msg.sender].balance < _amount);
    }

    function CreateVote(string calldata message, uint lockedAmount) public {
        require(presidents[msg.sender].balance >= lockedAmount, "");

        presidents[msg.sender].balance -= lockedAmount;

        activeVotes[voteCount].addresss = msg.sender;
        activeVotes[voteCount].lockAmount = lockedAmount;
        activeVotes[voteCount].message = message;

        assert(presidents[msg.sender].balance < lockedAmount);
        voteCount++;
    }

    function useVote(uint id) external {
        require(activeVotes[id].addresss != address(0), "dead address");
        require(!voteUsedd[msg.sender][id].isUsedVote == true, "You cannot vote for the same person.");

        voteUsedd[msg.sender][id].isUsedVote = true;

        unchecked {
            activeVotes[id].votes += 1;
        }
    }

}