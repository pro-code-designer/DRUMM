// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./UserManager.sol";
import "./ProductManagement.sol";

contract run {
    address payable private admin; // Address of the admin user

    UserManager private userManager; // Instance of the UserManager contract
    mapping(address => ProductManagement) private productManager; // Mapping of user addresses to their respective ProductManagement contracts
    mapping(address => bool) private cmp_ID; // Mapping to keep track of whether a user has a company or not
    uint private unban_request_price;
    uint private seller_price;
    uint private standard_price;
    uint private legal_price;

    constructor(
        uint _unban_request_price,
        uint _seller_price,
        uint _standard_price,
        uint _legal_price
    ) {
        admin = payable(msg.sender); // Set the admin address as the sender of the contract
        userManager = new UserManager(msg.sender); // Create a new instance of the UserManager contract with the admin as the sender
        unban_request_price = _unban_request_price;
        seller_price = _seller_price;
        standard_price = _standard_price;
        legal_price = _legal_price;
    }

    modifier notBanned() {
        require(
            !userManager.isUserBanned(msg.sender),
            "You are banned from adding products."
        );
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "You are banned from adding products.");
        _;
    }

    event unban_req(address sender);
    event seller_req(address sender);
    event standard_req(address sender);
    event legal_req(address sender);

    function addSeller(address user) public notBanned {
        userMN anager.addSeller(msg.sender, user);
    }

    function removeSeller(address user) public notBanned {
        userManager.removeSeller(msg.sender, user);
    }

    function startMyCompany() public notBanned {
        require(cmp_ID[msg.sender] == false, "you have company before"); // Require that the user does not already have a company
        productManager[msg.sender] = new ProductManagement(
            admin,
            msg.sender,
            ProductManagement.CompanyType.UNKNOWN
        ); // Create a new instance of the ProductManagement contract for the user
        cmp_ID[msg.sender] = true; // Set the user's company status to true
    }

    modifier haveCompany() {
        // Modifier to check if the user has a company
        require(cmp_ID[msg.sender] == true, "no company with this address"); // Require that the user has a company
        _;
    }

    function addProduct(
        uint256 _productCode,
        uint256 _expirationDate,
        uint256 _price,
        uint256 _productNumber,
        ProductManagement.ProductType _productType
    ) public haveCompany notBanned {
        productManager[msg.sender].addProduct(
            payable(msg.sender),
            _productCode,
            _expirationDate,
            _price,
            _productNumber,
            _productType
        );
    }

    function getProduct(
        address _cmpAddress,
        uint256 _productCode,
        uint256 _productNumber
    ) public view notBanned returns (ProductManagement.Product memory) {
        require(cmp_ID[_cmpAddress] == true, "no company with this address");
        return
            productManager[_cmpAddress].getProduct(
                _productCode,
                _productNumber
            );
    }

    function editProductType(
        address _cmpAddress,
        uint256 _productCode,
        uint256 _productNumber,
        ProductManagement.ProductType _newProductType
    ) public notBanned {
        require(cmp_ID[_cmpAddress] == true, "no company with this address");
        productManager[_cmpAddress].editProductType(
            msg.sender,
            _productCode,
            _productNumber,
            _newProductType
        );
    }

    function editForSale(
        address _cmpAddress,
        uint256 _productCode,
        uint256 _productNumber,
        bool _forsale
    ) public notBanned {
        require(cmp_ID[_cmpAddress] == true, "no company with this address");
        bool _is_seller = userManager.isUserSeller(msg.sender);
        productManager[_cmpAddress].editForSale(
            msg.sender,
            _productCode,
            _productNumber,
            _forsale,
            _is_seller
        );
    }

    function editCompanyType(
        address _cmpAddress,
        ProductManagement.CompanyType _company_owner_type
    ) public notBanned {
        require(cmp_ID[_cmpAddress] == true, "no company with this address");
        productManager[_cmpAddress].editCompanyType(
            msg.sender,
            _company_owner_type
        );

        if (_company_owner_type == ProductManagement.CompanyType.STANDARD) {
            userManager.addStandardCompany(msg.sender, _cmpAddress); //make a standard company
        } else if (_company_owner_type == ProductManagement.CompanyType.LEGAL) {
            userManager.addLegalCompany(msg.sender, _cmpAddress); //make an legal company
        } else if (_company_owner_type == ProductManagement.CompanyType.BAN) {
            userManager.banUser(msg.sender, _cmpAddress); //ban company
        } else {
            if (userManager.isUserBanned(_cmpAddress)) {
                userManager.removeBan(msg.sender, _cmpAddress);
            }
            if (userManager.isUserLegalCompany(_cmpAddress)) {
                userManager.removeLegalCompany(msg.sender, _cmpAddress);
            }
            if (userManager.isUserStandardCompany(_cmpAddress)) {
                userManager.removeStandardCompany(msg.sender, _cmpAddress);
            }
        }
    }

    function buyProduct(
        address _cmpAddress,
        uint _productCode,
        uint _productNumber
    ) public payable notBanned {
        require(cmp_ID[_cmpAddress] == true, "no company with this address");
        productManager[_cmpAddress].buyProduct{value: msg.value}(
            payable(msg.sender),
            _productCode,
            _productNumber
        );
    }

    function requestToBeLegal() public payable notBanned {
        require(
            !userManager.isUserLegalCompany(msg.sender),
            "You were legal company"
        );

        require(
            !userManager.isUserStandardCompany(msg.sender),
            "You were standard company"
        );

        require(msg.value == legal_price, "this value is incorect");
        admin.transfer(msg.value);
        emit legal_req(msg.sender);
    }

    function requestToBeStandard() public payable notBanned {
        require(
            userManager.isUserLegalCompany(msg.sender),
            "you should be legal first"
        );
        require(msg.value == standard_price, "this value is incorect");
        admin.transfer(msg.value);
        emit standard_req(msg.sender);
    }

    function requestToBeseller() public payable notBanned {
        require(
            !userManager.isUserSeller(msg.sender),
            "you should be seller first"
        );
        require(msg.value == seller_price, "this value is incorect");
        admin.transfer(msg.value);
        emit seller_req(msg.sender);
    }

    function unbanRequest() public payable {
        require(userManager.isUserBanned(msg.sender), "You are notbanned");
        require(msg.value == unban_request_price, "this value is incorect");
        admin.transfer(msg.value);
        emit unban_req(msg.sender);
    }
} 
