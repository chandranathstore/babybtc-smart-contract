// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BabyBTC {
    string public name = "Baby BTC";
    string public symbol = "BABYB";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    // ✅ Token price system
    uint256 public tokenPrice; // in wei
    uint256 public floorPrice; // minimum buy in wei

    // ✅ Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event PriceUpdated(uint256 newPrice);
    event Bought(address indexed buyer, uint256 amount, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalSupply = 920_000_000_000_000 * 10**decimals;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);

        tokenPrice = 0.000001 ether; // 0.000001 BNB per token (example)
        floorPrice = 0.01 ether;     // Minimum 0.01 BNB to buy
    }

    // ✅ Anti-bot + price floor protected buy function
    function buyTokens() public payable {
        require(tx.origin == msg.sender, "Bots not allowed");
        require(msg.value >= floorPrice, "Minimum 50 taka (0.01 BNB)");

        uint256 tokens = (msg.value * (10**decimals)) / tokenPrice;
        require(balanceOf[owner] >= tokens, "Not enough tokens");

        balanceOf[owner] -= tokens;
        balanceOf[msg.sender] += tokens;

        emit Transfer(owner, msg.sender, tokens);
        emit Bought(msg.sender, tokens, msg.value);
    }

    // ✅ Admin Functions
    function setTokenPrice(uint256 newPrice) public onlyOwner {
        tokenPrice = newPrice;
        emit PriceUpdated(newPrice);
    }

    function setFloorPrice(uint256 newPrice) public onlyOwner {
        floorPrice = newPrice;
    }

    // ✅ Standard ERC20 functions
    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function burn(uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance to burn");
        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Invalid address");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
}
