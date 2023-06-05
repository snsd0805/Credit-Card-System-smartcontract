// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SoulboundToken.sol";

contract Bank {
    using Counters for Counters.Counter;
    Counters.Counter private id_counter;

	struct Order {
		bool isFinished;
		uint amount;
	}

	SoulboundToken sbt;
	address owner;
	mapping(address => uint) arrears;
	mapping(uint => Order) order_amount;
	mapping(address => uint[]) client_orders;
	mapping(address => uint) credits;
	mapping(address => uint) sbt_number;

	constructor(address SBT_addr) {
		sbt = SoulboundToken(SBT_addr);
		owner = msg.sender;
	}

	receive() external payable {}

    modifier onlyBank {
        require(msg.sender == owner, "Only the owner can access this function.");
        _;
    }

	modifier onlyClient {
		require(sbt_number[msg.sender] != 0);
		_;
	}

	function setCredit(address client, uint amount) public onlyBank {
		credits[client] = amount;
	}

	function register(uint number) public {
		uint target = sbt.getAccountNumber(msg.sender);
		require(target != 0, "You don't have SBT.");
		require(target == number, "This is not your SBT number.");
		sbt_number[msg.sender] = target;
	}

	function pay(address shop, uint amount) public onlyClient {
		require(amount <= credits[msg.sender], "You don't have enough credit.");
		id_counter.increment();
		uint id = id_counter.current();
		arrears[msg.sender] += amount;
		order_amount[id] = Order(false, amount);
		client_orders[msg.sender].push(id);
		payable(shop).transfer(amount);
		sbt.logBorrowing(msg.sender, id, amount);
	}

	function repay() public payable onlyClient returns (uint[] memory, uint) {
		uint value = msg.value;
		uint repay_amount = 0;
		uint should_pay;
		uint[] memory unfinished = new uint[](client_orders[msg.sender].length);
		uint refund;
		uint item_counter = 0;
		for (uint i=0; i<client_orders[msg.sender].length; i++) {
			should_pay = order_amount[client_orders[msg.sender][i]].amount;
			if ((value - repay_amount) >= should_pay){
				repay_amount += should_pay;
				order_amount[client_orders[msg.sender][i]].isFinished = true;
			} else {
				unfinished[item_counter] = (client_orders[msg.sender][i]);
				item_counter += 1;
			}
		}
		refund = value - repay_amount;
		if (refund != 0){
			payable(msg.sender).transfer(refund);
		}
		return (unfinished, refund);
	}
}
