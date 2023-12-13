# Smart Contracts for Product and Company Management

This repository contains three Solidity smart contracts: `ProductManagement`, `run`, and `UserManager`. These contracts collectively manage products within a decentralized system, handle the creation and management of user companies, and include user management functionalities.

## Table of Contents
- [`ProductManagement` Smart Contract](#productmanagement-smart-contract)
- [`run` Smart Contract](#run-smart-contract)
- [`UserManager` Smart Contract](#usermanager-smart-contract)
- [Usage](#usage)
- [Smart Contract Details](#smart-contract-details)
- [Modifiers](#modifiers)
- [Installation](#installation)
- [Deployment on Fantom Testnet](#deployment-on-fantom-testnet)
- [License](#license)

## `ProductManagement` Smart Contract

### Introduction

The `ProductManagement` smart contract facilitates product management within a decentralized environment. It defines various product types, company types, and provides functions for adding, editing, and buying products.

### Contract Features

- **Product Types**: The contract supports different product types, including standard, legal, and unknown. Each type has variations such as limited sale, no sale, or illegal.

- **Company Types**: Companies are categorized as standard, legal, unknown, or banned. The contract enforces specific product type restrictions based on the company type.

- **Product Addition**: Users can add products to the system with specific attributes such as expiration date, price, and product type.

- **Product Editing**: Product types and sale status can be edited by authorized users. Restrictions apply based on company and product types.

- **Product Purchase**: Users can buy products from the system, transferring ownership and updating the sale status.

- **Access Control**: The contract includes access control through modifiers, allowing only authorized users to perform certain actions.

## `run` Smart Contract

### Introduction

The `run` smart contract serves as the central hub for managing user companies and their associated product management contracts. It incorporates functionality for creating companies, adding products, managing product details, and handling user requests.

### Contract Features

- **Company Management**: Users can start their own companies and request changes to their company types (standard, legal, seller).

- **Product Addition**: Companies can add products to the system using the associated `ProductManagement` contract.

- **Product Editing**: Companies can edit product types, sale status, and other details through the linked `ProductManagement` contract.

- **User Requests**: Users can request changes to their company types, such as becoming a legal company or seller.

## `UserManager` Smart Contract

### Introduction

The `UserManager` smart contract manages user-related functionalities such as banning users, adding standard/legal companies, adding sellers, and handling user requests.

### Contract Features

- **User Banning**: Admin can ban users, preventing them from adding products. Bans can be removed later.

- **Company Management**: Users can be associated with standard, legal, or seller company types.

- **User Requests**: Users can request to change their company types (e.g., legal, standard, seller).

## Usage

To interact with the smart contracts, users can perform actions such as starting a company, adding products, editing product details, making requests to change their company types, and managing user bans.

## Smart Contract Details

- **UserManager Integration**: The contracts interact with the `UserManager` contract to handle user-related functionality, such as adding sellers, banning users, and managing company types.

- **ProductManagement Integration**: The `run` contract utilizes the `ProductManagement` contract for adding products, editing product details, and facilitating product transactions.

- **Modifiers**: The contracts include modifiers like `notBanned` and `onlyAdmin` to control access to certain functions.

## Modifiers

- `notBanned`: Ensures that the user making the transaction is not banned.
- `onlyAdmin`: Requires that the caller is the admin.
- `onlyDeployer`: Restricts access to only the contract deployer.

## Installation

Deploy the smart contracts to a compatible blockchain network that supports the Ethereum Virtual Machine (EVM). Set the initial admin address and deployer address during deployment.

## Deployment on Fantom Testnet

All three smart contracts have been deployed on the Fantom testnet. You can view the `ProductManagement` contract [here](https://thirdweb.com/fantom-testnet/0xcdb192C96287fF32Acd6E4AE2B41c919c240eB5D/code), the `run` contract [here](https://thirdweb.com/fantom-testnet/0xcdb192C96287fF32Acd6E4AE2B41c919c240eB5D/code), and the `UserManager` contract [here](https://thirdweb.com/fantom-testnet/0xcdb192C96287fF32Acd6E4AE2B41c919c240eB5D/code).

## License

These smart contracts are licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.

Feel free to explore and contribute to the development of these smart contracts. Happy coding!
