// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SoulboundToken.sol";

contract Bank {
    using Counters for Counters.Counter;
    Counters.Counter private id_counter;

	SoulboundToken SBT;
	address owner;
	mapping(address => uint) arrears;
	mapping(address => uint) SBTNumbers;

	constructor(address SBT_addr) {
		SBT = SoulboundToken(SBT_addr);
	}

    modifier onlyBank {
        require(msg.sender == owner, "Only the owner can access this function.");
        _;
    }

	function register(uint number) public {
		uint target = SBT.getAccountNumber(msg.sender);
		require(target == number, "This is not your SBT number.");
		SBTNumbers[msg.sender] = target;
	}
}
