// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SavingsVault {
    
    // Ether balances of each user
    mapping(address => uint256) private etherBalances;
    
    // ERC20 token balances: user => tokenAddress => balance
    mapping(address => mapping(address => uint256)) private tokenBalances;

    event EtherDeposited(address indexed user, uint256 amount);
    event EtherWithdrawn(address indexed user, uint256 amount);
    event TokenDeposited(address indexed user, address indexed token, uint256 amount);
    event TokenWithdrawn(address indexed user, address indexed token, uint256 amount);

    // Deposit ETH into the contract
    function depositEther() external payable {
        require(msg.value > 0, "Must send some ETH");
        etherBalances[msg.sender] += msg.value;
        emit EtherDeposited(msg.sender, msg.value);
    }

    // Withdraw ETH from the contract
    function withdrawEther(uint256 amount) external {
        require(etherBalances[msg.sender] >= amount, "Insufficient balance");
        etherBalances[msg.sender] -= amount;

        // Transfer ETH back to user
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Ether transfer failed");

        emit EtherWithdrawn(msg.sender, amount);
    }

    // Check ETH balance
    function checkEtherBalance(address user) external view returns (uint256) {
        return etherBalances[user];
    }

    // Deposit ERC20 tokens into the contract
    function depositToken(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        IERC20 erc20 = IERC20(token);

        // Transfer tokens from user to contract
        require(erc20.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        // Update internal balance
        tokenBalances[msg.sender][token] += amount;

        emit TokenDeposited(msg.sender, token, amount);
    }

    // Withdraw ERC20 tokens from the contract
    function withdrawToken(address token, uint256 amount) external {
        require(tokenBalances[msg.sender][token] >= amount, "Insufficient token balance");
        tokenBalances[msg.sender][token] -= amount;

        IERC20 erc20 = IERC20(token);
        require(erc20.transfer(msg.sender, amount), "Token transfer failed");

        emit TokenWithdrawn(msg.sender, token, amount);
    }

    // Check ERC20 balance
    function checkTokenBalance(address user, address token) external view returns (uint256) {
        return tokenBalances[user][token];
    }
}
