// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProposalModule {

    enum State {
        NONE,
        PROPOSED,
        APPROVED,
        QUEUED,
        EXECUTED
    }

    struct Proposal {
        address target;
        uint256 value;
        bytes data;
        uint256 approvals;
        uint256 createdAt;
        State state;
    }

    uint256 public proposalCount;

    mapping(uint256 => Proposal) public proposals;

    function propose(
        address target,
        uint256 value,
        bytes calldata data
    ) external returns(uint256 id) {

        id = ++proposalCount;

        proposals[id] = Proposal({
            target: target,
            value: value,
            data: data,
            approvals: 0,
            createdAt: block.timestamp,
            state: State.PROPOSED
        });
    }

    function approve(uint256 id) external {

        Proposal storage p = proposals[id];

        require(p.state == State.PROPOSED || p.state == State.APPROVED, "invalid state");

        require(block.timestamp >= p.createdAt + 1 hours, "commit phase");      

        p.approvals++;

        if(p.approvals >= 1) {
            p.state = State.APPROVED;
        }
    }

    function setQueued(uint256 id) internal {
        Proposal storage p = proposals[id];
        require(p.state == State.APPROVED, "not approved");
        p.state = State.QUEUED;
    }
}
