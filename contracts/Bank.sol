// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SoulboundToken.sol";

struct Order {
	bool isFinished;
	uint amount;
	address shop;
}

contract Bank {
	using Counters for Counters.Counter;
	Counters.Counter private id_counter;

	SoulboundToken public sbt;
	address public owner;
	bool public recv = false;
	mapping(address => uint) private arrears;
	mapping(uint => Order) private order_info;
	mapping(address => uint[]) private client_orders;
	mapping(address => uint) private credits;
	mapping(address => uint) private sbt_number;

	constructor(address SBT_addr) {
		sbt = SoulboundToken(SBT_addr);
		owner = msg.sender;
	}

	modifier onlyBank {
		require(msg.sender == owner, "Only the owner can access this function.");
		_;
	}

	modifier onlyClient {
		require(sbt_number[msg.sender] != 0, "You should call register() first.");
		_;
	}

	modifier onlySelfOrBank(address addr) {
		require((msg.sender == owner) || (msg.sender==addr), "Only the owner can access this function.");
		_;
	}

	receive() external payable onlyBank {}


	function setCredit(address client, uint amount) public onlyBank {
		credits[client] = amount;
	}

	function register(uint number) public {
		uint target = sbt.getAccountNumber(msg.sender);
		require(target != 0, "You don't have SBT.");
		require(target == number, "This is not your SBT number.");
		require(sbt_number[msg.sender] == 0, "You have registered.");
		sbt_number[msg.sender] = target;
	}

	function pay(address shop, uint amount) public onlyClient {
		require(amount <= (credits[msg.sender]-arrears[msg.sender]), "You don't have enough credit.");
		id_counter.increment();
		uint id = id_counter.current();
		arrears[msg.sender] += amount;
		order_info[id] = Order(false, amount, shop);
		client_orders[msg.sender].push(id);
		payable(shop).transfer(amount);
		sbt.logBorrowing(msg.sender, id, amount);
	}

	function repay() public payable onlyClient returns (uint, uint) {
		require(recv, "It's not the time to repay.");
		uint value = msg.value;
		uint repay_amount = 0;
		uint should_pay;
		uint refund;
		uint item_counter = 0;
		
		for (uint i=0; i<client_orders[msg.sender].length; i++) {
			should_pay = order_info[client_orders[msg.sender][i]].amount;
			if ((value - repay_amount) >= should_pay){
				repay_amount += should_pay;
				order_info[client_orders[msg.sender][i]].isFinished = true;
				sbt.logRepaying(msg.sender, client_orders[msg.sender][i], should_pay);
			} else {
				client_orders[msg.sender][item_counter] = client_orders[msg.sender][i];
				item_counter += 1;
			}
		}
		for(uint i=0; i<(client_orders[msg.sender].length-item_counter); i++){
			client_orders[msg.sender].pop();
		}
		refund = value - repay_amount;
		arrears[msg.sender] -= repay_amount;
		if (refund != 0){
			payable(msg.sender).transfer(refund);
		}
		return (client_orders[msg.sender].length, refund);
	}

	function start_recv() public onlyBank {
		recv = true;
	}

	function stop_recv() public onlyBank {
		recv = false;
	}

	function getCredit(address client) public view onlySelfOrBank(client) returns (uint) {
		return credits[client];
	}

	function getArrear(address client) public view onlySelfOrBank(client) return (uint) {
		return arrears[client];
	}

	function getClientOrders(address client) public view onlySelfOrBank(client) returns (Order[] memory){
		Order[] memory orders = new Order[]( client_orders[client].length );
		for(uint i=0; i<client_orders[client].length; i++){
			orders[i] = order_info[client_orders[client][i]];
		}
		return orders;
	}
}
