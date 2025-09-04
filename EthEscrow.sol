// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract EthEscrow {

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
    mapping(uint256 => EthEscrow) public ethEscrowId;

    mapping(uint256 => ResolvedEscrowInfo) private resolvedEscrowIdInfo;
    mapping(address => uint256[]) private myEscrowsAsBuyer;
    mapping(address => uint256[]) private myEscrowsAsSeller;

    /// @notice Mapping which shows whether issue is raised for escrow id.
    mapping(uint256 => bool) public raisedIssueForEthEscrowId;

    /// @notice Mapping which shows the address which raised issue for escrow id.
    mapping(uint256 => address) public raisedIssueBy;

    /// @notice Mapping which shows whether cancellation request is raised for escrow id.
    mapping(uint256 => bool) public raisedCancellationRequestForEthEscrowId;

    /// @notice Mapping which shows the address which raised cancellation request for escrow id.
    mapping(uint256 => address) public raisedCancellationRequestBy;

    struct EthEscrow {
        address buyer;
        address seller;
        EscrowState escrowState; 
        uint256 ethAmount;
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
    uint256 public totalEthEscrowsCreated;

    // EVENTS //

    event EscrowCreated (
        uint256 escrowId, 
        address buyer, 
        address seller, 
        uint256 ethAmount, 
        uint256 revisionsOffered, 
        uint8 escrowProviderFeeForEscrow, 
        uint8 automaticWithdrawTimeForEscrow
    );
    
    event EscrowFunded(uint256 escrowId, uint256 ethAmount);
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

    // CREATE ETH ESCROW //

    /**
     * @notice Function creates new ETH escrow id.
     *         Caller would be set as the seller.
     * 
     * @param _buyer            The address of the buyer.
     * @param _ethAmount        The ETH amount for the escrow id.
     * @param _revisionsOffered The amount of revisions offered for escrow id.
     */
    function createNewEthEscrow (
        address _buyer,
        uint256 _ethAmount,
        uint256 _revisionsOffered) public {
        require(canCreateNewEscrow == true, "Can't create new escrow");
        require(_buyer != address(0), "Buyer must not be zero address");
        require(msg.sender != _buyer, "Seller and buyer should not be same");
        require(_ethAmount > 0, "ETH amount must be greater than zero");
        ethEscrowId[totalEthEscrowsCreated + 1].buyer = _buyer;
        myEscrowsAsBuyer[_buyer].push(totalEthEscrowsCreated + 1);
        ethEscrowId[totalEthEscrowsCreated + 1].seller = msg.sender;
        myEscrowsAsSeller[msg.sender].push(totalEthEscrowsCreated + 1);
        ethEscrowId[totalEthEscrowsCreated + 1].ethAmount = _ethAmount;
        ethEscrowId[totalEthEscrowsCreated + 1].revisionsOffered = _revisionsOffered;
        ethEscrowId[totalEthEscrowsCreated + 1].escrowProviderFeeForEscrow = escrowProviderFee;
        ethEscrowId[totalEthEscrowsCreated + 1].automaticWithdrawTimeForEscrow = automaticWithdrawTime;
        ethEscrowId[totalEthEscrowsCreated + 1].escrowState = EscrowState.Created;
        emit EscrowCreated (
            totalEthEscrowsCreated + 1, 
            _buyer, 
            msg.sender, 
            _ethAmount, 
            _revisionsOffered, 
            ethEscrowId[totalEthEscrowsCreated + 1].escrowProviderFeeForEscrow, 
            ethEscrowId[totalEthEscrowsCreated + 1].automaticWithdrawTimeForEscrow
        );
        totalEthEscrowsCreated++;
    }

    // FUND ETH ESCROW //

    /**
     * @notice Function funds the escrow id.
     *         Caller has to be the buyer of the escrow id.
     *
     * @param escrowId The escrow's id.
     */
    function fundEthEscrow(uint256 escrowId) public payable {
        require(canFundEscrow == true, "Escrow funding stopped");
        require(ethEscrowId[escrowId].escrowState == EscrowState.Created, "Escrow id does not exist");
        require(msg.sender == ethEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
        require(msg.value == ethEscrowId[escrowId].ethAmount, "Improper ETH Amount");
        ethEscrowId[escrowId].escrowState = EscrowState.Funded;
        emit EscrowFunded(escrowId, msg.value);
    }

    // MARK DELIVERED FOR ETH ESCROW //

    /**
     * @notice Function marks delivered for escrow id.
     *         Caller has to be the seller of the escrow id.
     *
     * @param escrowId The escrow's id.
     */
    function markDeliveredForEthEscrow(uint256 escrowId) public {
        require(raisedCancellationRequestForEthEscrowId[escrowId] == false, "Cancellation request active");
        require(raisedIssueForEthEscrowId[escrowId] == false, "Issue raised");
        require (
            ethEscrowId[escrowId].escrowState == EscrowState.Funded ||
            ethEscrowId[escrowId].escrowState == EscrowState.InRevision,
            "Escrow id not funded yet"
        );
        require(ethEscrowId[escrowId].totalDeliveries + 1 <= ethEscrowId[escrowId].revisionsOffered + 1, "Can't deliver again");
        require(msg.sender == ethEscrowId[escrowId].seller, "You are not the seller for this escrow id");
        ethEscrowId[escrowId].escrowState = EscrowState.Delivered;
        ethEscrowId[escrowId].deliverdAtTime = block.timestamp;
        ethEscrowId[escrowId].totalDeliveries++;
        emit DeliveredForEscrow(escrowId, block.timestamp, ethEscrowId[escrowId].totalDeliveries);
    }

    // REQUEST REVISION FOR ETH ESCROW //

    /**
     * @notice Function allows to request revision for escrow id.
     *         Caller must be the buyer for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function requestRevisionForEthEscrow(uint256 escrowId) public {
        require(msg.sender == ethEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
        require(ethEscrowId[escrowId].escrowState == EscrowState.Delivered, "Not delivered yet for escrow id");
        require(ethEscrowId[escrowId].revisionsRequested + 1 <= ethEscrowId[escrowId].revisionsOffered, "Can't request more revision for escrow id");
        ethEscrowId[escrowId].escrowState = EscrowState.InRevision;
        ethEscrowId[escrowId].revisionsRequested++;
        emit RevisionRequestedForEscrow(escrowId, ethEscrowId[escrowId].revisionsRequested);
    }

    // MARK COMPLETED FOR ETH ESCROW //

    /**
     * @notice Function allows to mark completed for escrow id.
     *         Caller must be the buyer for escrow id.
     *         Caller can also be the seller for the escrow id if the automatic withdraw time has elapsed for the escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function markCompletedForEthEscrow(uint256 escrowId) public {
        require(raisedIssueForEthEscrowId[escrowId] == false, "Issue raised");
        uint256 currentTime = block.timestamp;
        if (currentTime - ethEscrowId[escrowId].deliverdAtTime > ethEscrowId[escrowId].automaticWithdrawTimeForEscrow && 
            msg.sender == ethEscrowId[escrowId].seller &&
            ethEscrowId[escrowId].escrowState == EscrowState.Delivered) {
            sendValue(payable(ethEscrowId[escrowId].seller), ethEscrowId[escrowId].ethAmount * (100 - ethEscrowId[escrowId].escrowProviderFeeForEscrow) / 100);
            sendValue(payable(arbiter), ethEscrowId[escrowId].ethAmount * ethEscrowId[escrowId].escrowProviderFeeForEscrow / 100);
            ethEscrowId[escrowId].escrowState = EscrowState.Completed;
            emit EscrowCompleted(escrowId);
        } else {
            require(ethEscrowId[escrowId].escrowState == EscrowState.Delivered, "Not delivered yet for escrow id");
            require(msg.sender == ethEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
            sendValue(payable(ethEscrowId[escrowId].seller), ethEscrowId[escrowId].ethAmount * (100 - ethEscrowId[escrowId].escrowProviderFeeForEscrow) / 100);
            sendValue(payable(arbiter), ethEscrowId[escrowId].ethAmount * ethEscrowId[escrowId].escrowProviderFeeForEscrow / 100);
            ethEscrowId[escrowId].escrowState = EscrowState.Completed;
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
    function raiseCancellationRequestForEthEscrow(uint256 escrowId) public {
        require(ethEscrowId[escrowId].escrowState == EscrowState.Funded, "Escrow not funded");
        require(raisedCancellationRequestForEthEscrowId[escrowId] == false, "Cancellation request active");
        require(msg.sender == ethEscrowId[escrowId].buyer || msg.sender == ethEscrowId[escrowId].seller, "Caller not buyer or seller");
        raisedCancellationRequestForEthEscrowId[escrowId] = true;
        raisedCancellationRequestBy[escrowId] = msg.sender;
        emit CancellationRequestRaisedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to close raised cancellation request for escrow id.
     *         Caller must be the one who raised cancellation request for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function closeCancellationRequestForEthEscrowId(uint256 escrowId) public {
        require(raisedCancellationRequestForEthEscrowId[escrowId] == true, "Cancellation request not raised");
        require(msg.sender == raisedCancellationRequestBy[escrowId], "Caller must be the one who raised cancellation request");
        raisedCancellationRequestForEthEscrowId[escrowId] = false;
        emit CancellationRequestClosedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to accept raised cancellation request for escrow id.
     *         If buyer has raised the cancellation request then the caller must be seller the for the escrow id.
     *         Likewise if seller has raised the cancellation request then the caller must be buyer the for the escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function acceptCancellationRequestForEthEscrowId(uint256 escrowId) public {
        if (raisedCancellationRequestBy[escrowId] == ethEscrowId[escrowId].buyer) {
            require(msg.sender == ethEscrowId[escrowId].seller, "Caller not seller");
            ethEscrowId[escrowId].escrowState = EscrowState.Cancelled;
            raisedCancellationRequestForEthEscrowId[escrowId] = false;
            sendValue(payable(ethEscrowId[escrowId].buyer), ethEscrowId[escrowId].ethAmount);
            emit CancellationRequestAcceptedForEscrow(escrowId);
        } else {
            require(msg.sender == ethEscrowId[escrowId].buyer, "Caller not buyer");
            ethEscrowId[escrowId].escrowState = EscrowState.Cancelled;
            raisedCancellationRequestForEthEscrowId[escrowId] = false;
            sendValue(payable(ethEscrowId[escrowId].buyer), ethEscrowId[escrowId].ethAmount);
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
    function raiseIssueForEthEscrowId(uint256 escrowId) public {
        require ( 
           ethEscrowId[escrowId].escrowState == EscrowState.Funded ||
           ethEscrowId[escrowId].escrowState == EscrowState.Delivered,
           "Escrow not funded nor delivered"
        );
        require(raisedIssueForEthEscrowId[escrowId] == false, "Issue raised");
        require(msg.sender == ethEscrowId[escrowId].buyer || msg.sender == ethEscrowId[escrowId].seller, "Caller not buyer or seller");
        raisedIssueForEthEscrowId[escrowId] = true;
        raisedIssueBy[escrowId] = msg.sender;
        emit IssueRaisedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to close raised issue for escrow id.
     *         Caller must be the one who raised cancellation request for escrow id.
     * 
     * @param escrowId The escrow's id.
     */
    function closeIssueForEthEscrowId(uint256 escrowId) public {
        require(raisedIssueForEthEscrowId[escrowId] == true, "Issue not raised");
        require(msg.sender == arbiter || msg.sender == raisedIssueBy[escrowId], "Caller not arbiter or the one who raised issue");
        raisedIssueForEthEscrowId[escrowId] = false;
        emit IssueClosedForEscrow(escrowId);
    }

    /**
     * @notice Function allows to resolve the issue for escrow id.
     *         Caller must be the arbiter.
     * 
     * @param escrowId      The escrow's id.
     * @param _buyerAmount  The ETH amount the buyer will receive.
     * @param _sellerAmount The ETH amount the seller will receive.
     */
    function resolveIssueForEthEscrowId(uint256 escrowId, uint256 _buyerAmount, uint256 _sellerAmount) public {
        require(raisedIssueForEthEscrowId[escrowId] == true, "Issue not raised");
        require(msg.sender == arbiter, "Caller not arbiter");
        uint256 _arbiterAmount = ethEscrowId[escrowId].ethAmount * ethEscrowId[escrowId].escrowProviderFeeForEscrow / 100;
        require(_buyerAmount + _sellerAmount + _arbiterAmount == ethEscrowId[escrowId].ethAmount, "Total amount not equal to ETH amount");
        sendValue(payable(ethEscrowId[escrowId].buyer), _buyerAmount);
        sendValue(payable(ethEscrowId[escrowId].seller), _sellerAmount);
        sendValue(payable(arbiter), _arbiterAmount);
        ethEscrowId[escrowId].escrowState == EscrowState.Resolved;
        raisedIssueForEthEscrowId[escrowId] = false;
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Funded) {
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
            if (raisedCancellationRequestForEthEscrowId[escrowIds[i]] == true && myAddress == raisedCancellationRequestBy[escrowIds[i]]) {
               activeRequestsRaisedByBuyerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeRequestsRaisedByBuyerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedCancellationRequestForEthEscrowId[escrowIds[i]] == true && ethEscrowId[escrowIds[i]].seller == raisedCancellationRequestBy[i]) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Cancelled) {
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
            if (raisedIssueForEthEscrowId[escrowIds[i]] == true && myAddress == raisedIssueBy[escrowIds[i]]) {
               activeIssuesRaisedByBuyerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeIssuesRaisedByBuyerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedIssueForEthEscrowId[escrowIds[i]] == true && ethEscrowId[escrowIds[i]].seller == raisedIssueBy[i]) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Resolved) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Delivered) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.InRevision) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Completed) {
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

    /**
     * @notice Function views your current funded escrows as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyFundedEscrowsAsSeller(address myAddress) public view returns(uint256[] memory fundedEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        fundedEscrowIds = new uint256[](escrowIds.length);
        uint256 counter;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Funded) {
               fundedEscrowIds[counter] = escrowIds[i];
               ++counter;
            }
        }
        assembly{mstore(fundedEscrowIds, counter)}
        return fundedEscrowIds;
    }

    /**
     * @notice Function views active cancellation requests raised by you and raised towards you as a seller.
     * 
     * @param myAddress Your address.
     */
    function viewMyActiveCancellationRequestsAsSeller(address myAddress) public view returns (uint256[] memory activeRequestsRaisedBySellerForEscrowIds, uint256[] memory activeRequestsRaisedTowardsSellerForEscrowIds) {
        uint256[] memory escrowIds = myEscrowsAsSeller[myAddress];
        activeRequestsRaisedBySellerForEscrowIds = new uint256[](escrowIds.length);
        activeRequestsRaisedTowardsSellerForEscrowIds = new uint256[](escrowIds.length);
        uint256 counterA = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedCancellationRequestForEthEscrowId[escrowIds[i]] == true && myAddress == raisedCancellationRequestBy[escrowIds[i]]) {
               activeRequestsRaisedBySellerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeRequestsRaisedBySellerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedCancellationRequestForEthEscrowId[escrowIds[i]] == true && ethEscrowId[escrowIds[i]].buyer == raisedCancellationRequestBy[i]) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Cancelled) {
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
            if (raisedIssueForEthEscrowId[escrowIds[i]] == true && myAddress == raisedIssueBy[escrowIds[i]]) {
               activeIssuesRaisedBySellerForEscrowIds[counterA] = escrowIds[i];
               ++counterA;
            }
        }
        assembly{mstore(activeIssuesRaisedBySellerForEscrowIds, counterA)}
        uint256 counterB = 0;
        for (uint256 i = 0; i < escrowIds.length; ++i) {
            if (raisedIssueForEthEscrowId[escrowIds[i]] == true && ethEscrowId[escrowIds[i]].buyer == raisedIssueBy[i]) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Resolved) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Delivered) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.InRevision) {
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
            if (ethEscrowId[escrowIds[i]].escrowState == EscrowState.Completed) {
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
        require(totalEthEscrowsCreated > 0, "No ETH escrows created");
        activeIssuesEscrowIds = new uint256[](totalEthEscrowsCreated);
        uint256 counter = 0;
        for (uint256 i = 0; i < totalEthEscrowsCreated; ++i) {
            if (raisedIssueForEthEscrowId[i + 1] == true) {
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
        require(ethEscrowId[escrowId].escrowState == EscrowState.Resolved, "Not a resolved escrow");
        resolvedEscrowInfo = resolvedEscrowIdInfo[escrowId];
        return resolvedEscrowInfo;
    }

}