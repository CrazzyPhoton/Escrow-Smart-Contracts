# Escrow Smart Contracts

**Compatible with all EVM blockchains**
### [Ethereum Escrow](https://github.com/CrazzyPhoton/Escrow-Smart-Contracts/blob/main/Erc20Escrow.sol)
### [NFT Escrow](https://github.com/CrazzyPhoton/Escrow-Smart-Contracts/blob/main/NftEscrow.sol)
### [ERC20 Escrow](https://github.com/CrazzyPhoton/Escrow-Smart-Contracts/blob/main/Erc20Escrow.sol)

*The **Ethereum, NFT, and ERC20** escrow smart contracts facilitate secure transactions between buyers and sellers by acting as intermediaries. The contracts manage the process through various states, such as creation, funding, delivery, and completion. They incorporate built-in functions to handle disputes, revisions, and cancellations, ensuring smooth and transparent interactions between parties. An arbiter plays a critical role in overseeing conflicts, fairly allocating funds to the buyer, seller, and themselves based on the resolution, while also managing fees.*

*The contracts log all actions through events like "EscrowCreated," "EscrowFunded," and "EscrowCompleted," providing an audit trail that enhances transparency. Flexible configurations, such as setting the escrow provider fee and automatic withdrawal time, allow the arbiter to adjust the system to specific needs. Additionally, mappings keep track of each party’s escrows, issues, and cancellation requests, offering users clear visibility of their active and completed transactions. These features work together to protect the interests of all involved parties while ensuring the security and reliability of the escrow process.*

---

# Table of Contents

