// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    ============================================================
                    ERC20 TOKEN FROM SCRATCH
    ============================================================

    This contract implements the ERC20 token standard manually
    without importing any external libraries like OpenZeppelin.

    It includes:
    - Token metadata (name, symbol, decimals)
    - Balances tracking
    - Allowances system
    - Transfer logic
    - Approval logic
    - Minting (initial supply)
    - Events required by ERC20

    Solidity 0.8+ automatically handles overflow/underflow checks.
*/

contract MyERC20 {

    /*
        ========================================================
                            TOKEN METADATA
        ========================================================
    */

    // Token name (example: "My Token")
    string public name;

    // Token symbol (example: "MTK")
    string public symbol;

    // Number of decimals (usually 18)
    uint8 public decimals;

    // Total number of tokens in existence
    uint256 public totalSupply;

    /*
        ========================================================
                            STORAGE
        ========================================================
    */

    // Mapping to store balances of each address
    // address => token balance
    mapping(address => uint256) private balances;

    // Nested mapping for allowances
    // owner => (spender => amount)
    mapping(address => mapping(address => uint256)) private allowances;

    /*
        ========================================================
                            EVENTS
        ========================================================
    */

    // Emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Emitted when approval is given
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /*
        ========================================================
                            CONSTRUCTOR
        ========================================================
    */

    /*
        Constructor runs only once during deployment.

        We set:
        - Token name
        - Symbol
        - Decimals
        - Initial supply

        Initial supply is minted to the deployer.
    */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        // Mint initial supply to deployer
        _mint(msg.sender, _initialSupply);
    }

    /*
        ========================================================
                        BALANCE FUNCTIONS
        ========================================================
    */

    /*
        Returns the token balance of an address
    */
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    /*
        ========================================================
                        TRANSFER FUNCTIONS
        ========================================================
    */

    /*
        Transfer tokens from caller to another address
    */
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /*
        Internal transfer function containing the logic
        Used by both transfer() and transferFrom()
    */
    function _transfer(address from, address to, uint256 amount) internal {

        // Cannot send to zero address
        require(to != address(0), "Transfer to zero address");

        // Sender must have enough balance
        require(balances[from] >= amount, "Insufficient balance");

        // Subtract from sender
        balances[from] -= amount;

        // Add to receiver
        balances[to] += amount;

        // Emit event
        emit Transfer(from, to, amount);
    }

    /*
        ========================================================
                        ALLOWANCE FUNCTIONS
        ========================================================
    */

    /*
        Approve a spender to spend tokens on behalf of caller
    */
    function approve(address spender, uint256 amount) public returns (bool) {

        require(spender != address(0), "Approve to zero address");

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    /*
        Check how many tokens a spender is allowed to spend
    */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return allowances[owner][spender];
    }

    /*
        Transfer tokens from one address to another
        using allowance mechanism
    */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {

        uint256 currentAllowance = allowances[from][msg.sender];

        // Check allowance
        require(currentAllowance >= amount, "Allowance exceeded");

        // Reduce allowance
        allowances[from][msg.sender] = currentAllowance - amount;

        // Transfer tokens
        _transfer(from, to, amount);

        return true;
    }

    /*
        ========================================================
                            MINTING
        ========================================================
    */

    /*
        Internal mint function
        Creates new tokens and assigns them to an address
    */
    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "Mint to zero address");

        // Increase total supply
        totalSupply += amount;

        // Increase balance
        balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    /*
        ========================================================
                            BURNING
        ========================================================
    */

    /*
        Public burn function (optional feature)
        Allows users to destroy their own tokens
    */
    function burn(uint256 amount) public {

        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }
}