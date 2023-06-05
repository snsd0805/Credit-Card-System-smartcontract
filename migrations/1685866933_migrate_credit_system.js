var SBT = artifacts.require("SoulboundToken");
var Bank = artifacts.require("Bank");

module.exports = function(_deployer) {
	// Use deployer to state migration tasks.
	_deployer.deploy(SBT).then((SBT_instance) => {
		return _deployer.deploy(Bank, SBT_instance.address).then((Bank_instance) => {
			return SBT_instance.addReliableBank(Bank_instance.address);
		});
	});
};
