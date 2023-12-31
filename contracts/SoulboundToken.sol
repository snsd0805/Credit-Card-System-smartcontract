// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SoulboundToken is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    struct Certificate {
        address addr;
        uint number;
    }

    mapping(address => bool) private isReliableBank;
    mapping(address => Certificate[]) private certificates;
    mapping(address => uint) private address_to_number;

    event Borrow(address indexed client, address indexed shop, address indexed bank, uint id, uint amount);
    event Repay(address indexed client, address indexed bank, uint id, uint amount);
    event Warning(address indexed client, address indexed bank);

    constructor() ERC721("Credit System Soulbound Token", "CS_SBT") {}

    function mint(address player) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        address_to_number[player] = newItemId;

        return newItemId;
    }

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override {
        require(from == address(0) || to == address(0), "SOULBOUND: Non-Transferable.");
        require(balanceOf(to)==0, "SOULBOUND: Everyone should only have 1 SBT.");
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Credit System Soulbound Token (CS_SBT) #',
                        Strings.toString(tokenId),
                        '",',
                        '"image_data": "',
                        getSvgImage(tokenId),
                        '"',
                        "}"
                    )
                )   
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function getSvgImage(uint uid) private pure returns (string memory){
        string memory uid_str = Strings.toString(uid);
        string memory a = "<svg id='eY2GjP7k5St1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 511.999 511.999' shape-rendering='geometricPrecision' text-rendering='geometricPrecision' width='511.999' height='511.999'><path d='M460.803,446.739h-409.606C22.967,446.739,0,423.772,0,395.542v-279.085C0,88.227,22.967,65.26,51.197,65.26h409.605c28.23,0,51.197,22.967,51.197,51.197v279.084c.001,28.231-22.966,51.198-51.196,51.198Z' fill='#39a3db'/><path d='M460.803,65.26h-204.804v381.479h204.802c28.23,0,51.197-22.967,51.197-51.197v-279.085C512,88.227,489.033,65.26,460.803,65.26Z' fill='#3797d3'/><path d='M237.413,381.144h-156.122c-10.264,0-18.586-8.322-18.586-18.586v-213.119c0-10.264,8.322-18.586,18.586-18.586h156.122c10.264,0,18.586,8.322,18.586,18.586v213.119c0,10.266-8.32,18.586-18.586,18.586Z' fill='#80d0e1'/><g><circle r='27.204' transform='translate(159.356 237.355)' fill='#e8f2fb'/><path d='M160.414,285.559c-40.261,0-73.306,30.9-76.71,70.279-.312,3.614,2.556,6.721,6.184,6.721h141.053c3.628,0,6.496-3.106,6.184-6.721-3.405-39.378-36.449-70.279-76.711-70.279Z' fill='#e8f2fb'/></g><path d='M439.004,234.586h-147.18c-10.264,0-18.586-8.322-18.586-18.586v-66.561c0-10.264,8.322-18.586,18.586-18.586h147.18c10.264,0,18.586,8.322,18.586,18.586v66.561c0,10.265-8.321,18.586-18.586,18.586Z' transform='matrix(1.06575 0 0 1.15416-23.142833-14.750278)' fill='#51b3da'/><path d='M439.004,284.497h-147.18c-10.264,0-18.586-8.322-18.586-18.586s8.322-18.586,18.586-18.586h147.18c10.264,0,18.586,8.322,18.586,18.586c0,10.266-8.321,18.586-18.586,18.586Z' transform='matrix(1.075331 0 0 1.526395-25.760726-81.826221)' fill='#51b3da'/><text dx='0' dy='0' font-family='&quot;eY2GjP7k5St1:::Source Sans Pro&quot;' font-size='25.59995' font-weight='700' transform='translate(270.606978 180.04155)' fill='#fff' stroke-width='0'><tspan y='0' font-weight='700' stroke-width='0'><![CDATA[Credit System]]></tspan><tspan x='0' y='25.59995' font-weight='700' stroke-width='0'><![CDATA[     Soulbound Token]]></tspan><tspan x='0' y='51.1999' font-weight='700' stroke-width='0'><![CDATA[     (CSSBT)]]></tspan></text><text dx='0' dy='0' font-family='&quot;eY2GjP7k5St1:::Source Sans Pro&quot;' font-size='25.59995' font-weight='700' transform='translate(295.693679 332.445094)' fill='#fff' stroke-width='0'><tspan y='0' font-weight='700' stroke-width='0'><![CDATA[#";
        string memory b =  "]]></tspan></text><style><![CDATA[@font-face {font-family: 'eY2GjP7k5St1:::Source Sans Pro';font-style: normal;font-weight: 700;src: url(data:font/ttf;charset=utf-8;base64,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) format('truetype');}]]></style></svg>";
        return string(abi.encodePacked(a, uid_str, b));
    }

    modifier onlyBank {
        require(isReliableBank[msg.sender] == true, "Only bank can access this function");
        _;
    }

	modifier onlySelfOrBank(address addr) {
		require(isReliableBank[msg.sender] == true || (msg.sender == addr), "Only the owner can access this function.");
		_;
	}

    modifier onlyRegister {
        require(balanceOf(msg.sender)!=0, "Only Register can access this function");
        _;
    }

    function addReliableBank(address bank) public onlyOwner {
        isReliableBank[bank] = true;
    }

    function removeReliableBank(address bank) public onlyOwner {
        isReliableBank[bank] = false;
    }

    function logBorrowing(address client, address shop, uint id, uint amount) public onlyBank {
        emit Borrow(client, shop, msg.sender, id, amount);
    }

    function logRepaying(address client, uint id, uint amount) public onlyBank {
        emit Repay(client, msg.sender, id, amount);
    }

    function logWarning(address client) public onlyBank {
        emit Warning(client, msg.sender);
    }

    function addCertificate(address addr, uint number) public onlyRegister{
        certificates[msg.sender].push(Certificate(addr, number));
    }

    function listCertificate(address client) public view onlyBank returns (Certificate[] memory){
        return certificates[client];
    }

    function getAccountNumber(address client) public view onlySelfOrBank(client) returns (uint) {
        return address_to_number[client];
    }
}