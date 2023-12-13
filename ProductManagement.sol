// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract ProductManagement {
    enum ProductType {
        STANDARD,
        STANDARD_LIMITEDSALE,
        STANDARD_NOSALE,
        LEGAL,
        LEGAL_LIMITEDSALE,
        LEGAL_NOSALE,
        UNKNOWN,
        UNKNOWN_LIMITEDSALE,
        UNKNOWN_NOSALE,
        ILEGAL
    }

    enum CompanyType {
        STANDARD,
        LEGAL,
        UNKNOWN,
        BAN
    }

    struct Product {
        uint256 productCode;
        uint256 expirationDate;
        address companyId;
        address payable owner;
        uint256 price;
        uint256 productNumber;
        ProductType productType;
        bool forsale;
        bool exists;
    }

    event ProductAdded(
        uint256 productCode,
        uint256 productNumber,
        uint256 expirationDate,
        uint256 price,
        ProductType productType,
        address indexed companyId,
        address indexed owner,
        bool forsale,
        bool exists
    );

    event ProductTypeEdited(
        uint256 productCode,
        uint256 productNumber,
        ProductType newProductType,
        address indexed owner
    );
    event ForsaleEdited(
        uint256 productCode,
        uint256 productNumber,
        bool forSale,
        address indexed owner
    );

    event ProductSold(uint256 productCode, uint256 productNumber);

    mapping(uint256 => mapping(uint256 => Product)) private companyProducts;

    function addProduct(
        address payable _sender,
        uint256 _productCode,
        uint256 _expirationDate,
        uint256 _price,
        uint256 _productNumber,
        ProductType _productType
    ) public onlyOwner(_sender) {
        if (company_owner_type == CompanyType.STANDARD) {
            require(
                _productType < ProductType.LEGAL,
                "you cannot make product with this type"
            );
        } else if (company_owner_type == CompanyType.LEGAL) {
            require(
                _productType < ProductType.UNKNOWN &&
                    _productType >= ProductType.LEGAL,
                "you cannot make product with this type"
            );
        } else {
            require(
                _productType < ProductType.ILEGAL &&
                    _productType >= ProductType.UNKNOWN,
                "you cannot make product with this type"
            );
        }

        bool _forsale = false;
        bool _exists = true;
        // Check if a product with the given product code already exists for the calling company
        require(
            companyProducts[_productCode][_productNumber].exists == false,
            "Product with the given product number already exists"
        );
        // Create a new product and add it to the companyProducts mapping
        Product memory newProduct = Product(
            _productCode,
            _expirationDate,
            _sender,
            _sender,
            _price,
            _productNumber,
            _productType,
            _forsale,
            _exists
        );
        companyProducts[_productCode][_productNumber] = newProduct;
        emit ProductAdded(
            _productCode,
            _productNumber,
            _expirationDate,
            _price,
            _productType,
            _sender,
            _sender,
            _forsale,
            _exists
        );
    }

    function getProduct(
        uint256 _productCode,
        uint256 _productNumber
    ) public view returns (Product memory) {
        Product memory product = companyProducts[_productCode][_productNumber];
        require(
            product.exists != false,
            "No products with the given product number found"
        );
        return product;
    }

    function editProductType(
        address _sender,
        uint256 _productCode,
        uint256 _productNumber,
        ProductType _newProductType
    ) public onlyAdminAndOwner(_sender) {
        Product storage product = companyProducts[_productCode][_productNumber];
        require(
            product.exists != false,
            "No products with the given product number found"
        );
        product.productType = _newProductType;
        emit ProductTypeEdited(
            _productCode,
            _productNumber,
            _newProductType,
            _sender
        );
    }

    function editForSale(
        address _sender,
        uint256 _productCode,
        uint256 _productNumber,
        bool _forsale,
        bool _is_seller
    ) public {
        Product storage product = companyProducts[_productCode][_productNumber];
        require(
            product.exists != false,
            "No products with the given product number found"
        );
        require(
            product.owner == _sender || _sender == admin,
            "Only the product owner can edit the product type"
        );
        if (
            product.productType == ProductType.STANDARD_NOSALE ||
            product.productType == ProductType.LEGAL_NOSALE ||
            product.productType == ProductType.UNKNOWN_NOSALE
        ) {
            if (_sender != admin) {
                require(
                    product.owner == product.companyId,
                    "only saleble for company you can not sell this item"
                );
            }
        } else if (
            product.productType == ProductType.STANDARD_LIMITEDSALE ||
            product.productType == ProductType.LEGAL_LIMITEDSALE ||
            product.productType == ProductType.UNKNOWN_LIMITEDSALE
        ) {
            if (_sender != admin) {
                require(
                    product.owner == product.companyId || _is_seller,
                    "only saleble for company and verifid seller you can not sell this item"
                );
            }
        } else if (
            product.productType == ProductType.ILEGAL ||
            company_owner_type == CompanyType.BAN
        ) {
            revert("this item is illegal to sell");
        }
        product.forsale = _forsale;
        emit ForsaleEdited(_productCode, _productNumber, _forsale, _sender);
    }

    function editCompanyType(
        address _sender,
        CompanyType _company_owner_type
    ) public onlyAdmin(_sender) {
        company_owner_type = _company_owner_type;
    }

    function buyProduct(
        address payable _sender,
        uint _productCode,
        uint _productNumber
    ) public payable {
        // Retrieve the product from the storage using the given product code and number
        Product storage product = companyProducts[_productCode][_productNumber];
        require(
            product.exists != false,
            "No products with the given product number found"
        );
        require(
            product.productType != ProductType.ILEGAL,
            "This product is ilegal to buy"
        );
        require(product.forsale, "This product is not for sale");
        require(product.price == msg.value, "The value is not equal to price");
        require(product.owner != _sender, "You alredy own the product");
        product.owner.transfer(msg.value);
        product.owner = _sender;
        product.forsale = false;
    }

    modifier onlyOwner(address _sender) {
        require(
            _sender == company_owner,
            "Only company owner can perform this action"
        );
        _;
    }
    modifier onlyAdmin(address _sender) {
        require(_sender == admin, "Only admin can perform this action");
        _;
    }
    modifier onlyAdminAndOwner(address _sender) {
        require(
            _sender == company_owner || _sender == admin,
            "Only admin and company owner can perform this action"
        );
        _;
    }

    address private company_owner;
    address private admin;
    CompanyType company_owner_type;

    constructor(
        address _admin,
        address _company_owner,
        CompanyType _companyType
    ) {
        company_owner_type = _companyType;
        company_owner = _company_owner;
        admin = _admin;
    }
}
