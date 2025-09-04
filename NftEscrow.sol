// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// File: contracts/NftEscrow.sol

pragma solidity ^0.8.19;

contract NftEscrow is ERC721Holder {

    // STATE VARIABLES //

    /// @notice The address of the arbiter.
    address public arbiter;

    /// @notice Boolean for disabling and enabling escrow creation.
    bool public canCreateNewEscrow;

    /// @notice Boolean for disabling and enabling escrow funding.
    bool public canFundEscrow;
    
    enum EscrowState {
        NonExistent,
        Created,
        Funded,
        Cancelled,
        Resolved,
        Delivered,
        InRevision,
        Completed
    }

    /// @notice Mapping for storing and to view escrow information.
    mapping(uint256 => NftEscrow) public nftEscrowId;

    mapping(uint256 => ResolvedEscrowInfo) private resolvedEscrowIdInfo;
    mapping(address => uint256[]) private myEscrowsAsBuyer;
    mapping(address => uint256[]) private myEscrowsAsSeller;

    /// @notice Mapping which shows whether issue is raised for escrow id.
    mapping(uint256 => bool) public raisedIssueForNftEscrowId;

    /// @notice Mapping which shows the address which raised issue for escrow id.
    mapping(uint256 => address) public raisedIssueBy;

    /// @notice Mapping which shows whether cancellation request is raised for escrow id.
    mapping(uint256 => bool) public raisedCancellationRequestForNftEscrowId;

    /// @notice Mapping which shows the address which raised cancellation request for escrow id.
    mapping(uint256 => address) public raisedCancellationRequestBy;

    /// @notice Mapping which shows whether seller has paid the escrow provider fee for escrow id.
    mapping(uint256 => bool) public hasSellerPayedEscrowProviderFee;

    struct NftEscrow {
        address buyer;
        address seller;
        EscrowState escrowState; 
        IERC721[] nftCollectionsAddresses;
        uint256[] nftTokenIds;
        uint256 deliverdAtTime;
        uint256 revisionsOffered;
        uint256 totalDeliveries;
        uint256 revisionsRequested;
        uint256 escrowProviderFeeForEscrow;
        uint8 automaticWithdrawTimeForEscrow;
    }

    struct ResolvedEscrowInfo {
        IERC721[] _collectionAddressesForBuyer; 
        uint256[] _tokenIdsForBuyer; 
        IERC721[] _collectionAddressesForSeller; 
        uint256[] _tokenIdsForSeller;
    }

    /// @notice The escrow provider fee in ETH.
    uint256 public escrowProviderFee;

    /// @notice The automatic withdraw time for escrow.
    uint8 public automaticWithdrawTime;

    /// @notice The total number of escrows created.
    uint256 public totalNftEscrowsCreated;

    // EVENTS //

    event EscrowCreated (
        uint256 escrowId, 
        address buyer, 
        address seller, 
        IERC721[] nftCollectionsAdresses,
        uint256[] nftTokenIds,
        uint256 revisionsOffered, 
        uint256 escrowProviderFeeForEscrow, 
        uint8 automaticWithdrawTimeForEscrow
    );
    
    event EscrowFunded(uint256 escrowId, IERC721[] nftCollectionsAdresses, uint256[] nftTokenIds);
    event DeliveredForEscrow(uint256 escrowId, uint256 deliverdAtTime, uint256 totalDeliveries);
    event RevisionRequestedForEscrow(uint256 escrowId, uint256 revisionsRequested);
    event EscrowCompleted(uint256 escrowId);
    event CancellationRequestRaisedForEscrow(uint256 escrowId);
    event CancellationRequestClosedForEscrow(uint256 escrowId);
    event CancellationRequestAcceptedForEscrow(uint256 escrowId);
    event IssueRaisedForEscrow(uint256 escrowId);
    event IssueClosedForEscrow(uint256 escrowId);
    event IssueResolvedForEscrow(uint256 escrowId, IERC721[] collectionAddressesForBuyer, uint256[] tokenIdsForBuyer, IERC721[] collectionAddressesForSeller, uint256[] tokenIdsForSeller);


    // CONSTRUCTOR //

    constructor() {
        arbiter = msg.sender;
    }

    // CREATE NFT ESCROW //

    /**
     * @notice Function creates new NFT escrow id.
     *         Caller would be set as the seller.
     * 
     * @param _buyer                  The address of the buyer.
     *
     * @param _nftCollectionsAdresses The NFT collections contract addresses array.
     *                                Example array: [Collection1Address,Collection1Address,Collection2Address].
     *
     * @param _nftTokenIds            The corresponding NFT tokenIds of the collections.
     *                                Example array: [Collection1TokenId4,Collection1TokenId30,Collection2TokenId8].
     *
     * @param _revisionsOffered       The amount of revisions offered for escrow id.
     */
    function createNewNftEscrow (
        address _buyer,
        IERC721[] calldata _nftCollectionsAdresses,
        uint256[] calldata _nftTokenIds,
        uint256 _revisionsOffered) public {
        require(canCreateNewEscrow == true, "Can't create new escrow");
        require(_buyer != address(0), "Buyer must not be zero address");
        require(msg.sender != _buyer, "Seller and buyer should not be same");
        require(_nftCollectionsAdresses.length > 0, "ETH amount must be greater than zero");
        require(_nftTokenIds.length > 0, "ETH amount must be greater than zero");
        nftEscrowId[totalNftEscrowsCreated + 1].buyer = _buyer;
        myEscrowsAsBuyer[_buyer].push(totalNftEscrowsCreated + 1);
        nftEscrowId[totalNftEscrowsCreated + 1].seller = msg.sender;
        myEscrowsAsSeller[msg.sender].push(totalNftEscrowsCreated + 1);
        nftEscrowId[totalNftEscrowsCreated + 1].nftCollectionsAddresses = _nftCollectionsAdresses;
        nftEscrowId[totalNftEscrowsCreated + 1].nftTokenIds = _nftTokenIds;
        nftEscrowId[totalNftEscrowsCreated + 1].revisionsOffered = _revisionsOffered;
        nftEscrowId[totalNftEscrowsCreated + 1].escrowProviderFeeForEscrow = escrowProviderFee;
        nftEscrowId[totalNftEscrowsCreated + 1].automaticWithdrawTimeForEscrow = automaticWithdrawTime;
        nftEscrowId[totalNftEscrowsCreated + 1].escrowState = EscrowState.Created;
        emit EscrowCreated (
            totalNftEscrowsCreated + 1, 
            _buyer, 
            msg.sender, 
            _nftCollectionsAdresses,
            _nftTokenIds,
            _revisionsOffered,
            nftEscrowId[totalNftEscrowsCreated + 1].escrowProviderFeeForEscrow,
            nftEscrowId[totalNftEscrowsCreated + 1].automaticWithdrawTimeForEscrow
        );
        totalNftEscrowsCreated++;
    }

    // FUND NFT ESCROW //

    /**
     * @notice Function funds the escrow id.
     *         Caller has to be the buyer of the escrow id.
     *
     * @param escrowId The escrow's id.
     */
    function fundNftEscrow(uint256 escrowId) public {
        require(canFundEscrow == true, "Escrow funding stopped");
        require(nftEscrowId[escrowId].escrowState == EscrowState.Created, "Escrow id does not exist");
        require(msg.sender == nftEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
        for (uint256 i = 0; i < (nftEscrowId[escrowId].nftCollectionsAddresses).length; ++i) {
            nftEscrowId[escrowId].nftCollectionsAddresses[i].safeTransferFrom(nftEscrowId[escrowId].buyer, address(this), nftEscrowId[escrowId].nftTokenIds[i]);
        }
        nftEscrowId[escrowId].escrowState = EscrowState.Funded;
        emit EscrowFunded(escrowId, nftEscrowId[escrowId].nftCollectionsAddresses, nftEscrowId[escrowId].nftTokenIds);
    }

    // PAY ESCROW PROVIDER FEE BY SELLER //

    /**
     * @notice Function to pay the escrow provider fee in ETH.
     *         Caller has to be the seller of the escrow id.
     *
     * @param escrowId The escrow's id.
     */
    function payEscrowProviderFeeBySeller(uint256 escrowId) public payable  {
        require(msg.sender == nftEscrowId[escrowId].seller, "You are not the seller for this escrow id");
        require(hasSellerPayedEscrowProviderFee[escrowId] == false, "Already paid");
        require(nftEscrowId[escrowId].escrowState == EscrowState.Funded, "Escrow id not funded yet");
        require(msg.value == nftEscrowId[escrowId].escrowProviderFeeForEscrow, "Incorrect ETH amount");
        hasSellerPayedEscrowProviderFee[escrowId] = true;
    }

    // MARK DELIVERED FOR NFT ESCROW //

    /**
     * @notice Function marks delivered for escrow id.
     *         Caller has to be the seller of the escrow id.
     *
     * @param escrowId The escrow's id.
     */
    function markDeliveredForNftEscrow(uint256 escrowId) public {
        require(msg.sender == nftEscrowId[escrowId].seller, "You are not the seller for this escrow id");
        require(hasSellerPayedEscrowProviderFee[escrowId] == true, "Escrow provider fee not paid");
        require(raisedCancellationRequestForNftEscrowId[escrowId] == false, "Cancellation request active");
        require(raisedIssueForNftEscrowId[escrowId] == false, "Issue raised");
        require (
            nftEscrowId[escrowId].escrowState == EscrowState.Funded ||
            nftEscrowId[escrowId].escrowState == EscrowState.InRevision,
            "Escrow id not funded yet"
        );
        require(nftEscrowId[escrowId].totalDeliveries + 1 <= nftEscrowId[escrowId].revisionsOffered + 1, "Can't deliver again");
        nftEscrowId[escrowId].escrowState = EscrowState.Delivered;
        nftEscrowId[escrowId].deliverdAtTime = block.timestamp;
        nftEscrowId[escrowId].totalDeliveries++;
        emit DeliveredForEscrow(escrowId, block.timestamp, nftEscrowId[escrowId].totalDeliveries);
    }

    // REQUEST REVISION FOR NFT ESCROW //

    /**
     * @notice Function allows to request revision for escrow id.
     *         Caller must be the buyer for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function requestRevisionForNftEscrow(uint256 escrowId) public {
        require(msg.sender == nftEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
        require(nftEscrowId[escrowId].escrowState == EscrowState.Delivered, "Not delivered yet for escrow id");
        require(nftEscrowId[escrowId].revisionsRequested + 1 <= nftEscrowId[escrowId].revisionsOffered, "Can't request more revision for escrow id");
        nftEscrowId[escrowId].escrowState = EscrowState.InRevision;
        nftEscrowId[escrowId].revisionsRequested++;
        emit RevisionRequestedForEscrow(escrowId, nftEscrowId[escrowId].revisionsRequested);
    }

    // MARK COMPLETED FOR NFT ESCROW //

    /**
     * @notice Function allows to mark completed for escrow id.
     *         Caller must be the buyer for escrow id.
     *         Caller can also be the seller for the escrow id if the automatic withdraw time has elapsed for the escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function markCompletedForNftEscrow(uint256 escrowId) public  {
        require(raisedIssueForNftEscrowId[escrowId] == false, "Issue raised");
        uint256 currentTime = block.timestamp;
        if (msg.sender == nftEscrowId[escrowId].seller &&
            currentTime - nftEscrowId[escrowId].deliverdAtTime > nftEscrowId[escrowId].automaticWithdrawTimeForEscrow &&
            nftEscrowId[escrowId].escrowState == EscrowState.Delivered) {
            for (uint256 i = 0; i < (nftEscrowId[escrowId].nftCollectionsAddresses).length; ++i) {
                nftEscrowId[escrowId].nftCollectionsAddresses[i].safeTransferFrom(address(this), nftEscrowId[escrowId].seller, nftEscrowId[escrowId].nftTokenIds[i]);
            }
            sendValue(payable(arbiter), nftEscrowId[escrowId].escrowProviderFeeForEscrow);
            nftEscrowId[escrowId].escrowState = EscrowState.Completed;
            emit EscrowCompleted(escrowId);
        } else {
            require(nftEscrowId[escrowId].escrowState == EscrowState.Delivered, "Not delivered yet for escrow id");
            require(msg.sender == nftEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
            for (uint256 i = 0; i < (nftEscrowId[escrowId].nftCollectionsAddresses).length; ++i) {
                nftEscrowId[escrowId].nftCollectionsAddresses[i].safeTransferFrom(address(this), nftEscrowId[escrowId].seller, nftEscrowId[escrowId].nftTokenIds[i]);
            }
            sendValue(payable(arbiter), nftEscrowId[escrowId].escrowProviderFeeForEscrow);
            nftEscrowId[escrowId].escrowState = EscrowState.Completed;
            emit EscrowCompleted(escrowId);
        }
    }

    // CANCELLATIONS HANDLING //

    /**
     * @notice Function allows to raise cancellation request for escrow id.
     *         Caller must be the buyer or seller for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function raiseCancellationRequestForNftEscrow(uint256 escrowId) public {
        require(nftEscrowId[escrowId].escrowState == EscrowState.Funded, "Escrow not funded");
        require(raisedCancellationRequestForNftEscrowId[escrowId] == false, "Cancellation request active");
        require(msg.sender == nftEscrowId[escrowId].buyer || msg.sender == nftEscrowId[escrowId].seller, "Caller not buyer or seller");
        if (msg.sender == nftEscrowId[escrowId].seller) {
            require(hasSellerPayedEscrowProviderFee[escrowId] == true, "Escrow provider fee not paid by seller");
        }
        raisedCancellationRequestForNftEscrowId[escrowId] = true;
        raisedCancellationRequestBy[escrowId] = msg.sender;
        emit CancellationRequestRaisedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to close raised cancellation request for escrow id.
     *         Caller must be the one who raised cancellation request for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function closeCancellationRequestForNftEscrowId(uint256 escrowId) public {
        require(raisedCancellationRequestForNftEscrowId[escrowId] == true, "Cancellation request not raised");
        require(msg.sender == raisedCancellationRequestBy[escrowId], "Caller must be the one who raised cancellation request");
        raisedCancellationRequestForNftEscrowId[escrowId] = false;
        emit CancellationRequestClosedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to accept raised cancellation request for escrow id.
     *         If buyer has raised the cancellation request then the caller must be seller the for the escrow id.
     *         Likewise if seller has raised the cancellation request then the caller must be buyer the for the escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function acceptCancellationRequestForNftEscrowId(uint256 escrowId) public {
        if (raisedCancellationRequestBy[escrowId] == nftEscrowId[escrowId].buyer) {
            require(msg.sender == nftEscrowId[escrowId].seller, "Caller not seller");
            nftEscrowId[escrowId].escrowState = EscrowState.Cancelled;
            raisedCancellationRequestForNftEscrowId[escrowId] = false;
            for (uint256 i = 0; i < (nftEscrowId[escrowId].nftCollectionsAddresses).length; ++i) {
                nftEscrowId[escrowId].nftCollectionsAddresses[i].safeTransferFrom(address(this), nftEscrowId[escrowId].buyer, nftEscrowId[escrowId].nftTokenIds[i]);
            }
            sendValue(payable(nftEscrowId[escrowId].seller), nftEscrowId[escrowId].escrowProviderFeeForEscrow);
            emit CancellationRequestAcceptedForEscrow(escrowId);
        } else {
            require(msg.sender == nftEscrowId[escrowId].buyer, "Caller not buyer");
            nftEscrowId[escrowId].escrowState = EscrowState.Cancelled;
            raisedCancellationRequestForNftEscrowId[escrowId] = false;
            for (uint256 i = 0; i < (nftEscrowId[escrowId].nftCollectionsAddresses).length; ++i) {
                nftEscrowId[escrowId].nftCollectionsAddresses[i].safeTransferFrom(address(this), nftEscrowId[escrowId].buyer, nftEscrowId[escrowId].nftTokenIds[i]);
            }
            sendValue(payable(nftEscrowId[escrowId].seller), nftEscrowId[escrowId].escrowProviderFeeForEscrow);
            emit CancellationRequestAcceptedForEscrow(escrowId);
        }
    }

    // ISSUE HANDLING //

    /** 
     * @notice Function allows to raise issue for escrow id.
     *         Caller must be the buyer or seller for escrow id.
     *
     * @param escrowId The escrow's id.
     */
    function raiseIssueForNftEscrowId(uint256 escrowId) public {
        require ( 
           nftEscrowId[escrowId].escrowState == EscrowState.Funded ||
           nftEscrowId[escrowId].escrowState == EscrowState.Delivered,
           "Escrow not funded nor delivered"
        );
        require(raisedIssueForNftEscrowId[escrowId] == false, "Issue raised");
        require(msg.sender == nftEscrowId[escrowId].buyer || msg.sender == nftEscrowId[escrowId].seller, "Caller not buyer or seller");
        if (msg.sender == nftEscrowId[escrowId].seller) {
            require(hasSellerPayedEscrowProviderFee[escrowId] == true, "Escrow provider fee not paid by seller");
        }
        raisedIssueForNftEscrowId[escrowId] = true;
        raisedIssueBy[escrowId] = msg.sender;
        emit IssueRaisedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to close raised issue for escrow id.
     *         Caller must be the one who raised cancellation request for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function closeIssueForNftEscrowId(uint256 escrowId) public {
        require(raisedIssueForNftEscrowId[escrowId] == true, "Issue not raised");
        require(msg.sender == arbiter || msg.sender == raisedIssueBy[escrowId], "Caller not arbiter or the one who raised issue");
        raisedIssueForNftEscrowId[escrowId] = false;
        emit IssueClosedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to resolve the issue for escrow id.
     *         Caller must be the arbiter.
     * 
     * @param escrowId                     The escrow's id.
     * @param collectionAddressesForBuyer  The NFT collection addresses for buyer.
     * @param tokenIdsForBuyer             The corresponding NFT tokenIds the buyer will receive from the above mentioned collections.
     * @param collectionAddressesForSeller The NFT collection addresses for seller.
     * @param tokenIdsForSeller            The corresponding NFT tokenIds the seller will receive from the above mentioned collections.
     */
    function resolveIssueForNftEscrowId(uint256 escrowId, IERC721[] calldata collectionAddressesForBuyer, uint256[] calldata tokenIdsForBuyer, IERC721[] calldata collectionAddressesForSeller, uint256[] calldata tokenIdsForSeller) public {
        require(raisedIssueForNftEscrowId[escrowId] == true, "Issue not raised");
        require(msg.sender == arbiter, "Caller not arbiter");
        require(collectionAddressesForBuyer.length == tokenIdsForBuyer.length, "collectionAddressesForBuyer and tokenIdsForBuyer arrays lengths must be equal");
        require(collectionAddressesForSeller.length == tokenIdsForSeller.length, "collectionAddressesForSeller and tokenIdsForSeller arrays lengths must be equal");
        if (tokenIdsForBuyer.length > 0) {
           for (uint256 i = 0; i < collectionAddressesForBuyer.length; ++i) {
               collectionAddressesForBuyer[i].safeTransferFrom(address(this), nftEscrowId[escrowId].buyer, tokenIdsForBuyer[i]);
            }
        }
        if (tokenIdsForSeller.length > 0) {
           for (uint256 i = 0; i < collectionAddressesForSeller.length; ++i) {
               collectionAddressesForSeller[i].safeTransferFrom(address(this), nftEscrowId[escrowId].seller, tokenIdsForSeller[i]);
            }
        }
        sendValue(payable(arbiter), nftEscrowId[escrowId].escrowProviderFeeForEscrow);
        resolvedEscrowIdInfo[escrowId]._collectionAddressesForBuyer = collectionAddressesForBuyer;
        resolvedEscrowIdInfo[escrowId]._tokenIdsForBuyer = tokenIdsForBuyer;
        resolvedEscrowIdInfo[escrowId]._collectionAddressesForSeller = collectionAddressesForSeller;
        resolvedEscrowIdInfo[escrowId]._tokenIdsForSeller = tokenIdsForSeller;
        nftEscrowId[escrowId].escrowState == EscrowState.Resolved;
        raisedIssueForNftEscrowId[escrowId] = false;
        emit IssueResolvedForEscrow(escrowId, collectionAddressesForBuyer, tokenIdsForBuyer, collectionAddressesForSeller, tokenIdsForSeller);
    }

    // CONFIGURATIONS //

    /**
     * @notice Function sets the automatic withdraw time.
     *         Automatic withdraw time is the time after which the seller can withdraw their payment on their own if the buyer doesn't mark the escrow completed or ask for a revision in the automatic withdraw time.
     *         Caller must be the current arbiter.
     *
     * @param _automaticWithdrawTime The automatic withdraw time to be set.
     */
    function setAutomaticWithdrawTime(uint8 _automaticWithdrawTime) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        automaticWithdrawTime = _automaticWithdrawTime;
    }

    /**
     * @notice Function sets whether escrow can be created.
     *         Caller must be the current arbiter.
     * 
     * @param state Set state to true to enable escrow creation.
     *              Set state to false to disable escrow creation.
     */
    function setCanCreateNewEscrow(bool state) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        canCreateNewEscrow = state;
    }

    /**
     * @notice Function sets whether escrow can be funded.
     *         Caller must be the current arbiter.
     * 
     * @param state Set state to true to enable escrow funding.
     *              Set state to false to disable escrow funding.
     */
    function setCanFundEscrow(bool state) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        canFundEscrow = state;
    }

    /**
     * @notice Function sets the escrow provider fee for escrow.
     *         Caller must be the current arbiter.
     * 
     * @param _escrowProviderFee The escrow provider fee in ETH.
     */
    function setEscrowProviderFee(uint256 _escrowProviderFee) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        escrowProviderFee = _escrowProviderFee;
    }

    /**
     * @notice Function sets the new arbiter.
     *         Caller must be the current arbiter.
     * 
     * @param newArbiter New arbiter's wallet address.
     */
    function setNewArbiter(address newArbiter) public {
        require(msg.sender == arbiter, "Caller not current arbiter");
        require(newArbiter != address(0), "New arbiter cannot be zero address");
        arbiter = newArbiter;
    }

    // INTERNAL FUNCTION //

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    // BUYER FUNCTIONS //

    /**
     * @notice Function views your current escrows as a buyer.
     * 
     * @param myAddress Your address.
     */
    function viewMyEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory escrowIds) {
        escrowIds = myEscrowsAsBuyer[myAddress];
        return escrowIds;
    }

    /**
     * @notice Function views your current funded escrows as a buyer.
     * 
     * @param myAddress Your address.
     */
    function viewMyFundedEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory fundedEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsBuyer[myAddress];
        fundedEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Funded) {
               fundedEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(fundedEscrowIds, counter)}
        return fundedEscrowIds;
    }

    /**
     * @notice Function views active cancellation requests raised by you and raised towards you as a buyer.
     * 
     * @param myAddress Your address.
     */
    function viewMyActiveCancellationRequestsAsBuyer(address myAddress) public view returns (uint256[] memory activeRequestsRaisedByBuyerForEscrowIds, uint256[] memory activeRequestsRaisedTowardsBuyerForEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsBuyer[myAddress];
        activeRequestsRaisedByBuyerForEscrowIds = new uint256[](escrowIds.length);
        activeRequestsRaisedTowardsBuyerForEscrowIds = new uint256[](escrowIds.length);
        uint256 counterA = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedCancellationRequestForNftEscrowId[escrowIds[i]] == true && myAddress == raisedCancellationRequestBy[escrowIds[i]]) {
               activeRequestsRaisedByBuyerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeRequestsRaisedByBuyerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedCancellationRequestForNftEscrowId[escrowIds[i]] == true && nftEscrowId[escrowIds[i]].seller == raisedCancellationRequestBy[i]) {
               activeRequestsRaisedTowardsBuyerForEscrowIds[counterB] = escrowIds[i];
               ++counterB;
            }
        }
        assembly{mstore(activeRequestsRaisedTowardsBuyerForEscrowIds, counterB)}
        return (activeRequestsRaisedByBuyerForEscrowIds, activeRequestsRaisedTowardsBuyerForEscrowIds);
    }

    /**
     * @notice Function views your cancelled escrows as a buyer.
     * 
     * @param myAddress Your address.
     */
    function viewMyCancelledEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory cancelledEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsBuyer[myAddress];
        cancelledEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Cancelled) {
               cancelledEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(cancelledEscrowIds, counter)}
        return cancelledEscrowIds;
    }

    /**
     * @notice Function views active issues raised by you and raised towards you as a buyer.
     * 
     * @param myAddress Your address.
     */
    function viewMyActiveIssuesAsBuyer(address myAddress) public view returns (uint256[] memory activeIssuesRaisedByBuyerForEscrowIds, uint256[] memory activeIssuesRaisedTowardsBuyerForEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsBuyer[myAddress];
        activeIssuesRaisedByBuyerForEscrowIds = new uint256[](escrowIds.length);
        activeIssuesRaisedTowardsBuyerForEscrowIds = new uint256[](escrowIds.length);
        uint256 counterA = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedIssueForNftEscrowId[escrowIds[i]] == true && myAddress == raisedIssueBy[escrowIds[i]]) {
               activeIssuesRaisedByBuyerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeIssuesRaisedByBuyerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedIssueForNftEscrowId[escrowIds[i]] == true && nftEscrowId[escrowIds[i]].seller == raisedIssueBy[i]) {
               activeIssuesRaisedTowardsBuyerForEscrowIds[counterB] = escrowIds[i];
               ++counterB;
            }
        }
        assembly{mstore(activeIssuesRaisedTowardsBuyerForEscrowIds, counterB)}
        return (activeIssuesRaisedByBuyerForEscrowIds, activeIssuesRaisedTowardsBuyerForEscrowIds);
    }   

    /**
     * @notice Function views your resolved escrows as a buyer.
     * 
     * @param myAddress Your address.
     */
    function viewMyResolvedEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory resolvedEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsBuyer[myAddress];
        resolvedEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Resolved) {
               resolvedEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(resolvedEscrowIds, counter)}
        return resolvedEscrowIds;
    }

    /**
     * @notice Function views your delivered escrows as a buyer.
     * 
     * @param myAddress Your address.
     */
    function viewMyDeliveredEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory deliveredEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsBuyer[myAddress];
        deliveredEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Delivered) {
               deliveredEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(deliveredEscrowIds, counter)}
        return deliveredEscrowIds;
    }

    /**
     * @notice Function views your in revision escrows as a buyer.
     * 
     * @param myAddress Your address.
     */
    function viewMyInRevisionEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory inrevisionEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsBuyer[myAddress];
        inrevisionEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.InRevision) {
               inrevisionEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(inrevisionEscrowIds, counter)}
        return inrevisionEscrowIds;
    }

    /**
     * @notice Function views your completed escrows as a buyer.
     * 
     * @param myAddress Your address.
     */
    function viewMyCompletedEscrowsAsBuyer(address myAddress) public view returns(uint256[] memory completedEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsBuyer[myAddress];
        completedEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Completed) {
               completedEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(completedEscrowIds, counter)}
        return completedEscrowIds;
    }

    // SELLER FUNCTIONS //

    /**
     * @notice Function views your current escrows as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyEscrowsAsSeller(address myAddress) public view returns (uint256[] memory escrowIds) {
        escrowIds = myEscrowsAsSeller[myAddress];
        return escrowIds;
    }

    function viewMyFundedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory fundedEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        fundedEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Funded) {
               fundedEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(fundedEscrowIds, counter)}
        return fundedEscrowIds;
    }

    /**
     * @notice Function views your current funded escrows as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyActiveCancellationRequestsAsSeller(address myAddress) public view returns (uint256[] memory activeRequestsRaisedBySellerForEscrowIds, uint256[] memory activeRequestsRaisedTowardsSellerForEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        activeRequestsRaisedBySellerForEscrowIds = new uint256[](escrowIds.length);
        activeRequestsRaisedTowardsSellerForEscrowIds = new uint256[](escrowIds.length);
        uint256 counterA = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedCancellationRequestForNftEscrowId[escrowIds[i]] == true && myAddress == raisedCancellationRequestBy[escrowIds[i]]) {
               activeRequestsRaisedBySellerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeRequestsRaisedBySellerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedCancellationRequestForNftEscrowId[escrowIds[i]] == true && nftEscrowId[escrowIds[i]].buyer == raisedCancellationRequestBy[i]) {
               activeRequestsRaisedTowardsSellerForEscrowIds[counterB] = escrowIds[i];
               ++counterB;
            }
        }
        assembly{mstore(activeRequestsRaisedTowardsSellerForEscrowIds, counterB)}
        return (activeRequestsRaisedBySellerForEscrowIds, activeRequestsRaisedTowardsSellerForEscrowIds);
    }

    /**
     * @notice Function views your cancelled escrows as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyCancelledEscrowsAsSeller(address myAddress) public view returns(uint256[] memory cancelledEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        cancelledEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Cancelled) {
               cancelledEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(cancelledEscrowIds, counter)}
        return cancelledEscrowIds;
    }

    /**
     * @notice Function views active issues raised by you and raised towards you as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyActiveIssuesAsSeller(address myAddress) public view returns (uint256[] memory activeIssuesRaisedBySellerForEscrowIds, uint256[] memory activeIssuesRaisedTowardsSellerForEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        activeIssuesRaisedBySellerForEscrowIds = new uint256[](escrowIds.length);
        activeIssuesRaisedTowardsSellerForEscrowIds = new uint256[](escrowIds.length);
        uint256 counterA = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedIssueForNftEscrowId[escrowIds[i]] == true && myAddress == raisedIssueBy[escrowIds[i]]) {
               activeIssuesRaisedBySellerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeIssuesRaisedBySellerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedIssueForNftEscrowId[escrowIds[i]] == true && nftEscrowId[escrowIds[i]].buyer == raisedIssueBy[i]) {
               activeIssuesRaisedTowardsSellerForEscrowIds[counterB] = escrowIds[i];
               ++counterB;
            }
        }
        assembly{mstore(activeIssuesRaisedTowardsSellerForEscrowIds, counterB)}
        return (activeIssuesRaisedBySellerForEscrowIds, activeIssuesRaisedTowardsSellerForEscrowIds);
    }

    /**
     * @notice Function views your resolved escrows as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyResolvedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory resolvedEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        resolvedEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Resolved) {
               resolvedEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(resolvedEscrowIds, counter)}
        return resolvedEscrowIds;
    }

    /**
     * @notice Function views your delivered escrows as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyDeliveredEscrowsAsSeller(address myAddress) public view returns(uint256[] memory deliveredEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        deliveredEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Delivered) {
               deliveredEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(deliveredEscrowIds, counter)}
        return deliveredEscrowIds;
    }

    /**
     * @notice Function views your in revision escrows as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyInRevisionEscrowsAsSeller(address myAddress) public view returns(uint256[] memory inrevisionEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        inrevisionEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.InRevision) {
               inrevisionEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(inrevisionEscrowIds, counter)}
        return inrevisionEscrowIds;
    }

    /**
     * @notice Function views your completed escrows as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyCompletedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory completedEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        completedEscrowIds = new uint256[](escrowIds.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (nftEscrowId[escrowIds[i]].escrowState == EscrowState.Completed) {
               completedEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(completedEscrowIds, counter)}
        return completedEscrowIds;
    }

    // ACTIVE ISSUES //

    /**
     * @notice Function views active escrows with issues raised. 
     */
    function viewActiveIssues() public view returns (uint256[] memory activeIssuesEscrowIds) {
        require(totalNftEscrowsCreated > 0, "No NFT escrows created");
        activeIssuesEscrowIds = new uint256[](totalNftEscrowsCreated);
        uint256 counter = 0;
        for (uint256 i = 0; i < totalNftEscrowsCreated; ++i) {
            if (raisedIssueForNftEscrowId[i + 1] == true) {
               activeIssuesEscrowIds[counter] = i + 1;
               ++counter;
            }
        }
        assembly{mstore(activeIssuesEscrowIds, counter)}
        return activeIssuesEscrowIds;
    }

    // RESOLVED ESCROW INFO //

    /**
     * @notice Function views a resolved escrow's info.
     * 
     * @param escrowId The escrow's id.
     */
    function viewResolvedEscrowIdInfo(uint256 escrowId) public view returns (ResolvedEscrowInfo memory resolvedEscrowInfo) {
        require(nftEscrowId[escrowId].escrowState == EscrowState.Resolved, "Not a resolved escrow");
        resolvedEscrowInfo = resolvedEscrowIdInfo[escrowId];
        return resolvedEscrowInfo;
    }


}
