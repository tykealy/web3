// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

contract SupplyChainSSI{

    //Role represent enity involving inside the chain
    enum Role{
        None,               // Resevered for index 0 since solidity uses this as default value.
        Manufacturer,       // Represents entities that produce goods or raw materials in the supply chain.
        Supplier,           // Represents entities responsible for supplying raw materials or products to other entities in the chain.
        Retailer,           // Represents entities that sell products directly to customers or end-users.
        Customer,           // Represents the end-users or buyers who purchase goods from retailers.
        Admin               // Represents an entity with administrative privileges, responsible for managing roles, credentials, and the overall functioning of the supply chain.
    }
		// The DID struct represents a Decentralized Identifier in your supply chain system. 
    struct DID {
        string identifier;          // A unique string identifier for the entity.
        address owner;              // The Ethereum address of the entity that owns this DID.
        uint256 createdAt;					// A timestamp representing when the DID was created.
    }
    
    //The meta of each entiy in the supply chain
    struct Metadata{
        string name;            // The name of company or entity involving in the suply chain
        string email;           // User's full name or company name
        string phone_number;    // Contact details like email or phone number
        string location;        // Physical location (e.g., address, city, or country)
    }
		
    // The RoleCredential struct represents a credential assigned to an entity within the supply chain, associating them with a specific role. 
    // It ensures that the roles are securely verifiable, time-stamped, and revocable if necessary.
    struct RoleCredential{
        address issuer;
        address user;					//	The Ethereum address of the entity (e.g., manufacturer, supplier) to whom the credential is issued.
        Role role;						//	Specifies the role assigned to the entity.
        bytes32 hash;					//	A cryptographic hash uniquely identifying the credential.
        uint issuedAt;				//	A timestamp representing when the credential was issued.
        bool revoked;					//	Indicates whether the credential has been revoked.
    }

		// Used to set the deployer as an Admin and initialize their role history
    constructor (){
        roles[msg.sender] = Role.Admin;             // Set the deployer's role as Admin
        roleHistory[msg.sender].push(Role.Admin);
        createDID("admin");   // Add Admin role to deployer's role history
    }
    mapping(address => DID) private dids;																// Maps an Ethereum address to its corresponding Decentralized Identifier (DID).
    mapping(address => Metadata) internal metadatas;  										// Maps an Ethereum address to its associated metadata.
    mapping(address => Role) internal roles;															// Maps an Ethereum address to the current role assigned to the entity.
    mapping(address => Role[]) private roleHistory;											// Maps an Ethereum address to the history of roles the entity has held.
    mapping(address => RoleCredential[]) private issuedRoleCredential;		// Maps an Ethereum address to the list of role credentials issued to the entity.

    event DIDCreated(address indexed owner, string identifier);
    event MetadataCreated(address indexed owner, Metadata metadata);
    event MetadataUpdated(address indexed owner, Metadata Metadata);
    event RoleAssigned(address indexed owner, Role _role);
    event RoleUpdated(address indexed owner, Role newRole);
    event RoleCredentialCreated(address indexed user, Role role, bytes32 hash, uint issuedAt);
    event CredentialRevoked(address indexed user, Role role, bytes32 hash );

    // Function to create a DID (Decentralized Identifier) for a user
    function createDID(string memory _identifier) public {
				// Check if identifier is not empty
        require(bytes(_identifier).length > 0, "Identifier cannot be is empty;");

				// Check if user doesn't already have a DID
        require(bytes(dids[msg.sender].identifier).length == 0, "DID already exists for this address");

				// Create the DID
        dids[msg.sender] = DID({owner: msg.sender, identifier: _identifier, createdAt: block.timestamp});

				// Emit the DIDCreated event
        emit DIDCreated(msg.sender, _identifier);
    }

		// Function to retrieve the DID of a user
    function getDID(address _address) public view returns (string memory) {
				// Ensure DID exists for the user
        require(
            bytes(dids[_address].identifier).length > 0,
            "No DID exists for this address"
        );

				// Return the DID identifier
        return dids[_address].identifier;
    }
  
		// This function is responsible for creating metadata
    function setMetaData(string memory _email, string memory _phoneNumber, string memory _name, string memory _location ) public {
      	// Check if user already have a DID.
        require(dids[msg.sender].owner == msg.sender , "Owner does not have a DID");
      	
      	// Call a function responsible for checking parameters.
        require(validateMetadata(_email, _phoneNumber, _name, _location), "User's metadata is incomplete");
      	
      	// Checking if the user already have a metadata.

        Metadata memory newMetadata = Metadata({
            name: _name,
            email: _email,
            phone_number: _phoneNumber,
            location: _location
        });
      
      	// If the above coditions are met, create a new metadata and assign it to the user address.
        metadatas[msg.sender] = newMetadata;
      
      	// Emit the event to store log
        emit  MetadataCreated(msg.sender, newMetadata);
    }
  
		// This function is responsible for showing metadata
    function getMetaData(address _address) public view returns (Metadata memory )  {
      	//We do not have to check wether or not _address is valid because
				//If _address has no metadata stored, calling metadatas[_address] will not throw an error; 
      	//instead, it will return a Metadata struct with all fields set to their defaults(empty string.
        return (metadatas[_address]);
    }
  
  	// This function will update the new metadata for provided user, 
  	// Revoke the old issued credential and create a new one. 
  	// This function is crucial since informations of each entity in supply chain are likely to change to comply with the law.
    function updateMetadata(address _user,string memory _email,string memory _phoneNumber,string memory _name,string memory _location) public {
        // Only allow Admin to update metadata
        require(roles[msg.sender] == Role.Admin, "You don't have permission to update metadata");

        // Ensure the user has a DID
        require(dids[_user].owner == _user, "User does not have a DID");

        // Validate the metadata input
        require(validateMetadata(_email, _phoneNumber, _name, _location), "User's metadata is incomplete");

        // Update the metadata for the user
        metadatas[_user] = Metadata({
            email: _email,
            phone_number: _phoneNumber,
            name: _name,
            location: _location
        });

        //revoking the old credential since the metadata is updated 
        revokeCredential(_user);

        //After revoking the previous credential, we create a new credential
        createCredential(_user);

        // Emit the MetadataCreated event after updating metadata
        emit MetadataUpdated(_user, metadatas[_user]);
    }
		// Function to assign a role to a user (only callable by Admin)
    function AssignRole( address _user,  uint _role) public {
				// Ensure only Admin can assign roles
        require(roles[msg.sender] == Role.Admin, "You don't have permission to assign role");

				// Ensure user has a DID
        require(dids[_user].owner == _user , "User does not have a DID");

				// Ensure the role is valid
        require(_role >0 && _role <= 5, "Invalid role");

				// Assign role to the user
        roles[_user] = Role(_role);

				// Add role to the user's history
        roleHistory[_user].push(Role(_role));

				// Emit the RoleAssigned event
        emit RoleAssigned(_user, Role(_role));
    }

		// Function to retrieve the current role of a user
    function getRole(address _user) public view returns (string memory role){
      	// The same reason as getMetadata, We do not need to verify _user address/
        return  roleToString(roles[_user]);
    }

		// Helper function to validate metadata (ensures all fields are filled)
    function validateMetadata(string memory _email, string memory _phoneNumber, string memory _name, string memory _location) internal pure returns (bool) {
        if (bytes(_name).length == 0) {
            revert("Metadata validation failed: Name is missing.");
        } 
        if (bytes(_email).length == 0) {
            revert("Metadata validation failed: Email is missing.");
        } 
        if (bytes(_phoneNumber).length == 0) {
            revert("Metadata validation failed: Phone number is missing.");
        } 
        if(bytes(_location).length == 0){
            revert("Metadata validation failed: Public key is missing.");
        }
        
        return true;
    }

		// Function to create a role credential
    function createCredential( address _user ) public  {
      require(dids[_user].owner == _user , "Owner does not have a DID");											// Ensure the user has a DID
      require(roles[msg.sender] == Role.Admin, "You don't have permission to assign role");		// Ensure only Admin can create credentials
      require(bytes(metadatas[_user].name).length > 0, "User do not have metadata");					// Ensure the user has metadata
        
			// Validate metadata
			require(validateMetadata(metadatas[_user].email, 																				
      metadatas[_user].phone_number, 
      metadatas[_user].name, 
      metadatas[_user].location), "User's metadata is incomplete");

			// Generate unique hash for credential
      bytes32 hash = keccak256(abi.encodePacked(
        msg.sender,
        roles[_user], 
        metadatas[_user].email, 
        metadatas[_user].location, 
        block.timestamp, 
        _user)
      );

      // Instanciate credential with revoked field as false
      RoleCredential memory roleCredential = RoleCredential({
        issuer: msg.sender,
        user: _user,
        role: roles[_user],
        hash: hash,
        issuedAt: block.timestamp,
        revoked: false
      });

			// Store the issued credential
      issuedRoleCredential[_user].push(roleCredential);

			// Emit credential creation event
      emit RoleCredentialCreated(_user, roles[_user], hash, block.timestamp);
    }
 
		// Function to retrieve the credentials of a user
    function getCredential( address _user) public view returns (bytes32 _credentials ) {
      // The same reason as getMetadata, We do not need to verify _user address/
        return issuedRoleCredential[_user][0].hash;
    }
  	
  	//The function is called to revoke the old credential when the metadata of a user has been changed.
    function revokeCredential(address _user) public  {
        require(roles[msg.sender] == Role.Admin, "You do not have permission to revoke credential."); 	// Verify Caller Permission
        require(dids[_user].owner == _user , "Owner does not have a DID");                            	// Verify User Ownership of DID
        require(bytes(metadatas[_user].name).length > 0, "User do not have metadata");                	// Confirms that the user's metadata exists and is valid

        RoleCredential[] storage credentials = issuedRoleCredential[_user];                           	// Fetches the list of role credentials issued to the user
        require(credentials.length > 0, "No credentials found for this user");                        	// Verifies that the user has at least one credential

         // Mark the most recent credential as revoked
        RoleCredential storage latestCredential = credentials[credentials.length - 1];                	// Identified the most recently issued credential
        require(!latestCredential.revoked, "Credential is already revoked");                          	// confirm that this credential have been revoked or not

        latestCredential.revoked = true; // revoke credential

        // Emit event to notify the credential revocation
        emit CredentialRevoked(_user, latestCredential.role, latestCredential.hash); 
    }

    //Convert role enum to string
    function roleToString(Role _role) internal pure returns (string memory) {
        if (_role == Role.None) {
            return "None";
        } else if (_role == Role.Manufacturer) {
            return "Manufacturer";
        } else if (_role == Role.Admin) {
            return "Admin";
        }else if(_role == Role.Supplier ){
            return "Supplier";
        } else if (_role == Role.Retailer) {
            return "Retailer";
        }else  if (_role == Role.Customer){
            return "Customer";
        }
        return "User have no role";
    }

    function verifyRoleCredential(address _issuer, address _user, uint _role) view  public returns ( bool, bytes32, bytes32 ){
      RoleCredential[] memory credentials = issuedRoleCredential[_user];
      require(credentials.length > 0, "No credentials found for this user");

      // Ensure the provided role is valid
      require(_role > 0 && _role <= uint(Role.Admin), "Invalid role provided");

      for (uint256 i = 0; i < credentials.length; i++) {
        if(credentials[i].issuer==_issuer && credentials[i].role == Role(_role) ){
          bytes32 hash = credentials[i].hash;

          bytes32 expectedhash = keccak256(abi.encodePacked(
            _issuer,
            credentials[i].role, 
            metadatas[_user].email, 
            metadatas[_user].location, 
            credentials[i].issuedAt, 
            _user)
          );
          if (hash == expectedhash){
            return(true, hash, expectedhash);
          }
        }
      }
      return(false , bytes32(0), bytes32(0));
    }

    function updateRole(address _user,  uint _role) public  {
      require(roles[msg.sender] == Role.Admin, "You don't have permission to assign rol");
      require( bytes(dids[_user].identifier).length > 0, "No DID exists for this address"); 
      require(_role >0 && _role <= 5, "Invalid role");
      roles[_user] = Role(_role);
      roleHistory[_user].push(Role(_role));
      emit RoleUpdated(_user, Role(_role));
    }

    function requireRole(address _user, Role _requiredRole) internal view {
      require(roles[_user] == _requiredRole, "Action not permitted for this role");
      require(bytes(metadatas[_user].name).length > 0, "Metadata not found");
    }
}