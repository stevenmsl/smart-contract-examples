// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExploreSol {
    
    /* 
      - names is a nested dynamic array as
        string itself is an array of bytes
    */
    string[] public names;

    function AddName(string memory name) public {
        names.push(name);
    }

    function getNames() public view returns (string[] memory) {
        return names;
    }
    
    
}