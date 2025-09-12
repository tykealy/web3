// SPDX-License-Identifier: MIT

//Group B:
//Group Member:
//Tykea Ly
//Measheanh Sengheng
//Khann Lyhouthap 
//Vuthy Outhdom
//Koy Sambo
pragma solidity ^0.8.0;

import "./SupplyChainSSI.sol";

contract SupplyChain is SupplyChainSSI {

    struct TransferRecord {
        address from;
        address to;
        uint256 timestamp;
    }

    struct Product {
        uint256 productId;
        string serialNumber; 
        string productType; 
        string manufacturerName;
        uint256 manufactureYear;
        address currentOwner;
        string metadataHash; 
    }

    uint256 public productCounter;
    mapping(uint256 => Product) public products;
    mapping(uint256 => TransferRecord[]) private productHistories;

    event ProductRegistered(uint256 productId, string serialNumber, string productType, address indexed manufacturer);
    event OwnershipTransferred(uint256 productId, address indexed from, address indexed to);

    // Role-Specific Permissions
    modifier onlyManufacturer() {
        require(roles[msg.sender] == Role.Manufacturer, "Only manufacturers can perform this action");
        _;
    }

    // Function to register a new product
    function registerProduct(
        string memory _serialNumber,
        string memory _productType,
        uint256 _manufactureYear,
        string memory _metadataHash
    ) public onlyManufacturer {
        require(bytes(_serialNumber).length > 0, "Serial number is required");
        require(bytes(_productType).length > 0, "Product type is required");
        require(bytes(metadatas[msg.sender].name).length > 0, "Manufacturer name is required");
        require(bytes(_metadataHash).length > 0, "Metadata hash is required");

        productCounter++;
        products[productCounter] = Product({
            productId: productCounter,
            serialNumber: _serialNumber,
            productType: _productType,
            manufacturerName: metadatas[msg.sender].name,
            manufactureYear: _manufactureYear,
            currentOwner: msg.sender,
            metadataHash: _metadataHash
        });

        productHistories[productCounter].push(TransferRecord({
            from: address(0),
            to: msg.sender,
            timestamp: block.timestamp
        }));

        emit ProductRegistered(productCounter, _serialNumber, _productType, msg.sender);
    }

    // Function to transfer product ownership
    function transferProductOwnership(uint256 _productId, address _newOwner) public {
        Product storage product = products[_productId];
        require(product.productId != 0, "Product not found");
        require(product.currentOwner == msg.sender, "Only current owner can transfer");
        require(_newOwner != address(0), "Invalid new owner address");

        // Add the transfer record
        productHistories[_productId].push(TransferRecord({
            from: msg.sender,
            to: _newOwner,
            timestamp: block.timestamp
        }));

        product.currentOwner = _newOwner;

        emit OwnershipTransferred(_productId, msg.sender, _newOwner);
    }

    // Function to get the history of a product
    function getProductHistory(uint256 _productId) public view returns (
        TransferRecord[] memory
    ) {
        Product storage product = products[_productId];
        require(product.productId != 0, "Product not found");

        uint256 historyLength = productHistories[_productId].length;
        TransferRecord[] memory histories = new TransferRecord[](historyLength);

        for (uint256 i = 0; i < historyLength; i++) {
        TransferRecord memory record = productHistories[_productId][i];
        histories[i] = TransferRecord({
            from: record.from,
            to: record.to,
            timestamp: record.timestamp
        });
        }
        return histories;
    }

    // Function to get product details
    function getProductDetails(uint256 _productId) public view returns (
        uint256,
        string memory,
        string memory,
        string memory,
        uint256,
        address,
        string memory
    ) {
        Product memory product = products[_productId];
        require(product.productId != 0, "Product not found");

        return (
            product.productId,
            product.serialNumber,
            product.productType,
            product.manufacturerName,
            product.manufactureYear,
            product.currentOwner,
            product.metadataHash
        );
    }
}