// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
    address public owner;
    bytes32 public immutable name;

    constructor(bytes32 _name) {
        owner = msg.sender;
        name = _name;
    }

    function anyCall(uint256 _func, uint256 data) external {
        function(uint) func;
        assembly {
            func := _func
        }
        func(data);
    }

    function transferOwnership() public {
        require(msg.sender == owner);
        owner = msg.sender;
    }
}
