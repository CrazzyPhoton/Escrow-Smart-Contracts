// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: contracts/Erc20Escrow.sol

pragma solidity ^0.8.19;

contract Erc20Escrow {

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
    mapping(uint256 => Erc20Escrow) public erc20EscrowId;

    mapping(uint256 => ResolvedEscrowInfo) private resolvedEscrowIdInfo;
    mapping(address => uint256[]) private myEscrowsAsBuyer;
    mapping(address => uint256[]) private myEscrowsAsSeller;

    /// @notice Mapping which shows whether issue is raised for escrow id.
    mapping(uint256 => bool) public raisedIssueForErc20EscrowId;

    /// @notice Mapping which shows the address which raised issue for escrow id.
    mapping(uint256 => address) public raisedIssueBy;

    /// @notice Mapping which shows whether cancellation request is raised for escrow id.
    mapping(uint256 => bool) public raisedCancellationRequestForErc20EscrowId;

    /// @notice Mapping which shows the address which raised cancellation request for escrow id.
    mapping(uint256 => address) public raisedCancellationRequestBy;

    struct Erc20Escrow {
        address buyer;
        address seller;
        EscrowState escrowState;
        IERC20 erc20Token; 
        uint256 erc20TokenAmount;
        uint256 deliverdAtTime;
        uint256 revisionsOffered;
        uint256 totalDeliveries;
        uint256 revisionsRequested;
        uint8 escrowProviderFeeForEscrow;
        uint8 automaticWithdrawTimeForEscrow;
    }

    struct ResolvedEscrowInfo {
        uint256 buyerAmount;
        uint256 sellerAmount;
        uint256 arbiterAmount;
    }

    /// @notice The escrow provider fee percentage out of 100.
    uint8 public escrowProviderFee;

    /// @notice The automatic withdraw time for escrow.
    uint8 public automaticWithdrawTime;

    /// @notice The total number of escrows created.
    uint256 public totalErc20EscrowsCreated;

    // EVENTS //

    event EscrowCreated (
        uint256 escrowId, 
        address buyer, 
        address seller,
        IERC20 erc20Token, 
        uint256 erc20TokenAmount, 
        uint256 revisionsOffered, 
        uint8 escrowProviderFeeForEscrow,
        uint8 automaticWithdrawTimeForEscrow
    );
    
    event EscrowFunded(uint256 escrowId, IERC20 erc20Token, uint256 erc20TokenAmount);
    event DeliveredForEscrow(uint256 escrowId, uint256 deliverdAtTime, uint256 totalDeliveries);
    event RevisionRequestedForEscrow(uint256 escrowId, uint256 revisionsRequested);
    event EscrowCompleted(uint256 escrowId);
    event CancellationRequestRaisedForEscrow(uint256 escrowId);
    event CancellationRequestClosedForEscrow(uint256 escrowId);
    event CancellationRequestAcceptedForEscrow(uint256 escrowId);
    event IssueRaisedForEscrow(uint256 escrowId);
    event IssueClosedForEscrow(uint256 escrowId);
    event IssueResolvedForEscrow(uint256 escrowId, uint256 buyerAmount, uint256 sellerAmount, uint256 arbiterAmount);


    // CONSTRUCTOR //

    constructor() {
        arbiter = msg.sender;
    }

    // CREATE ERC20 ESCROW //

    /**
     * @notice Function creates new erc20 escrow id.
     *         Caller would be set as the seller.
     * 
     * @param _buyer            The address of the buyer.
     * @param _erc20Token       The erc20 token contract address.
     * @param _erc20TokenAmount The erc20 token amount.
     * @param _revisionsOffered The amount of revisions offered for escrow id.
     */
    function createNewErc20Escrow (
        address _buyer,
        IERC20 _erc20Token,
        uint256 _erc20TokenAmount,
        uint256 _revisionsOffered) public {
        require(canCreateNewEscrow == true, "Can't create new escrow");
        require(_buyer != address(0), "Buyer must not be zero address");
        require(msg.sender != _buyer, "Seller and buyer should not be same");
        require(_erc20TokenAmount > 0, "Erc20 amount must be greater than zero");
        erc20EscrowId[totalErc20EscrowsCreated + 1].buyer = _buyer;
        myEscrowsAsBuyer[_buyer].push(totalErc20EscrowsCreated + 1);
        erc20EscrowId[totalErc20EscrowsCreated + 1].seller = msg.sender;
        myEscrowsAsSeller[msg.sender].push(totalErc20EscrowsCreated + 1);
        erc20EscrowId[totalErc20EscrowsCreated + 1].erc20Token = _erc20Token;
        erc20EscrowId[totalErc20EscrowsCreated + 1].erc20TokenAmount = _erc20TokenAmount;
        erc20EscrowId[totalErc20EscrowsCreated + 1].revisionsOffered = _revisionsOffered;
        erc20EscrowId[totalErc20EscrowsCreated + 1].escrowProviderFeeForEscrow = escrowProviderFee;
        erc20EscrowId[totalErc20EscrowsCreated + 1].automaticWithdrawTimeForEscrow = automaticWithdrawTime;
        erc20EscrowId[totalErc20EscrowsCreated + 1].escrowState = EscrowState.Created;
        emit EscrowCreated (
            totalErc20EscrowsCreated + 1, 
            _buyer, 
            msg.sender,
            _erc20Token, 
            _erc20TokenAmount, 
            _revisionsOffered, 
            erc20EscrowId[totalErc20EscrowsCreated + 1].escrowProviderFeeForEscrow,  
            erc20EscrowId[totalErc20EscrowsCreated + 1].automaticWithdrawTimeForEscrow
        );
        totalErc20EscrowsCreated++;
    }

    // FUND ERC20 ESCROW //

    /**
     * @notice Function funds the escrow id.
     *         Caller has to be the buyer of the escrow id.
     *
     * @param escrowId The escrow's id.
     */
    function fundErc20Escrow(uint256 escrowId) public {
        require(canFundEscrow == true, "Escrow funding stopped");
        require(erc20EscrowId[escrowId].escrowState == EscrowState.Created, "Escrow id does not exist");
        require(msg.sender == erc20EscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
        erc20EscrowId[escrowId].erc20Token.transferFrom(erc20EscrowId[escrowId].buyer, address(this), erc20EscrowId[escrowId].erc20TokenAmount);
        erc20EscrowId[escrowId].escrowState = EscrowState.Funded;
        emit EscrowFunded(escrowId, erc20EscrowId[escrowId].erc20Token, erc20EscrowId[escrowId].erc20TokenAmount);
    }

    // MARK DELIVERED FOR ERC20 ESCROW //

    /**
     * @notice Function marks delivered for escrow id.
     *         Caller has to be the seller of the escrow id.
     *
     * @param escrowId The escrow's id.
     */
    function markDeliveredForErc20Escrow(uint256 escrowId) public {
        require(raisedCancellationRequestForErc20EscrowId[escrowId] == false, "Cancellation request active");
        require(raisedIssueForErc20EscrowId[escrowId] == false, "Issue raised");
        require (
            erc20EscrowId[escrowId].escrowState == EscrowState.Funded ||
            erc20EscrowId[escrowId].escrowState == EscrowState.InRevision,
            "Escrow id not funded yet"
        );
        require(erc20EscrowId[escrowId].totalDeliveries + 1 <= erc20EscrowId[escrowId].revisionsOffered + 1, "Can't deliver again");
        require(msg.sender == erc20EscrowId[escrowId].seller, "You are not the seller for this escrow id");
        erc20EscrowId[escrowId].escrowState = EscrowState.Delivered;
        erc20EscrowId[escrowId].deliverdAtTime = block.timestamp;
        erc20EscrowId[escrowId].totalDeliveries++;
        emit DeliveredForEscrow(escrowId, block.timestamp, erc20EscrowId[escrowId].totalDeliveries);
    }

    // REQUEST REVISION FOR ERC20 ESCROW //

    /**
     * @notice Function allows to request revision for escrow id.
     *         Caller must be the buyer for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function requestRevisionForErc20Escrow(uint256 escrowId) public {
        require(msg.sender == erc20EscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
        require(erc20EscrowId[escrowId].escrowState == EscrowState.Delivered, "Not delivered yet for escrow id");
        require(erc20EscrowId[escrowId].revisionsRequested + 1 <= erc20EscrowId[escrowId].revisionsOffered, "Can't request more revision for escrow id");
        erc20EscrowId[escrowId].escrowState = EscrowState.InRevision;
        erc20EscrowId[escrowId].revisionsRequested++;
        emit RevisionRequestedForEscrow(escrowId, erc20EscrowId[escrowId].revisionsRequested);
    }

    // MARK COMPLETED FOR ERC20 ESCROW //

    /**
     * @notice Function allows to mark completed for escrow id.
     *         Caller must be the buyer for escrow id.
     *         Caller can also be the seller for the escrow id if the automatic withdraw time has elapsed for the escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function markCompletedForErc20Escrow(uint256 escrowId) public {
        require(raisedIssueForErc20EscrowId[escrowId] == false, "Issue raised");
        uint256 currentTime = block.timestamp;
        if (currentTime - erc20EscrowId[escrowId].deliverdAtTime > erc20EscrowId[escrowId].automaticWithdrawTimeForEscrow && 
            msg.sender == erc20EscrowId[escrowId].seller &&
            erc20EscrowId[escrowId].escrowState == EscrowState.Delivered) {
            erc20EscrowId[escrowId].erc20Token.transfer(erc20EscrowId[escrowId].seller, erc20EscrowId[escrowId].erc20TokenAmount * (100 - erc20EscrowId[escrowId].escrowProviderFeeForEscrow) / 100);
            erc20EscrowId[escrowId].erc20Token.transfer(arbiter, erc20EscrowId[escrowId].erc20TokenAmount * erc20EscrowId[escrowId].escrowProviderFeeForEscrow / 100);
            erc20EscrowId[escrowId].escrowState = EscrowState.Completed;
            emit EscrowCompleted(escrowId);
        } else {
            require(erc20EscrowId[escrowId].escrowState == EscrowState.Delivered, "Not delivered yet for escrow id");
            require(msg.sender == erc20EscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
            erc20EscrowId[escrowId].erc20Token.transfer(erc20EscrowId[escrowId].seller, erc20EscrowId[escrowId].erc20TokenAmount * (100 - erc20EscrowId[escrowId].escrowProviderFeeForEscrow) / 100);
            erc20EscrowId[escrowId].erc20Token.transfer(arbiter, erc20EscrowId[escrowId].erc20TokenAmount * erc20EscrowId[escrowId].escrowProviderFeeForEscrow / 100);
            erc20EscrowId[escrowId].escrowState = EscrowState.Completed;
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
    function raiseCancellationRequestForErc20Escrow(uint256 escrowId) public {
        require(erc20EscrowId[escrowId].escrowState == EscrowState.Funded, "Escrow not funded");
        require(raisedCancellationRequestForErc20EscrowId[escrowId] == false, "Cancellation request active");
        require(msg.sender == erc20EscrowId[escrowId].buyer || msg.sender == erc20EscrowId[escrowId].seller, "Caller not buyer or seller");
        raisedCancellationRequestForErc20EscrowId[escrowId] = true;
        raisedCancellationRequestBy[escrowId] = msg.sender;
        emit CancellationRequestRaisedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to close raised cancellation request for escrow id.
     *         Caller must be the one who raised cancellation request for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function closeCancellationRequestForErc20EscrowId(uint256 escrowId) public {
        require(raisedCancellationRequestForErc20EscrowId[escrowId] == true, "Cancellation request not raised");
        require(msg.sender == raisedCancellationRequestBy[escrowId], "Caller must be the one who raised cancellation request");
        raisedCancellationRequestForErc20EscrowId[escrowId] = false;
        emit CancellationRequestClosedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to accept raised cancellation request for escrow id.
     *         If buyer has raised the cancellation request then the caller must be seller the for the escrow id.
     *         Likewise if seller has raised the cancellation request then the caller must be buyer the for the escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function acceptCancellationRequestForErc20EscrowId(uint256 escrowId) public {
        if (raisedCancellationRequestBy[escrowId] == erc20EscrowId[escrowId].buyer) {
            require(msg.sender == erc20EscrowId[escrowId].seller, "Caller not seller");
            erc20EscrowId[escrowId].escrowState = EscrowState.Cancelled;
            raisedCancellationRequestForErc20EscrowId[escrowId] = false;
            erc20EscrowId[escrowId].erc20Token.transfer(erc20EscrowId[escrowId].buyer, erc20EscrowId[escrowId].erc20TokenAmount);
            emit CancellationRequestAcceptedForEscrow(escrowId);
        } else {
            require(msg.sender == erc20EscrowId[escrowId].buyer, "Caller not buyer");
            erc20EscrowId[escrowId].escrowState = EscrowState.Cancelled;
            raisedCancellationRequestForErc20EscrowId[escrowId] = false;
            erc20EscrowId[escrowId].erc20Token.transfer(erc20EscrowId[escrowId].buyer, erc20EscrowId[escrowId].erc20TokenAmount);
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
    function raiseIssueForErc20EscrowId(uint256 escrowId) public {
        require ( 
           erc20EscrowId[escrowId].escrowState == EscrowState.Funded ||
           erc20EscrowId[escrowId].escrowState == EscrowState.Delivered,
           "Escrow not funded nor delivered"
        );
        require(raisedIssueForErc20EscrowId[escrowId] == false, "Issue raised");
        require(msg.sender == erc20EscrowId[escrowId].buyer || msg.sender == erc20EscrowId[escrowId].seller, "Caller not buyer or seller");
        raisedIssueForErc20EscrowId[escrowId] = true;
        raisedIssueBy[escrowId] = msg.sender;
        emit IssueRaisedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to close raised issue for escrow id.
     *         Caller must be the one who raised cancellation request for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function closeIssueForErc20EscrowId(uint256 escrowId) public {
        require(raisedIssueForErc20EscrowId[escrowId] == true, "Issue not raised");
        require(msg.sender == arbiter || msg.sender == raisedIssueBy[escrowId], "Caller not arbiter or the one who raised issue");
        raisedIssueForErc20EscrowId[escrowId] = false;
        emit IssueClosedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to resolve the issue for escrow id.
     *         Caller must be the arbiter.
     * 
     * @param escrowId      The escrow's id.
     * @param _buyerAmount  The erc20 token amount the buyer will receive.
     * @param _sellerAmount The erc20 token amount the seller will receive.
     */
    function resolveIssueForErc20EscrowId(uint256 escrowId, uint256 _buyerAmount, uint256 _sellerAmount) public {
        require(raisedIssueForErc20EscrowId[escrowId] == true, "Issue not raised");
        require(msg.sender == arbiter, "Caller not arbiter");
        uint256 _arbiterAmount = erc20EscrowId[escrowId].erc20TokenAmount * erc20EscrowId[escrowId].escrowProviderFeeForEscrow / 100;
        require(_buyerAmount + _sellerAmount + _arbiterAmount == erc20EscrowId[escrowId].erc20TokenAmount, "Total amount not equal to ERC20 amount");
        erc20EscrowId[escrowId].erc20Token.transfer(erc20EscrowId[escrowId].buyer, _buyerAmount);
        erc20EscrowId[escrowId].erc20Token.transfer(erc20EscrowId[escrowId].seller, _sellerAmount);
        erc20EscrowId[escrowId].erc20Token.transfer(arbiter, _arbiterAmount);
        erc20EscrowId[escrowId].escrowState == EscrowState.Resolved;
        raisedIssueForErc20EscrowId[escrowId] = false;
        resolvedEscrowIdInfo[escrowId].buyerAmount = _buyerAmount;
        resolvedEscrowIdInfo[escrowId].sellerAmount = _sellerAmount;
        resolvedEscrowIdInfo[escrowId].arbiterAmount = _arbiterAmount;
        emit IssueResolvedForEscrow(escrowId, _buyerAmount, _sellerAmount, _arbiterAmount);
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
     * @notice Function sets the escrow provider fee percentage taken from the eth amount deposited for the escrow.
     *         Caller must be the current arbiter.
     * 
     * @param _escrowProviderFee The escrow provider fee percentage out of 100.
     */
    function setEscrowProviderFee(uint8 _escrowProviderFee) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        require(_escrowProviderFee <= 100, "Fee must be less than 100%");
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Funded) {
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
            if (raisedCancellationRequestForErc20EscrowId[escrowIds[i]] == true && myAddress == raisedCancellationRequestBy[escrowIds[i]]) {
               activeRequestsRaisedByBuyerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeRequestsRaisedByBuyerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedCancellationRequestForErc20EscrowId[escrowIds[i]] == true && erc20EscrowId[escrowIds[i]].seller == raisedCancellationRequestBy[i]) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Cancelled) {
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
            if (raisedIssueForErc20EscrowId[escrowIds[i]] == true && myAddress == raisedIssueBy[escrowIds[i]]) {
               activeIssuesRaisedByBuyerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeIssuesRaisedByBuyerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedIssueForErc20EscrowId[escrowIds[i]] == true && erc20EscrowId[escrowIds[i]].seller == raisedIssueBy[i]) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Resolved) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Delivered) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.InRevision) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Completed) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Funded) {
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
            if (raisedCancellationRequestForErc20EscrowId[escrowIds[i]] == true && myAddress == raisedCancellationRequestBy[escrowIds[i]]) {
               activeRequestsRaisedBySellerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeRequestsRaisedBySellerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedCancellationRequestForErc20EscrowId[escrowIds[i]] == true && erc20EscrowId[escrowIds[i]].buyer == raisedCancellationRequestBy[i]) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Cancelled) {
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
            if (raisedIssueForErc20EscrowId[escrowIds[i]] == true && myAddress == raisedIssueBy[escrowIds[i]]) {
               activeIssuesRaisedBySellerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeIssuesRaisedBySellerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedIssueForErc20EscrowId[escrowIds[i]] == true && erc20EscrowId[escrowIds[i]].buyer == raisedIssueBy[i]) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Resolved) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Delivered) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.InRevision) {
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
            if (erc20EscrowId[escrowIds[i]].escrowState == EscrowState.Completed) {
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
        require(totalErc20EscrowsCreated > 0, "No erc20 escrows created");
        activeIssuesEscrowIds = new uint256[](totalErc20EscrowsCreated);
        uint256 counter = 0;
        for (uint256 i = 0; i < totalErc20EscrowsCreated; ++i) {
            if (raisedIssueForErc20EscrowId[i + 1] == true) {
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
        require(erc20EscrowId[escrowId].escrowState == EscrowState.Resolved, "Not a resolved escrow");
        resolvedEscrowInfo = resolvedEscrowIdInfo[escrowId];
        return resolvedEscrowInfo;
    }

}