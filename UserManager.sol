// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract UserManager {
    address private deployer; // Address of the contract deployer
    mapping(address => bool) private banned_users; // Mapping of banned users
    mapping(address => bool) private standard_cmp_ID; // Mapping of standard company IDs
    mapping(address => bool) private legal_cmp_ID; // Mapping of legal company IDs
    mapping(address => bool) private seller_ID; // Mapping of seller company IDs

    // Event that is emitted when a user is banned
    event UserBanned(address indexed user);

    // Event that is emitted when a user ban is removed
    event BanRemoved(address indexed user);

    // Event that is emitted when a standard company is added
    event StandardCompanyAdded(address indexed user);

    // Event that is emitted when a standard company is removed
    event StandardCompanyRemoved(address indexed user);

    // Event that is emitted when a legal company is added
    event LegalCompanyAdded(address indexed user);

    // Event that is emitted when a legal company is removed
    event LegalCompanyRemoved(address indexed user);

    // Event that is emitted when a seller company is added
    event SellerAdded(address indexed user);

    // Event that is emitted when a seller company is removed
    event SellerRemoved(address indexed user);

    // Modifier that restricts access to only the contract deployer
    modifier onlyDeployer(address _sender) {
        require(
            _sender == deployer,
            "Only the contract deployer can call this function"
        );
        _;
    }

    // Constructor that sets the deployer address
    constructor(address _sender) {
        deployer = _sender;
    }

    // Function that bans a user
    function banUser(
        address _sender,
        address user
    ) public onlyDeployer(_sender) {
        if (isUserStandardCompany(user)) {
            removeStandardCompany(_sender, user);
        }
        if (isUserLegalCompany(user)) {
            removeLegalCompany(_sender, user);
        }
        if (isUserSeller(user)) {
            removeSeller(_sender, user);
        }
        banned_users[user] = true;
        emit UserBanned(user); // Emit the UserBanned event
    }

    // Function that removes a user ban
    function removeBan(
        address _sender,
        address user
    ) public onlyDeployer(_sender) {
        require(banned_users[user] == true, "not ban before");
        banned_users[user] = false;
        emit BanRemoved(user); // Emit the BanRemoved event
    }

    // Function that checks if a user is banned
    function isUserBanned(address user) public view returns (bool) {
        return banned_users[user];
    }

    // Function that adds a standard company
    function addStandardCompany(
        address _sender,
        address user
    ) public onlyDeployer(_sender) {
        if (isUserBanned(user)) {
            removeBan(_sender, user);
        }
        if (isUserLegalCompany(user)) {
            removeLegalCompany(_sender, user);
        }
        standard_cmp_ID[user] = true;
        emit StandardCompanyAdded(user); // Emit the StandardCompanyAdded event
    }

    // Function that removes a standard company
    function removeStandardCompany(
        address _sender,
        address user
    ) public onlyDeployer(_sender) {
        require(
            standard_cmp_ID[user] == true,
            "removed from standard company before"
        );
        standard_cmp_ID[user] = false;
        emit StandardCompanyRemoved(user); // Emit the StandardCompanyRemoved event
    }

    // Function that checks if a user is a standard company
    function isUserStandardCompany(address user) public view returns (bool) {
        return standard_cmp_ID[user];
    }

    // Function that adds a legal company
    function addLegalCompany(
        address _sender,
        address user
    ) public onlyDeployer(_sender) {
        if (isUserBanned(user)) {
            removeBan(_sender, user);
        }
        if (isUserStandardCompany(user)) {
            removeStandardCompany(_sender, user);
        }
        legal_cmp_ID[user] = true;
        emit LegalCompanyAdded(user); // Emit the LegalCompanyAdded event
    }

    // Function that removes a legal company
    function removeLegalCompany(
        address _sender,
        address user
    ) public onlyDeployer(_sender) {
        require(
            legal_cmp_ID[user] == true,
            "removed from legal company  before"
        );
        legal_cmp_ID[user] = false;
        emit LegalCompanyRemoved(user); // Emit the LegalCompanyRemoved event
    }

    // Function that checks if a user is a legal company
    function isUserLegalCompany(address user) public view returns (bool) {
        return legal_cmp_ID[user];
    }

    // Function that adds a seller
    function addSeller(
        address _sender,
        address user
    ) public onlyDeployer(_sender) {
        if (isUserBanned(user)) {
            removeBan(_sender, user);
        }
        seller_ID[user] = true;
        emit SellerAdded(user); // Emit the SellerAdded event
    }

    // Function that removes a seller
    function removeSeller(
        address _sender,
        address user
    ) public onlyDeployer(_sender) {
        require(seller_ID[user] == true, "seller removed before");
        seller_ID[user] = false;
        emit SellerRemoved(user); // Emit the SellerRemoved event
    }

    // Function that checks if a user is a seller
    function isUserSeller(address user) public view returns (bool) {
        return seller_ID[user];
    }
}