1. [ETH Escrow Smart Contract](#eth-escrow-smart-contract)
2. [NFT Escrow Smart Contract](#nft-escrow-smart-contract)
3. [ERC20 Escrow Smart Contract](#erc20-escrow-smart-contract)

---

# ETH Escrow Smart Contract

## Overview

This Solidity contract facilitates an Ethereum-based escrow service, where buyers and sellers can engage in transactions under the supervision of an arbiter. It supports escrow creation, funding, revision requests, delivery, and resolution of disputes.

## State Variables

### Core Variables
- **`arbiter`**: Address of the arbiter who can resolve disputes.
- **`canCreateNewEscrow`**: Boolean flag to enable or disable the creation of new escrows.
- **`canFundEscrow`**: Boolean flag to enable or disable the funding of escrows.
- **`ethEscrowId`**: Mapping to store information for each escrow identified by a unique ID.
- **`resolvedEscrowIdInfo`**: Mapping to store resolved escrow information.
- **`myEscrowsAsBuyer`**: Mapping to track escrow IDs associated with a buyer.
- **`myEscrowsAsSeller`**: Mapping to track escrow IDs associated with a seller.
- **`raisedIssueForEthEscrowId`**: Mapping to track whether an issue has been raised for a specific escrow.
- **`raisedIssueBy`**: Mapping to track the address that raised an issue for a specific escrow.
- **`raisedCancellationRequestForEthEscrowId`**: Mapping to track whether a cancellation request has been raised for a specific escrow.
- **`raisedCancellationRequestBy`**: Mapping to track the address that raised a cancellation request.
- **`escrowProviderFee`**: The fee percentage charged by the escrow provider (out of 100).
- **`automaticWithdrawTime`**: The default time after which funds can be automatically withdrawn.
- **`totalEthEscrowsCreated`**: The total number of escrows created.

### Structs
- **`EthEscrow`**: Represents an escrow with fields like buyer, seller, escrow state, ETH amount, delivery time, revisions, and provider fees.
- **`ResolvedEscrowInfo`**: Stores the resolved amounts for buyer, seller, and arbiter in the case of disputes.

## Events
- **`EscrowCreated`**: Emitted when a new escrow is created.
- **`EscrowFunded`**: Emitted when an escrow is funded by the buyer.
- **`DeliveredForEscrow`**: Emitted when an escrow is marked as delivered by the seller.
- **`RevisionRequestedForEscrow`**: Emitted when a revision is requested by the buyer.
- **`EscrowCompleted`**: Emitted when an escrow is completed.
- **`CancellationRequestRaisedForEscrow`**: Emitted when a cancellation request is raised.
- **`CancellationRequestClosedForEscrow`**: Emitted when a cancellation request is closed.
- **`CancellationRequestAcceptedForEscrow`**: Emitted when a cancellation request is accepted.
- **`IssueRaisedForEscrow`**: Emitted when an issue is raised for the escrow.
- **`IssueClosedForEscrow`**: Emitted when an issue is closed.
- **`IssueResolvedForEscrow`**: Emitted when an issue is resolved, with the breakdown of amounts for the buyer, seller, and arbiter.

## Functions
### 1. **createNewEthEscrow**

```solidity
    function createNewEthEscrow (
        address _buyer,
        uint256 _ethAmount,
        uint256 _revisionsOffered) public;
```
Creates a new escrow for a buyer and a seller.

- **Parameters**:
  - `_buyer`: The address of the buyer.
  - `_ethAmount`: The amount of ETH to be held in escrow.
  - `_revisionsOffered`: The number of revisions offered by the seller.

- **Requirements**:
  - The escrow creation feature must be enabled (`canCreateNewEscrow`).
  - The buyer must be a non-zero address and different from the seller.
  - The ETH amount must be greater than zero.

- **Emits**: `EscrowCreated`

### 2. **fundEthEscrow**

```solidity
    function fundEthEscrow(uint256 escrowId) public payable;
```
Funds an existing escrow with ETH from the buyer.

- **Parameters**:
  - `escrowId`: The ID of the escrow to fund.

- **Requirements**:
  - The escrow funding feature must be enabled (`canFundEscrow`).
  - The escrow must exist in a "Created" state.
  - The caller must be the buyer of the escrow.
  - The sent ETH value must match the escrow’s ETH amount.

- **Emits**: `EscrowFunded`

### 3. **markDeliveredForEthEscrow**

```solidity
    function markDeliveredForEthEscrow(uint256 escrowId) public;
```
Marks the escrow as delivered by the seller.

- **Parameters**:
  - `escrowId`: The ID of the escrow to mark as delivered.

- **Requirements**:
  - No active cancellation request or issues should be present for the escrow.
  - The escrow must be in a "Funded" or "InRevision" state.
  - The seller must be the caller.
  - The number of deliveries must not exceed the revisions offered.

- **Emits**: `DeliveredForEscrow`

### 4. **requestRevisionForEthEscrow**

```solidity
    function requestRevisionForEthEscrow(uint256 escrowId) public;
```
Allows the buyer to request a revision for a delivered escrow.

- **Parameters**:
  - `escrowId`: The ID of the escrow for revision request.

- **Requirements**:
  - The caller must be the buyer.
  - The escrow must be marked as "Delivered".
  - The revisions requested must not exceed the offered revisions.

- **Emits**: `RevisionRequestedForEscrow`

### 5. **markCompletedForEthEscrow**

```solidity
    function markCompletedForEthEscrow(uint256 escrowId) public;
```
Marks the escrow as completed, transferring funds to the seller and the escrow provider.

- **Parameters**:
  - `escrowId`: The ID of the escrow to mark as completed.

- **Requirements**:
  - An issue must not be raised for the escrow.
  - If the seller is marking it completed, the withdrawal time must have passed.
  - The caller must be the buyer, or the seller if the automatic withdrawal time has elapsed.

- **Emits**: `EscrowCompleted`

### 6. **raiseCancellationRequestForEthEscrow**

```solidity
    function raiseCancellationRequestForEthEscrow(uint256 escrowId) public;
```
Allows the buyer or seller to raise a cancellation request for an escrow.

- **Parameters**:
  - `escrowId`: The ID of the escrow.
  
- **Requirements**:
  - The escrow must be in the "Funded" state.
  - No active cancellation request should exist for the escrow.
  - The caller must be either the buyer or the seller.

- **Emits**: `CancellationRequestRaisedForEscrow`

### 7. **closeCancellationRequestForEthEscrowId**

```solidity
    function closeCancellationRequestForEthEscrowId(uint256 escrowId) public;
```
Allows the caller (who raised the cancellation request) to close it.

- **Parameters**:
  - `escrowId`: The ID of the escrow.
  
- **Requirements**:
  - A cancellation request must be active.
  - The caller must be the one who raised the cancellation request.

- **Emits**: `CancellationRequestClosedForEscrow`

### 8. **acceptCancellationRequestForEthEscrowId**

```solidity
    function acceptCancellationRequestForEthEscrowId(uint256 escrowId) public;
```
Allows either the buyer or the seller to accept the cancellation request.

- **Parameters**:
  - `escrowId`: The ID of the escrow.

- **Requirements**:
  - If the buyer raised the cancellation request, the seller must accept it.
  - If the seller raised the cancellation request, the buyer must accept it.
  - The escrow will be marked as "Cancelled", and the buyer will receive the ETH back.

- **Emits**: `CancellationRequestAcceptedForEscrow`

### 9. **raiseIssueForEthEscrowId**

```solidity
    function raiseIssueForEthEscrowId(uint256 escrowId) public;
```
Allows the buyer or seller to raise an issue with the escrow.

- **Parameters**:
  - `escrowId`: The ID of the escrow.

- **Requirements**:
  - The escrow must be in "Funded" or "Delivered" state.
  - No issue should be raised already for the escrow.
  - The caller must be either the buyer or the seller.

- **Emits**: `IssueRaisedForEscrow`

### 10. **closeIssueForEthEscrowId**

```solidity
    function closeIssueForEthEscrowId(uint256 escrowId) public;
```
Allows the arbiter or the person who raised the issue to close it.

- **Parameters**:
  - `escrowId`: The ID of the escrow.

- **Requirements**:
  - An issue must be raised for the escrow.
  - The caller must be either the arbiter or the one who raised the issue.

- **Emits**: `IssueClosedForEscrow`

### 11. **resolveIssueForEthEscrowId**

```solidity
    function resolveIssueForEthEscrowId(uint256 escrowId, uint256 _buyerAmount, uint256 _sellerAmount) public;
```
Allows the arbiter to resolve the issue by distributing the funds.

- **Parameters**:
  - `escrowId`: The ID of the escrow.
  - `_buyerAmount`: The ETH amount the buyer will receive.
  - `_sellerAmount`: The ETH amount the seller will receive.

- **Requirements**:
  - An issue must be raised for the escrow.
  - The caller must be the arbiter.
  - The total of `_buyerAmount`, `_sellerAmount`, and the arbiter's fee must equal the original escrow amount.

- **Emits**: `IssueResolvedForEscrow`

### 12. **setAutomaticWithdrawTime**

```solidity
    function setAutomaticWithdrawTime(uint8 _automaticWithdrawTime) public;
```
Allows the arbiter to set the automatic withdrawal time for the escrow.

- **Parameters**:
  - `_automaticWithdrawTime`: The time in seconds after which the seller can withdraw their payment if no action has been taken by the buyer.

- **Requirements**:
  - The caller must be the arbiter.

### 13. **setCanCreateNewEscrow**

```solidity
    function setCanCreateNewEscrow(bool state) public;
```
Allows the arbiter to enable or disable the creation of new escrows.

- **Parameters**:
  - `state`: Set to `true` to enable, or `false` to disable the creation of new escrows.

- **Requirements**:
  - The caller must be the arbiter.

### 14. **setCanFundEscrow**

```solidity
    function setCanFundEscrow(bool state) public;
```
Allows the arbiter to enable or disable escrow funding.

- **Parameters**:
  - `state`: Set to `true` to enable, or `false` to disable escrow funding.

- **Requirements**:
  - The caller must be the arbiter.

### 15. **setEscrowProviderFee**

```solidity
    function setEscrowProviderFee(uint8 _escrowProviderFee) public;
```
Allows the arbiter to set the escrow provider fee as a percentage.

- **Parameters**:
  - `_escrowProviderFee`: The escrow provider fee percentage (out of 100).

- **Requirements**:
  - The caller must be the arbiter.
  - The fee must be less than or equal to 100%.

### 16. **setNewArbiter**

```solidity
    function setNewArbiter(address newArbiter) public;
```
Allows the arbiter to set a new arbiter.

- **Parameters**:
  - `newArbiter`: The address of the new arbiter.

- **Requirements**:
  - The caller must be the current arbiter.
  - The new arbiter address must be valid (not the zero address).

### 17. **viewMyEscrowsAsBuyer**

```solidity
    function viewMyEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory escrowIds);
```
Views your current escrows as a buyer.

- **Parameters**:
  - `myAddress`: Your address.

- **Returns**: An array of escrow IDs associated with your address.

### 18. **viewMyFundedEscrowsAsBuyer**

```solidity
    function viewMyFundedEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory fundedEscrowIds);
```
Views your current funded escrows as a buyer.

- **Parameters**:
  - `myAddress`: Your address.

- **Returns**: An array of escrow IDs that are in the `Funded` state.

### 19. **viewMyActiveCancellationRequestsAsBuyer**

```solidity
    function viewMyActiveCancellationRequestsAsBuyer(address myAddress) public view returns (
        uint256[] memory activeRequestsRaisedByBuyerForEscrowIds, 
        uint256[] memory activeRequestsRaisedTowardsBuyerForEscrowIds
    );
```
Views active cancellation requests raised by you and raised towards you as a buyer.

- **Parameters**:
  - `myAddress`: Your address.

- **Returns**:
  - `activeRequestsRaisedByBuyerForEscrowIds`: Escrow IDs where you raised the cancellation request.
  - `activeRequestsRaisedTowardsBuyerForEscrowIds`: Escrow IDs where a cancellation request was raised towards you.

### 20. **viewMyCancelledEscrowsAsBuyer**

```solidity
    function viewMyCancelledEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory cancelledEscrowIds);
```
Views your cancelled escrows as a buyer.

- **Parameters**:
  - `myAddress`: Your address.

- **Returns**: An array of escrow IDs that are in the `Cancelled` state.

### 21. **viewMyActiveIssuesAsBuyer**

```solidity
    function viewMyActiveIssuesAsBuyer(address myAddress) public view returns (
        uint256[] memory activeIssuesRaisedByBuyerForEscrowIds, 
        uint256[] memory activeIssuesRaisedTowardsBuyerForEscrowIds
    );
```
Views active issues raised by you and raised towards you as a buyer.

- **Parameters**:
  - `myAddress`: Your address.

- **Returns**:
  - `activeIssuesRaisedByBuyerForEscrowIds`: Escrow IDs where you raised the issue.
  - `activeIssuesRaisedTowardsBuyerForEscrowIds`: Escrow IDs where an issue was raised towards you.

### 22. **viewMyResolvedEscrowsAsBuyer**

```solidity
    function viewMyResolvedEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory resolvedEscrowIds);
```
Views your resolved escrows as a buyer.

- **Parameters**:
  - `myAddress`: Your address.

- **Returns**: An array of escrow IDs that are in the `Resolved` state.

### 23. **viewMyDeliveredEscrowsAsBuyer**

```solidity
    function viewMyDeliveredEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory deliveredEscrowIds);
```
Views your delivered escrows as a buyer.

- **Parameters**:
  - `myAddress`: Your address.

- **Returns**: An array of escrow IDs that are in the `Delivered` state.

### 24. **viewMyInRevisionEscrowsAsBuyer**

```solidity
    function viewMyInRevisionEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory inrevisionEscrowIds);
```
Views your escrows that are under revision as a buyer.

- **Parameters**:
  - `myAddress`: Your address.

- **Returns**: An array of escrow IDs that are in the `InRevision` state.

### 25. **viewMyCompletedEscrowsAsBuyer**

```solidity
    function viewMyCompletedEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory completedEscrowIds);
```
Views your completed escrows as a buyer.

- **Parameters**:
  - `myAddress`: Your address.

- **Returns**: An array of escrow IDs that are in the `Completed` state.

### 26. **viewMyEscrowsAsSeller**

```solidity
    function viewMyEscrowsAsSeller(address myAddress) public view returns (uint256[] memory escrowIds);
```
Views your current escrows as a seller.

- **Parameters**: 
  - `myAddress`: Your address.

- **Returns**: Array of `escrowIds`.

### 27. **viewMyFundedEscrowsAsSeller**

```solidity
    function viewMyFundedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory fundedEscrowIds);
```
Views your current funded escrows as a seller.

- **Parameters**: 
  - `myAddress`: Your address.

- **Returns**: Array of `fundedEscrowIds`.

### 28. **viewMyActiveCancellationRequestsAsSeller**

```solidity
    function viewMyActiveCancellationRequestsAsSeller(address myAddress) public view returns (
        uint256[] memory activeRequestsRaisedBySellerForEscrowIds, 
        uint256[] memory activeRequestsRaisedTowardsSellerForEscrowIds
    );
```
Views active cancellation requests raised by you and raised towards you as a seller.

- **Parameters**: 
  - `myAddress`: Your address.

- **Returns**: 
  - `activeRequestsRaisedBySellerForEscrowIds`: Active cancellation requests raised by you.
  - `activeRequestsRaisedTowardsSellerForEscrowIds`: Active cancellation requests raised towards you.

### 29. **viewMyCancelledEscrowsAsSeller**

```solidity
    function viewMyCancelledEscrowsAsSeller(address myAddress) public view returns(uint256[] memory cancelledEscrowIds);
```
Views your cancelled escrows as a seller.

- **Parameters**: 
  - `myAddress`: Your address.

- **Returns**: Array of `cancelledEscrowIds`.

### 30. **viewMyActiveIssuesAsSeller**

```solidity
    function viewMyActiveIssuesAsSeller(address myAddress) public view returns (
        uint256[] memory activeIssuesRaisedBySellerForEscrowIds, 
        uint256[] memory activeIssuesRaisedTowardsSellerForEscrowIds
    );
```
Views active issues raised by you and raised towards you as a seller.

- **Parameters**: 
  - `myAddress`: Your address.

- **Returns**: 
  - `activeIssuesRaisedBySellerForEscrowIds`: Active issues raised by you.
  - `activeIssuesRaisedTowardsSellerForEscrowIds`: Active issues raised towards you.

### 31. **viewMyResolvedEscrowsAsSeller**

```solidity
    function viewMyResolvedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory resolvedEscrowIds);
```
Views your resolved escrows as a seller.

- **Parameters**: 
  - `myAddress`: Your address.

- **Returns**: Array of `resolvedEscrowIds`.

### 32. **viewMyDeliveredEscrowsAsSeller**

```solidity
    function viewMyDeliveredEscrowsAsSeller(address myAddress) public view returns(uint256[] memory deliveredEscrowIds);
```
Views your delivered escrows as a seller.

- **Parameters**: 
  - `myAddress`: Your address.

- **Returns**: Array of `deliveredEscrowIds`.

### 33. **viewMyInRevisionEscrowsAsSeller**

```solidity
    function viewMyInRevisionEscrowsAsSeller(address myAddress) public view returns(uint256[] memory inrevisionEscrowIds);
```
Views your in-revision escrows as a seller.

- **Parameters**: 
  - `myAddress`: Your address.

- **Returns**: Array of `inrevisionEscrowIds`.

### 34. **viewMyCompletedEscrowsAsSeller**

```solidity
    function viewMyCompletedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory completedEscrowIds);
```
Views your completed escrows as a seller.

- **Parameters**: 
  - `myAddress`: Your address.

- **Returns**: Array of `completedEscrowIds`.

### 35. **viewActiveIssues**

```solidity
    function viewActiveIssues() public view returns (uint256[] memory activeIssuesEscrowIds);
```
Views active escrows with issues raised.

- **Returns**: Array of `activeIssuesEscrowIds`.

### 36. **viewResolvedEscrowIdInfo**

```solidity
    function viewResolvedEscrowIdInfo(uint256 escrowId) public view returns (ResolvedEscrowInfo memory resolvedEscrowInfo);
```
Views a resolved escrow's info.

- **Parameters**: 
  - `escrowId`: The escrow's ID.

- **Returns**: `ResolvedEscrowInfo` object.

---

# NFT Escrow Smart Contract

## Overview
The `NftEscrowSmartContract` enables secure and decentralized transactions of NFTs between buyers and sellers using Ethereum blockchain technology. It supports creating, funding, and managing escrow accounts for NFT transfers, ensuring both parties' safety and agreement. The contract incorporates features like revisions, issues, cancellation requests, and automatic withdrawals.

## State Variables

### Core Variables
- **`arbiter`**: Address of the arbiter.
- **`canCreateNewEscrow`**: Boolean flag for enabling/disabling escrow creation.
- **`canFundEscrow`**: Boolean flag for enabling/disabling escrow funding.
- **`escrowProviderFee`**: The fee charged for each escrow in ETH.
- **`automaticWithdrawTime`**: Time in hours for automatic withdrawal eligibility.
- **`totalNftEscrowsCreated`**: Total number of escrows created.

### Mappings
- **`nftEscrowId`**: Maps escrow IDs to their respective NFT escrow details.
- **`resolvedEscrowIdInfo`**: Maps escrow IDs to their resolution details.
- **`myEscrowsAsBuyer`/`myEscrowsAsSeller`**: Maps users to their escrow IDs as buyers or sellers.
- **`raisedIssueForNftEscrowId`/`raisedCancellationRequestForNftEscrowId`**: Flags for issues or cancellation requests.
- **`raisedIssueBy`/`raisedCancellationRequestBy`**: Tracks which address raised an issue or cancellation request.
- **`hasSellerPayedEscrowProviderFee`**: Tracks whether the seller has paid the escrow provider fee.

## Events
- **`EscrowCreated`**: Logs details when a new escrow is created.
- **`EscrowFunded`**: Logs details when an escrow is funded.
- **`DeliveredForEscrow`**: Logs delivery details for an escrow.
- **`RevisionRequestedForEscrow`**: Logs revision requests.
- **`EscrowCompleted`**: Logs completion of an escrow.
- **`CancellationRequestRaisedForEscrow`**: Logs a cancellation request.
- **`IssueRaisedForEscrow`**: Logs an issue raised for an escrow.
- **`IssueResolvedForEscrow`**: Logs resolution details for an escrow.

## Functions
### 1. **createNewNftEscrow**
```solidity
function createNewNftEscrow(
    address _buyer,
    IERC721[] calldata _nftCollectionsAdresses,
    uint256[] calldata _nftTokenIds,
    uint256 _revisionsOffered
) public;
```
Creates a new escrow with the specified details.

- **Parameters**:
  - `_buyer`: Address of the buyer.
  - `_nftCollectionsAdresses`: Array of NFT collection addresses.
  - `_nftTokenIds`: Array of token IDs for the NFTs.
  - `_revisionsOffered`: Number of revisions offered by the seller.

- **Requirements**:
  - `canCreateNewEscrow` must be `true`.
  - `_buyer` must not be the zero address or the same as the caller.
  - NFT collection addresses and token IDs must be provided.

- **Emits**: `EscrowCreated`

### 2. **fundNftEscrow**

```solidity
function fundNftEscrow(uint256 escrowId) public;
```
Funds an escrow with NFTs.

- **Parameters**:
  - `escrowId`: ID of the escrow to fund.

- **Requirements**:
  - `canFundEscrow` must be `true`.
  - Caller must be the buyer of the escrow.

- **Emits**: `EscrowFunded`

### 3. **payEscrowProviderFeeBySeller**

```solidity
function payEscrowProviderFeeBySeller(uint256 escrowId) public payable;
```
Pays the escrow provider fee.

- **Parameters**:
  - `escrowId`: ID of the escrow.

- **Requirements**:
  - Caller must be the seller of the escrow.
  - The fee must match `escrowProviderFee`.

### 4. **markDeliveredForNftEscrow**

```solidity
function markDeliveredForNftEscrow(uint256 escrowId) public;
```
Marks an escrow as delivered.

- **Parameters**:
  - `escrowId`: ID of the escrow.

- **Requirements**:
  - Caller must be the seller.
  - Seller must have paid the escrow provider fee.

- **Emits**: `DeliveredForEscrow`

### 5. **requestRevisionForNftEscrow**

```solidity
function requestRevisionForNftEscrow(uint256 escrowId) public;
```
Requests a revision for an escrow.

- **Parameters**:
  - `escrowId`: ID of the escrow.

- **Requirements**:
  - Caller must be the buyer.

-**Emits**: `RevisionRequestedForEscrow`

### 6. **markCompletedForNftEscrow**

```solidity
function markCompletedForNftEscrow(uint256 escrowId) public;
```
Marks an escrow as completed.

- **Parameters**:
  - `escrowId`: ID of the escrow.

- **Requirements**:
  - Caller must be the buyer, or seller if automatic withdrawal time has elapsed.

-**Emits**: `EscrowCompleted`

### 7. **raiseCancellationRequestForNftEscrow**

```solidity
    function raiseCancellationRequestForNftEscrow(uint256 escrowId) public;
```
Allows a buyer or seller to raise a cancellation request for a specific escrow.

- **Parameters**:
  - `escrowId`: The ID of the escrow.

- **Requirements**:
  - Escrow must be in the `Funded` state.
  - Caller must be the buyer or seller of the escrow.
  - Seller must have paid the escrow provider fee (if the caller is the seller).

- **Emits**: `CancellationRequestRaisedForEscrow`

### 8. **closeCancellationRequestForNftEscrowId**

```solidity
    function closeCancellationRequestForNftEscrowId(uint256 escrowId) public;
```
Allows the party who raised the cancellation request to close it.

- **Parameters**:
  - `escrowId`: The ID of the escrow.

- **Requirements**:
  - A cancellation request must exist for the escrow.
  - Caller must be the one who raised the cancellation request.

- **Emits**: `CancellationRequestClosedForEscrow`.

### 9. **acceptCancellationRequestForNftEscrowId**

```solidity
    function acceptCancellationRequestForNftEscrowId(uint256 escrowId) public;
```
Allows the counterparty to accept the cancellation request, resulting in escrow cancellation.

- **Parameters**:
  - `escrowId`: The ID of the escrow.

- **Requirements**:
  - Caller must be the counterparty of the request raiser.
  - Transfers NFTs and escrow fees appropriately.

- **Emits**: `CancellationRequestAcceptedForEscrow`.

### 10. **raiseIssueForNftEscrowId**

```solidity
    function raiseIssueForNftEscrowId(uint256 escrowId) public;
```
Allows a buyer or seller to raise an issue for a specific escrow.

- **Parameters**:
  - `escrowId`: The ID of the escrow.

- **Requirements**:
  - Escrow must be in the `Funded` or `Delivered` state.
  - Caller must be the buyer or seller of the escrow.
  - Seller must have paid the escrow provider fee (if the caller is the seller).

- **Emits**: `IssueRaisedForEscrow`.

### 11. **closeIssueForNftEscrowId**

```solidity
    function raiseIssueForNftEscrowId(uint256 escrowId) public;
```
Allows the arbiter or the party who raised the issue to close it.
- **Parameters**:
  - `escrowId`: The ID of the escrow.
- **Requirements**:
  - An issue must exist for the escrow.
  - Caller must be the arbiter or the party who raised the issue.
- **Emits**: `IssueClosedForEscrow`.

### 12. **resolveIssueForNftEscrowId**

```solidity
    function resolveIssueForNftEscrowId(
        uint256 escrowId, 
        IERC721[] calldata collectionAddressesForBuyer, 
        uint256[] calldata tokenIdsForBuyer, 
        IERC721[] calldata collectionAddressesForSeller, 
        uint256[] calldata tokenIdsForSeller) public;
```
Allows the arbiter to resolve an issue by redistributing NFTs and funds between buyer and seller.

- **Parameters**:
  - `escrowId`: The ID of the escrow.
  - `collectionAddressesForBuyer`: Array of NFT collection addresses for the buyer.
  - `tokenIdsForBuyer`: Corresponding token IDs for the buyer.
  - `collectionAddressesForSeller`: Array of NFT collection addresses for the seller.
  - `tokenIdsForSeller`: Corresponding token IDs for the seller.

- **Requirements**:
  - An issue must exist for the escrow.
  - Caller must be the arbiter.
  - Arrays for collections and token IDs must have equal lengths.

- **Emits**: `IssueResolvedForEscrow`.

### 13. **setAutomaticWithdrawTime**

```solidity
    function setAutomaticWithdrawTime(uint8 _automaticWithdrawTime) public;
```
Allows the arbiter to set the automatic withdrawal time after which the seller can withdraw payments automatically if no action is taken by the buyer.

- **Parameters**:
  - `_automaticWithdrawTime`: The withdrawal time in seconds.

- **Requirements**:
  - Caller must be the arbiter.

### 14. **setCanCreateNewEscrow**

```solidity
    function setCanCreateNewEscrow(bool state) public;
```
Enables or disables the creation of new escrows.

- **Parameters**:
  - `state`: Set to `true` to allow new escrows; `false` to disable.

- **Requirements**:
  - Caller must be the arbiter.

### 15. **setCanFundEscrow**

```solidity
    function setCanFundEscrow(bool state) public;
```
Enables or disables the funding of escrows.

- **Parameters**:
  - `state`: Set to `true` to allow funding; `false` to disable.

- **Requirements**:
  - Caller must be the arbiter.

### 16. **setEscrowProviderFee**

```solidity
    function setEscrowProviderFee(uint256 _escrowProviderFee) public;
```
Sets the escrow provider fee in ETH.

- **Parameters**:
  - `_escrowProviderFee`: Fee amount in wei.

- **Requirements**:
  - Caller must be the arbiter.

### 17. **setNewArbiter**

```solidity
    function setNewArbiter(address newArbiter) public;
```
Assigns a new arbiter to the contract.

- **Parameters**:
  - `newArbiter`: The address of the new arbiter.

- **Requirements**:
  - Caller must be the current arbiter.
  - `newArbiter` cannot be the zero address.

### 18. **viewMyEscrowsAsBuyer**

```solidity
    function viewMyEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory escrowIds);
```
Returns a list of escrow IDs associated with the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of escrow IDs.

### 19. **viewMyFundedEscrowsAsBuyer**

```solidity
    function viewMyFundedEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory fundedEscrowIds);
```
Returns a list of funded escrow IDs for the buyer.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of funded escrow IDs.

### 20. **viewMyActiveCancellationRequestsAsBuyer**

```solidity
    function viewMyActiveCancellationRequestsAsBuyer(address myAddress) public view returns (
        uint256[] memory activeRequestsRaisedByBuyerForEscrowIds, 
        uint256[] memory activeRequestsRaisedTowardsBuyerForEscrowIds
    );
```
Returns active cancellation requests raised by and towards the buyer.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `(uint256[], uint256[])`: Two arrays:
    - Escrow IDs for requests raised by the buyer.
    - Escrow IDs for requests raised towards the buyer.

### 21. **viewMyCancelledEscrowsAsBuyer**

```solidity
    function viewMyCancelledEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory cancelledEscrowIds);
```
Returns a list of cancelled escrow IDs for the buyer.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of cancelled escrow IDs.

### 22. **viewMyActiveIssuesAsBuyer**

```solidity
    function viewMyActiveIssuesAsBuyer(address myAddress) public view returns (
        uint256[] memory activeIssuesRaisedByBuyerForEscrowIds, 
        uint256[] memory activeIssuesRaisedTowardsBuyerForEscrowIds
    );
```
Returns active issues raised by and towards the buyer.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `(uint256[], uint256[])`: Two arrays:
    - Escrow IDs for issues raised by the buyer.
    - Escrow IDs for issues raised towards the buyer.

### 23. **viewMyResolvedEscrowsAsBuyer**

```solidity
    function viewMyResolvedEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory resolvedEscrowIds);
```
Returns a list of resolved escrow IDs for the buyer.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of resolved escrow IDs.

### 24. **viewMyDeliveredEscrowsAsBuyer**

```solidity
    function viewMyDeliveredEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory deliveredEscrowIds);
```
Returns a list of delivered escrow IDs for the buyer.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of delivered escrow IDs.

### 25. **viewMyInRevisionEscrowsAsBuyer**

```solidity
    function viewMyInRevisionEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory inrevisionEscrowIds);
```
Returns a list of in-revision escrow IDs for the buyer.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of in-revision escrow IDs.

### 26. **viewMyCompletedEscrowsAsBuyer**

```solidity
    function viewMyCompletedEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory completedEscrowIds);
```
Returns a list of completed escrow IDs for the buyer.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of completed escrow IDs.

### 27. **viewMyEscrowsAsSeller**

```solidity
    function viewMyEscrowsAsSeller(address myAddress) public view returns (uint256[] memory escrowIds);
```
Returns a list of escrow IDs associated with the seller.

- **Parameters**:
  - `myAddress`: Seller's address.

- **Returns**:
  - `uint256[]`: Array of escrow IDs.

### 28. **viewMyFundedEscrowsAsSeller**

```solidity
    function viewMyFundedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory fundedEscrowIds);
```
Returns a list of funded escrows for the seller.

- **Parameters**:
  - `myAddress`: Seller's address.

- **Returns**:
  - `uint256[]`: Array of funded escrow IDs.

### 29. **viewMyActiveCancellationRequestsAsSeller**

```solidity
    function viewMyActiveCancellationRequestsAsSeller(address myAddress) public view returns (
        uint256[] memory activeRequestsRaisedBySellerForEscrowIds, 
        uint256[] memory activeRequestsRaisedTowardsSellerForEscrowIds
    );
```
Returns active cancellation requests raised by or towards the seller.

- **Parameters**:
  - `myAddress`: Seller's address.

- **Returns**:
  - `(uint256[], uint256[])`: Two arrays:
    - Escrow IDs for requests raised by the seller.
    - Escrow IDs for requests raised towards the seller.

### 30. **viewMyCancelledEscrowsAsSeller**

```solidity
    function viewMyCancelledEscrowsAsSeller(address myAddress) public view returns(uint256[] memory cancelledEscrowIds);
```
Returns a list of cancelled escrows for the seller.

- **Parameters**:
  - `myAddress`: Seller's address.

- **Returns**:
  - `uint256[]`: Array of cancelled escrow IDs.

### 31. **viewMyActiveIssuesAsSeller**

```solidity
   function viewMyActiveIssuesAsSeller(address myAddress) public view returns (
       uint256[] memory activeIssuesRaisedBySellerForEscrowIds, 
       uint256[] memory activeIssuesRaisedTowardsSellerForEscrowIds
   );
```
Returns active issues raised by or towards the seller.

- **Parameters**:
  - `myAddress`: Seller's address.

- **Returns**:
  - `(uint256[], uint256[])`: Two arrays:
    - Escrow IDs for issues raised by the seller.
    - Escrow IDs for issues raised towards the seller.

### 32. **viewMyResolvedEscrowsAsSeller**

```solidity
    function viewMyResolvedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory resolvedEscrowIds);
```
Returns a list of resolved escrows for the seller.

- **Parameters**:
  - `myAddress`: Seller's address.

- **Returns**:
  - `uint256[]`: Array of resolved escrow IDs.

### 33. **viewMyDeliveredEscrowsAsSeller**

```solidity
    function viewMyDeliveredEscrowsAsSeller(address myAddress) public view returns(uint256[] memory deliveredEscrowIds);
```
Returns a list of delivered escrows for the seller.

- **Parameters**:
  - `myAddress`: Seller's address.

- **Returns**:
  - `uint256[]`: Array of delivered escrow IDs.

### 34. **viewMyInRevisionEscrowsAsSeller**

```solidity
    function viewMyInRevisionEscrowsAsSeller(address myAddress) public view returns(uint256[] memory inrevisionEscrowIds);
```
Returns a list of "in-revision" escrow IDs for the given seller.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: An array of escrow IDs where the state is `InRevision`.

### 35. **viewMyCompletedEscrowsAsSeller**

```solidity
    function viewMyCompletedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory completedEscrowIds);
```
Returns a list of "completed" escrow IDs for the given seller.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: An array of escrow IDs where the state is `Completed`.

### 36. **viewActiveIssues**

```solidity
    function viewActiveIssues() public view returns (uint256[] memory activeIssuesEscrowIds);
```
Returns a list of active escrows with issues raised.

- **Returns**:
  - `uint256[]`: Array of active issue escrow IDs.

### 37. **viewResolvedEscrowIdInfo**

```solidity
    function viewResolvedEscrowIdInfo(uint256 escrowId) public view returns (ResolvedEscrowInfo memory resolvedEscrowInfo);
```
Returns detailed information about a resolved escrow.

- **Parameters**:
  - `escrowId`: The ID of the resolved escrow.

- **Returns**:
  - `ResolvedEscrowInfo`: Struct containing escrow details.

---

# ERC20 Escrow Smart Contract

## Overview

The **ERC20 Escrow Smart Contract** facilitates secure transactions between buyers and sellers by holding ERC20 tokens in escrow until specific conditions are met. This ensures trust and fairness in transactions.

## State Variables

### Core Variables
- **`canCreateNewEscrow`**: Enables/disables escrow creation.
- **`canFundEscrow`**: Enables/disables escrow funding.
- **`erc20EscrowId`**: Mapping to store escrow details identified by a unique ID.
- **`myEscrowsAsBuyer`**: Mapping to track escrow IDs associated with a buyer.
- **`myEscrowsAsSeller`**: Mapping to track escrow IDs associated with a seller.
- **`raisedIssueForErc20EscrowId`**: Mapping to track if an issue is raised for an escrow.
- **`raisedIssueBy`**: Mapping to track the address that raised the issue.
- **`raisedCancellationRequestForErc20EscrowId`**: Mapping to track if a cancellation request is raised.
- **`raisedCancellationRequestBy`**: Mapping to track the address that raised the cancellation request.
- **`escrowProviderFee`**: The fee percentage charged by the escrow provider (out of 100).
- **`automaticWithdrawTime`**: The default time after which funds can be automatically withdrawn.
- **`totalErc20EscrowsCreated`**: The total number of escrows created.

## Structs

### `Erc20Escrow`
- **`buyer`**: Address of the buyer.
- **`seller`**: Address of the seller.
- **`escrowState`**: Current state of the escrow.
- **`erc20Token`**: ERC20 token used in the escrow.
- **`erc20TokenAmount`**: Amount of tokens in escrow.
- **`deliverdAtTime`**: Time of delivery.
- **`revisionsOffered`**: Number of revisions offered.
- **`totalDeliveries`**: Total number of deliveries.
- **`revisionsRequested`**: Number of revisions requested.
- **`escrowProviderFeeForEscrow`**: Fee for the escrow provider.
- **`automaticWithdrawTimeForEscrow`**: Automatic withdraw time for the escrow.

### `ResolvedEscrowInfo`
- **`buyerAmount`**: Amount allocated to the buyer.
- **`sellerAmount`**: Amount allocated to the seller.
- **`arbiterAmount`**: Amount allocated to the arbiter.

## Events
- **`EscrowCreated`**: Indicates the creation of a new escrow.
- **`EscrowFunded`**: Confirms that the escrow has been funded.
- **`EscrowCompleted`**: Signals the successful completion of an escrow.
- **`DeliveredForEscrow`**: Marks an escrow as delivered.
- **`RevisionRequestedForEscrow`**: Indicates a request for revision.
- **`IssueRaisedForEscrow`**: Indicates that an issue has been raised.
- **`CancellationRequestRaisedForEscrow`**: Signals that a cancellation request has been raised.
- **`IssueResolvedForEscrow`**: Marks the resolution of an issue and the distribution of funds.

## Functions

### 1. **createNewErc20Escrow**

```solidity
function createNewErc20Escrow (
    address _buyer,
    IERC20 _erc20Token,
    uint256 _erc20TokenAmount,
    uint256 _revisionsOffered
) public;
```
Creates a new escrow with specified buyer, ERC20 token, token amount, and revisions offered.

- **Parameters**:
  - `_buyer`: Address of the buyer.
  - `_erc20Token`: Address of the ERC20 token contract.
  - `_erc20TokenAmount`: Amount of tokens to be escrowed.
  - `_revisionsOffered`: Number of revisions offered to the buyer.

- **Requirements**:
  - Caller must be the seller.
  - `_buyer` and `_erc20Token` cannot be zero addresses.
  - `_erc20TokenAmount` must be greater than zero.

- **Emits**:
  - `EscrowCreated`

### 2. **fundErc20Escrow**

```solidity
function fundErc20Escrow(uint256 escrowId) public;
```
Allows the buyer to fund the escrow with the agreed ERC20 token amount.

- **Parameters**:
  - `escrowId`: The ID of the escrow to be funded.

- **Requirements**:
  - Caller must be the buyer.
  - The escrow must be in the `Created` state.
  - Buyer must have sufficient token balance and allowance.

- **Emits**:
  - `EscrowFunded`

### 3. **markDeliveredForErc20Escrow**

```solidity
function markDeliveredForErc20Escrow(uint256 escrowId) public;
```
Allows the seller to mark the escrow as delivered.

- **Parameters**:
  - `escrowId`: The ID of the escrow to be marked as delivered.

- **Requirements**:
  - Caller must be the seller.
  - The escrow must be in the `Funded` state.

- **Emits**:
  - `DeliveredForEscrow`

### 4. **requestRevisionForErc20Escrow**

```solidity
function requestRevisionForErc20Escrow(uint256 escrowId) public;
```
Enables the buyer to request a revision after delivery.

- **Parameters**:
  - `escrowId`: The ID of the escrow for which a revision is requested.

- **Requirements**:
  - Caller must be the buyer.
  - The escrow must be in the `Delivered` state.
  - The number of revisions requested must not exceed the offered revisions.

- **Emits**:
  - `RevisionRequestedForEscrow`

### 5. **markCompletedForErc20Escrow**

```solidity
function markCompletedForErc20Escrow(uint256 escrowId) public;
```
Marks the escrow as completed. Can be triggered by the buyer or automatically by the seller after the withdrawal time has elapsed.

- **Parameters**:
  - `escrowId`: The ID of the escrow to be completed.

- **Requirements**:
  - Caller must be the buyer or seller.
  - The escrow must be in the `Delivered` state.
  - If the seller calls this, the automatic withdrawal time must have elapsed.

- **Emits**:
  - `EscrowCompleted`

### 6. **raiseCancellationRequestForErc20Escrow**

```solidity
function raiseCancellationRequestForErc20Escrow(uint256 escrowId) public;
```
Allows the buyer or seller to raise a cancellation request for a specific escrow ID.

- **Parameters**:
  - `escrowId`: The ID of the escrow to raise the cancellation request for.

- **Requirements**:
  - The escrow must be in the `Funded` state.
  - No active cancellation request should exist.
  - Caller must be either the buyer or seller.

- **Emits**:
  - `CancellationRequestRaisedForEscrow`

### 7. **closeCancellationRequestForErc20EscrowId**

```solidity
function closeCancellationRequestForErc20EscrowId(uint256 escrowId) public;
```
Allows the individual who raised the cancellation request to close it.

- **Parameters**:
  - `escrowId`: The ID of the escrow with the active cancellation request.

- **Requirements**:
  - A cancellation request must be active for the escrow.
  - Caller must be the one who raised the cancellation request.

- **Emits**:
  - `CancellationRequestClosedForEscrow`

### 8. **acceptCancellationRequestForErc20EscrowId**

```solidity
function acceptCancellationRequestForErc20EscrowId(uint256 escrowId) public;
```
Allows the counterparty of the individual who raised the cancellation request to accept it and cancel the escrow.

- **Parameters**:
  - `escrowId`: The ID of the escrow with the active cancellation request.

- **Requirements**:
  - Caller must be the counterparty of the individual who raised the request (buyer if seller raised it, and vice versa).
  - The escrow will transition to the `Cancelled` state.

- **Emits**:
  - `CancellationRequestAcceptedForEscrow`

### 9. **raiseIssueForErc20EscrowId**

```solidity
function raiseIssueForErc20EscrowId(uint256 escrowId) public;
```
Allows the buyer or seller to raise an issue for a specific escrow.

- **Parameters**:
  - `escrowId`: The ID of the escrow for which an issue is raised.

- **Requirements**:
  - The escrow must be in the `Funded` or `Delivered` state.
  - No active issue should exist.
  - Caller must be either the buyer or seller.

- **Emits**:
  - `IssueRaisedForEscrow`

### 10. **closeIssueForErc20EscrowId**

```solidity
function closeIssueForErc20EscrowId(uint256 escrowId) public;
```
Allows the arbiter or the individual who raised the issue to close it.

- **Parameters**:
  - `escrowId`: The escrow's ID.

- **Requirements**:
  - An issue must have been raised for the escrow (`raisedIssueForErc20EscrowId[escrowId] == true`).
  - Caller must be the arbiter or the individual who raised the issue.

- **Emits**:
  - `IssueClosedForEscrow`: Signals that the issue has been closed.

### 11. **resolveIssueForErc20EscrowId**

```solidity
function resolveIssueForErc20EscrowId(
    uint256 escrowId,
    uint256 _buyerAmount,
    uint256 _sellerAmount
) public;
```
Resolves an issue for a specific escrow by distributing the ERC20 token amounts among the buyer, seller, and arbiter.

- **Parameters**:
  - `escrowId`: The unique identifier of the escrow.
  - `_buyerAmount`: The amount of tokens allocated to the buyer.
  - `_sellerAmount`: The amount of tokens allocated to the seller.

- **Requirements**:
  - An issue must have been raised for the escrow (`raisedIssueForErc20EscrowId[escrowId] == true`).
  - Caller must be the arbiter.
  - The total allocation (`_buyerAmount + _sellerAmount + _arbiterAmount`) must equal the escrowed token amount.

- **Emits**:
  - `IssueResolvedForEscrow`: Signals that the issue has been resolved with details of the token distribution.

### 11. **setAutomaticWithdrawTime**

```solidity
function setAutomaticWithdrawTime(uint8 _automaticWithdrawTime) public;
```
Sets the automatic withdrawal time for escrows.

- **Parameters**:
  - `_automaticWithdrawTime`: The time after which sellers can withdraw their payments if the buyer doesn't respond.

- **Requirements**:
  - Caller must be the arbiter.

### 12. **setCanCreateNewEscrow**

```solidity
function setCanCreateNewEscrow(bool state) public;
```
Enables or disables the creation of new escrows.

- **Parameters**:
  - `state`: Set to `true` to enable escrow creation, `false` to disable it.

- **Requirements**:
  - Caller must be the arbiter.

### 13. **setCanFundEscrow**

```solidity
function setCanFundEscrow(bool state) public;
```
Enables or disables escrow funding.

- **Parameters**:
  - `state`: Set to `true` to enable funding, `false` to disable it.

- **Requirements**:
  - Caller must be the arbiter.

### 14. **setEscrowProviderFee**

```solidity
function setEscrowProviderFee(uint8 _escrowProviderFee) public;
```
Sets the escrow provider fee percentage.

- **Parameters**:
  - `_escrowProviderFee`: Fee percentage (out of 100).

- **Requirements**:
  - Caller must be the arbiter.
  - `_escrowProviderFee` must not exceed 100%.

### 15. **setNewArbiter**

```solidity
function setNewArbiter(address newArbiter) public;
```
Sets the new arbiter for the contract.

- **Parameters**:
  - `newArbiter`: New arbiter's wallet address.

- **Requirements**:
  - Caller must be the current arbiter.
  - `newArbiter` must not be the zero address.

### 16. **viewMyEscrowsAsBuyer**

```solidity
    function viewMyEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory escrowIds);
```
Returns a list of escrow IDs associated with the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of escrow IDs.

### 17. **viewMyFundedEscrowsAsBuyer**

```solidity
    function viewMyFundedEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory fundedEscrowIds);
```
Returns a list of funded escrow IDs associated with the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of funded escrow IDs.

### 18. **viewMyActiveCancellationRequestsAsBuyer**

```solidity
    function viewMyActiveCancellationRequestsAsBuyer(address myAddress) public view returns (uint256[] memory activeRequestsRaisedByBuyerForEscrowIds, uint256[] memory activeRequestsRaisedTowardsBuyerForEscrowIds);
```
Returns lists of active cancellation requests raised by or towards the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of escrow IDs for requests raised by the buyer.
  - `uint256[]`: Array of escrow IDs for requests raised towards the buyer.

### 19. **viewMyCancelledEscrowsAsBuyer**

```solidity
    function viewMyCancelledEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory cancelledEscrowIds);
```
Returns a list of cancelled escrow IDs associated with the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of cancelled escrow IDs.

### 20. **viewMyActiveIssuesAsBuyer**

```solidity
    function viewMyActiveIssuesAsBuyer(address myAddress) public view returns (uint256[] memory activeIssuesRaisedByBuyerForEscrowIds, uint256[] memory activeIssuesRaisedTowardsBuyerForEscrowIds);
```
Returns lists of active issues raised by or towards the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of escrow IDs for issues raised by the buyer.
  - `uint256[]`: Array of escrow IDs for issues raised towards the buyer.

### 21. **viewMyResolvedEscrowsAsBuyer**

```solidity
    function viewMyResolvedEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory resolvedEscrowIds);
```
Returns a list of resolved escrow IDs associated with the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of resolved escrow IDs.

### 22. **viewMyDeliveredEscrowsAsBuyer**

```solidity
    function viewMyDeliveredEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory deliveredEscrowIds);
```
Returns a list of delivered escrow IDs associated with the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of delivered escrow IDs.

### 23. **viewMyInRevisionEscrowsAsBuyer**

```solidity
    function viewMyInRevisionEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory inrevisionEscrowIds);
```
Returns a list of escrows currently in revision associated with the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of escrow IDs in revision.

### 24. **viewMyCompletedEscrowsAsBuyer**

```solidity
    function viewMyCompletedEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory completedEscrowIds);
```
Returns a list of completed escrow IDs associated with the given buyer address.

- **Parameters**:
  - `myAddress`: The address of the buyer.

- **Returns**:
  - `uint256[]`: Array of completed escrow IDs.

### 25. **viewMyEscrowsAsSeller**

```solidity
    function viewMyEscrowsAsSeller(address myAddress) public view returns (uint256[] memory escrowIds);
```
Returns a list of escrow IDs associated with the given seller address.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: Array of escrow IDs.

### 26. **viewMyFundedEscrowsAsSeller**

```solidity
    function viewMyFundedEscrowsAsSeller(address myAddress) public view returns (uint256[] memory fundedEscrowIds);
```
Returns a list of funded escrow IDs for the given seller address.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: Array of funded escrow IDs.

### 27. **viewMyActiveCancellationRequestsAsSeller**

```solidity
    function viewMyActiveCancellationRequestsAsSeller(address myAddress) public view returns (uint256[] memory activeRequestsRaisedBySellerForEscrowIds, uint256[] memory activeRequestsRaisedTowardsSellerForEscrowIds);
```
Returns lists of active cancellation requests raised by or towards the seller for the given address.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: Array of active cancellation requests raised by the seller.
  - `uint256[]`: Array of active cancellation requests raised towards the seller.

### 28. **viewMyCancelledEscrowsAsSeller**

```solidity
    function viewMyCancelledEscrowsAsSeller(address myAddress) public view returns (uint256[] memory cancelledEscrowIds);
```
Returns a list of cancelled escrow IDs for the given seller address.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: Array of cancelled escrow IDs.

### 29. **viewMyActiveIssuesAsSeller**

```solidity
    function viewMyActiveIssuesAsSeller(address myAddress) public view returns (uint256[] memory activeIssuesRaisedBySellerForEscrowIds, uint256[] memory activeIssuesRaisedTowardsSellerForEscrowIds);
```
Returns lists of active issues raised by or towards the seller for the given address.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: Array of active issues raised by the seller.
  - `uint256[]`: Array of active issues raised towards the seller.

### 30. **viewMyResolvedEscrowsAsSeller**

```solidity
    function viewMyResolvedEscrowsAsSeller(address myAddress) public view returns (uint256[] memory resolvedEscrowIds);
```
Returns a list of resolved escrow IDs for the given seller address.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: Array of resolved escrow IDs.

### 31. **viewMyDeliveredEscrowsAsSeller**

```solidity
    function viewMyDeliveredEscrowsAsSeller(address myAddress) public view returns (uint256[] memory deliveredEscrowIds);
```
Returns a list of delivered escrow IDs for the given seller address.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: Array of delivered escrow IDs.

### 32. **viewMyInRevisionEscrowsAsSeller**

```solidity
    function viewMyInRevisionEscrowsAsSeller(address myAddress) public view returns (uint256[] memory inrevisionEscrowIds);
```
Returns a list of in-revision escrow IDs for the given seller address.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: Array of in-revision escrow IDs.

### 33. **viewMyCompletedEscrowsAsSeller**

```solidity
    function viewMyCompletedEscrowsAsSeller(address myAddress) public view returns (uint256[] memory completedEscrowIds);
```
Returns a list of completed escrow IDs for the given seller address.

- **Parameters**:
  - `myAddress`: The address of the seller.

- **Returns**:
  - `uint256[]`: Array of completed escrow IDs.

### 34. **viewActiveIssues**

```solidity
    function viewActiveIssues() public view returns (uint256[] memory activeIssuesEscrowIds);
```
Returns a list of escrow IDs with active issues.

- **Requirements**:
  - At least one ERC-20 escrow must have been created.

- **Returns**:
  - `uint256[]`: Array of escrow IDs with active issues.

### 35. **viewResolvedEscrowIdInfo**

```solidity
    function viewResolvedEscrowIdInfo(uint256 escrowId) public view returns (ResolvedEscrowInfo memory resolvedEscrowInfo);
```
Returns the information of a resolved escrow.

- **Parameters**:
  - `escrowId`: The ID of the escrow to view.

- **Requirements**:
  - The escrow must be in a `Resolved` state.

- **Returns**:
  - `ResolvedEscrowInfo`: Struct containing details of the resolved escrow.
