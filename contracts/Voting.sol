// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    constructor() Ownable(msg.sender) {}

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
    }

    struct Proposal {
        string description;
        uint256 voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public status;

    mapping(address => Voter) public voters;
    mapping(address => bool) private _whitelist;

    Proposal[] public proposals;

    uint256 public winningProposalId;

    event Whitelisted(address indexed account);
    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );
    event ProposalRegistered(uint256 proposalId);
    event Voted(address voter, uint256 proposalId);

    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "Voter not registered");
        _;
    }

    //whitelist adress
    function whitelist(address _account) public onlyOwner {
        _whitelist[_account] = true;
        emit Whitelisted(_account);
    }

    //Check if address is whitelisted
    function isWhitelisted(address _account) public view returns (bool) {
        return _whitelist[_account];
    }

    //Register a voter
    function registerVoter(address _voter) external onlyOwner {
        require(
            status == WorkflowStatus.RegisteringVoters,
            "Registration session closed"
        );
        require(!voters[_voter].isRegistered, "Already registered");

        voters[_voter].isRegistered = true;
        emit VoterRegistered(_voter);
    }

    //Start proposals registration
    function startProposalRegistration() external onlyOwner {
        require(status == WorkflowStatus.RegisteringVoters, "Must have registered user");
        status = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, status);
    }

    //Register a proposal
    function registerProposal(string memory _description)
        external
        onlyRegisteredVoter
    {
        require(
            status == WorkflowStatus.ProposalsRegistrationStarted,
            "Proposals registration not open"
        );
        proposals.push(Proposal({description: _description, voteCount: 0}));
        emit ProposalRegistered(proposals.length - 1);
    }

    //End proposals registration
    function endProposalRegistration() external onlyOwner {
        require(
            status == WorkflowStatus.ProposalsRegistrationStarted,
            "Proposals registration not open"
        );
        status = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(
            WorkflowStatus.ProposalsRegistrationStarted,
            status
        );
    }

    //Start voting session
    function startVotingSession() external onlyOwner {
        require(
            status == WorkflowStatus.ProposalsRegistrationEnded,
            "Must have proposals"
        );
        status = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(
            WorkflowStatus.ProposalsRegistrationEnded,
            status
        );
    }

    //Get all proposals and their indexes
    function getProposals()
        external
        view
        returns (string[] memory descriptions, uint256[] memory indexes)
    {
        uint256 length = proposals.length;
        descriptions = new string[](length);
        indexes = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            descriptions[i] = proposals[i].description;
            indexes[i] = i;
        }
    }

    //Vote for a proposal
    function vote(uint256 _proposalId) external onlyRegisteredVoter {
        require(
            status == WorkflowStatus.VotingSessionStarted,
            "Voting session not open"
        );
        require(!voters[msg.sender].hasVoted, "Voter already voted");
        require(_proposalId < proposals.length, "Invalid proposal ID");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;

        emit Voted(msg.sender, _proposalId);
    }

    //End voting session
    function endVotingSession() external onlyOwner {
        require(status == WorkflowStatus.VotingSessionStarted, "Voting session not open");
        status = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, status);
    }

    //Get the proposal with the most votes
    function getTalliedVotes() external onlyOwner {
        require(status == WorkflowStatus.VotingSessionEnded, "Voting session not finished");
        uint256 maxVotes = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxVotes) {
                maxVotes = proposals[i].voteCount;
                winningProposalId = i;
            }
        }

        status = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, status);
    }

    //Get the winning proposal
    function getWinner() external view returns (string memory) {
        require(status == WorkflowStatus.VotesTallied, "Votes not tallied yet");
        return proposals[winningProposalId].description;
    }
}
