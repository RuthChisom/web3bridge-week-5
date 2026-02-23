// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin libraries
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract PropertyManagement is Ownable, AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);
    }

    struct Property {
        uint id;
        string name;
        string location;
        uint price; // in tokens
        bool forSale;
        address owner;
    }

    uint public propertyCount;
    mapping(uint => Property) private properties;

    event PropertyCreated(uint id, string name, string location, uint price, address owner);
    event PropertyRemoved(uint id);
    event PropertyPurchased(uint id, address buyer, uint price);

    // CREATE PROPERTY
    function createProperty(string memory _name, string memory _location, uint _price, bool _forSale, address _owner)
        external
        onlyRole(MANAGER_ROLE)
    {
        propertyCount++;
        properties[propertyCount] = Property({
            id: propertyCount,
            name: _name,
            location: _location,
            price: _price,
            forSale: _forSale,
            owner: _owner
        });

        emit PropertyCreated(propertyCount, _name, _location, _price, _owner);
    }

    // REMOVE PROPERTY
    function removeProperty(uint _id) external onlyOwner {
        require(properties[_id].id != 0, "Property does not exist");
        delete properties[_id];
        emit PropertyRemoved(_id);
    }

    // GET ALL PROPERTIES
    function getAllProperties() external view returns (Property[] memory) {
        Property[] memory allProps = new Property[](propertyCount);
        uint counter = 0;

        for (uint i = 1; i <= propertyCount; i++) {
            if (properties[i].id != 0) { // skip deleted properties
                allProps[counter] = properties[i];
                counter++;
            }
        }
        return allProps;
    }

    // PURCHASE PROPERTY
    function buyProperty(uint _id, IERC20 paymentToken) external {
        Property storage prop = properties[_id];
        require(prop.id != 0, "Property does not exist");
        require(prop.forSale, "Property not for sale");
        require(prop.owner != msg.sender, "Cannot buy your own property");

        // Transfer tokens from buyer to current owner
        require(paymentToken.transferFrom(msg.sender, prop.owner, prop.price), "Token transfer failed");

        // Transfer ownership
        prop.owner = msg.sender;
        prop.forSale = false;

        emit PropertyPurchased(_id, msg.sender, prop.price);
    }

    // UPDATE PROPERTY SALE STATUS (only owner can set for sale or not)
    function setForSale(uint _id, bool _forSale) external {
        Property storage prop = properties[_id];
        require(prop.owner == msg.sender, "Only owner can set sale status");
        prop.forSale = _forSale;
    }
}