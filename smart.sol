// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoachingMaterials {
    // Define a structure for materials
    struct Material {
        string title;
        string ipfsHash;  // IPFS hash of the material
        uint256 price;     // Price in tokens
        bool exists;       // Check if the material exists
    }

    address public owner;
    mapping(address => uint256) public balances; // Student balances
    mapping(uint256 => Material) public materials; // Material storage
    mapping(address => mapping(uint256 => bool)) public hasAccess; // Access control
    uint256 public materialCount; // Count of materials

    // Events
    event MaterialAdded(uint256 indexed materialId, string title, uint256 price);
    event AccessGranted(address indexed student, uint256 indexed materialId);
    event PaymentMade(address indexed student, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Add a new material
    function addMaterial(string memory _title, string memory _ipfsHash, uint256 _price) public onlyOwner {
        materialCount++;
        materials[materialCount] = Material(_title, _ipfsHash, _price, true);
        emit MaterialAdded(materialCount, _title, _price);
    }

    // Deposit tokens into the student's balance
    function depositTokens() public payable {
        require(msg.value > 0, "No ether sent");
        balances[msg.sender] += msg.value;
        emit PaymentMade(msg.sender, msg.value);
    }

    // Purchase access to a material
    function purchaseAccess(uint256 _materialId) public {
        require(materials[_materialId].exists, "Material does not exist");
        require(balances[msg.sender] >= materials[_materialId].price, "Insufficient balance");
        
        // Deduct the price from the student's balance
        balances[msg.sender] -= materials[_materialId].price;
        hasAccess[msg.sender][_materialId] = true;

        emit AccessGranted(msg.sender, _materialId);
    }

    // Check if a student has access to a material
    function hasStudentAccess(uint256 _materialId) public view returns (bool) {
        return hasAccess[msg.sender][_materialId];
    }

    // Withdraw ether from the contract (only for owner)
    function withdraw(uint256 _amount) public onlyOwner {
        payable(owner).transfer(_amount);
    }
}
