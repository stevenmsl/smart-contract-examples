// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* better kickstart 

*/

contract Campaign {
    /* 
       - use struct to define your own types
       - this construct does contain a 
         nested mapping and hence needs to be 
         in a storage
       - you can't construct it either if you
         have a nested mapping
    */
    struct Request {
        string description;
        uint256 value;
        address recipient;
        bool complete;
        uint256 approvalCount;
        /* nested mapping  */
        mapping(address => bool) approvals;
    }
    /* when to use array
       - you need to return everything to the clients
       - you want to access certain entry using index
         and the index is known beforehand 
    */
    /* when NOT to use array
       - you need to search through it
       - the more items you have in an array the more
         gas it costs to loop through it
    */
    /* Why we use mapping here
       - this is because the Request construct contains
         a nested mapping and hence can't be constructed
         (meaning you can't create an instance for it)
    
    */
    mapping(uint => Request) public requests;
    uint numberOfRequests;  
    address public manager;
    uint256 public minimumContribution;
    mapping(address => bool) public approvers;
    uint256 public approversCount;
    
    /*
      function modifier
    */
    modifier restricted() {
        require(msg.sender == manager,"manager required");
        _;
    }
    
    constructor(uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
        numberOfRequests = 0;
        
    }
    
    /*
       - sponsor a campaign
       - payable means this function can
         receive ether into the contract
    */
    function contribute() public payable {
        require(msg.value > minimumContribution, 
            "minimum contribution required");
        approvers[msg.sender] = true;
        approversCount++;
    }
    
    function createRequest(string calldata description,
        uint value, address recipient) public restricted {
        
        /* 
          - since we can't create an Request instance,
            we have to use the following approach
          - you can think of storage modifier the same
            as by reference in other programming language
        */    
        Request storage r = requests[numberOfRequests++];
        r.description = description;
        r.value = value;
        r.recipient = recipient;
        r.complete = false;
            
    }
    
    
    
    
    
}
