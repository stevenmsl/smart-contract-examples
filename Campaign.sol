// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* better kickstart
   - the money won't go to the manager instead
     it will go to the vendor who provides
     goods and services
   - manager needs to submit expense request
     to send the money to the vendor
   - approvers, who contributed to the campaign,
     can approve a expense request 
   - once more than a half of the approvers
     have approved the request, the manager can 
     then finalizes the request and send the
     money to the recipient
*/

/* design considerations
  - you can let the managers deploy the campaign
    contract themself when needed because we don't 
    want to pay for the gas of deploying a 
    campaign contract
    - keep in mind that in kickstart there are tons
      of projects funded - this is equivalent to
      have many campaign contracts deployed in our
      case, and we certainly don't want to pay
      for any of it for deploying them
    - the downside for this approach is that 
      managers can potentially tamper the contract
      
  - or introduce an factory contract, which only
    needs to be deployed once, and provide a method
    on that factory contract that managers can call 
    to deploy new compaign contracts
    - we only pay for the gas to deploy the factory
      contract
    - managers pay for the gas to deploy new Campaign
      contracts
    - campaign contracts cannot be tampered as they
      are deployed by the factory contract not managers
*/

contract CampaignFactory {
    address[] public deployedCampaigns;
    
    function createCampaign(uint minimum) public {
        Campaign c = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(address(c));
    }
    
    function getDeployedCampigns() public view returns (address[] memory) {
        return deployedCampaigns;    
    } 
    
}

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
        /*
          - once the request is finalized,
            we need to transfer the fund 
            to the recipient so it needs
            to be payable
        */
        address payable recipient;
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
    
    /*
      - only manager can create a expense request 
        to send ether to a vendor (recipient) to
        purchase goods or services
        
      - approvers, who fund the campaign 
        by contributing ether, can
        then approve the expense request
    */
    function createRequest(string calldata description,
        uint value, address payable recipient) public restricted {
        
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
    
    function approveRequest(uint index) public {
        /* 
          - we want to modify the request and hence
            the storage modifier
        */
        Request storage request = requests[index];
        require(
            approvers[msg.sender],
            "You need to contribute first."
        );
        /*
          - and you haven't approved this request
            yet
        */
        require(
            !request.approvals[msg.sender],
            "You have already approved this request."
        );
        
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }
    
    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        
        require(
            request.approvalCount > (approversCount/2),
            "not enough votes to complete this request"
        );
        
        require(
            !request.complete,
            "This request has been finalized"
        );
        
        /* 
          - you can call the transfer function only if 
            the address is payable
        */
        request.recipient.transfer(request.value);
        request.complete = true;
        
    }
    
    
    
}
