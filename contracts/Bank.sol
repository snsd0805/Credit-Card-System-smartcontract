// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SoulboundToken.sol";

contract Bank {
    using Counters for Counters.Counter;
    Counters.Counter private id_counter;

	SoulboundToken sbt;
	address owner;
	mapping(address => uint) arrears;
	mapping(address => uint) sbt_number;

	constructor(address SBT_addr) {
		sbt = SoulboundToken(SBT_addr);
	}

    modifier onlyBank {
        require(msg.sender == owner, "Only the owner can access this function.");
        _;
    }

	modifier onlyClient {
		require(sbt_number[msg.sender] != 0);
		_;
	}

	function register(uint number) public {
		uint target = sbt.getAccountNumber(msg.sender);
		require(target != 0, "You don't have SBT.");
		require(target == number, "This is not your SBT number.");
		sbt_number[msg.sender] = target;
	}

}
