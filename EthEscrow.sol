// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract EthEscrowSmartContract {

    address public arbiter;

    bool public canCreateNewEscrow;
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

    mapping(uint256 => EthEscrow) public ethEscrowId;
    mapping(address => uint256[]) private myEscrowsAsBuyer;
    mapping(address => uint256[]) private myEscrowsAsSeller;
    mapping(uint256 => bool) public raisedIssueForEthEscrowId;
    mapping(uint256 => address) public raisedIssueBy;
    mapping(uint256 => bool) public raisedCancellationRequestForEthEscrowId;
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
        uint8 escrowProviderIssueResolutionFeeForEscrow;
        uint8 automaticWithdrawTimeForEscrow;
    }

    uint8 public escrowProviderFee;
    uint8 public issueResolutionFeeForEscrowProvider;
    uint8 public automaticWithdrawTime;
    uint256 public totalEthEscrowsCreated;

    constructor() {
        arbiter = msg.sender;
    }

    // CREATE ETH ESCROW //

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
        ethEscrowId[totalEthEscrowsCreated + 1].escrowProviderIssueResolutionFeeForEscrow = issueResolutionFeeForEscrowProvider;
        ethEscrowId[totalEthEscrowsCreated + 1].automaticWithdrawTimeForEscrow = automaticWithdrawTime;
        ethEscrowId[totalEthEscrowsCreated + 1].escrowState = EscrowState.Created;
        totalEthEscrowsCreated++;
    }

    // FUND ETH ESCROW //

    function fundEthEscrow(uint256 escrowId) public payable {
        require(canFundEscrow == true, "Escrow funding stopped");
        require(ethEscrowId[escrowId].escrowState == EscrowState.Created, "Escrow id does not exist");
        require(msg.sender == ethEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
        require(msg.value == ethEscrowId[escrowId].ethAmount, "Improper ETH funding");
        ethEscrowId[escrowId].escrowState = EscrowState.Funded;
    }

    // MARK DELIVERED FOR ETH ESCROW //

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
    }

    // REQUEST REVISION FOR ETH ESCROW //

    function requestRevisionForEthEscrow(uint256 escrowId) public {
        require(msg.sender == ethEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
        require(ethEscrowId[escrowId].escrowState == EscrowState.Delivered, "Not delivered yet for escrow id");
        require(ethEscrowId[escrowId].revisionsRequested + 1 <= ethEscrowId[escrowId].revisionsOffered, "Can't request more revision for escrow id");
        ethEscrowId[escrowId].escrowState = EscrowState.InRevision;
        ethEscrowId[escrowId].revisionsRequested++;
    }

    // MARK COMPLETED FOR ETH ESCROW //

    function markCompletedForEthEscrow(uint256 escrowId) public {
        require(raisedIssueForEthEscrowId[escrowId] == false, "Issue raised");
        uint256 currentTime = block.timestamp;
        if (currentTime - ethEscrowId[escrowId].deliverdAtTime > ethEscrowId[escrowId].automaticWithdrawTimeForEscrow && 
            msg.sender == ethEscrowId[escrowId].seller &&
            ethEscrowId[escrowId].escrowState == EscrowState.Delivered) {
            sendValue(payable(ethEscrowId[escrowId].seller), ethEscrowId[escrowId].ethAmount * (100 - ethEscrowId[escrowId].escrowProviderFeeForEscrow) / 100);
            sendValue(payable(arbiter), ethEscrowId[escrowId].ethAmount * ethEscrowId[escrowId].escrowProviderFeeForEscrow / 100);
            ethEscrowId[escrowId].escrowState = EscrowState.Completed;
        } else {
            require(ethEscrowId[escrowId].escrowState == EscrowState.Delivered, "Not delivered yet for escrow id");
            require(msg.sender == ethEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
            sendValue(payable(ethEscrowId[escrowId].seller), ethEscrowId[escrowId].ethAmount * (100 - ethEscrowId[escrowId].escrowProviderFeeForEscrow) / 100);
            sendValue(payable(arbiter), ethEscrowId[escrowId].ethAmount * ethEscrowId[escrowId].escrowProviderFeeForEscrow / 100);
            ethEscrowId[escrowId].escrowState = EscrowState.Completed;
        }
    }

    // CANCELLATIONS HANDLING //

    function raiseCancellationRequestForEthEscrow(uint256 escrowId) public {
        require(ethEscrowId[escrowId].escrowState == EscrowState.Funded, "Escrow not funded");
        require(raisedCancellationRequestForEthEscrowId[escrowId] == false, "Cancellation request active");
        require(msg.sender == ethEscrowId[escrowId].buyer || msg.sender == ethEscrowId[escrowId].seller, "Caller not buyer or seller");
        raisedCancellationRequestForEthEscrowId[escrowId] = true;
        raisedCancellationRequestBy[escrowId] = msg.sender;
    }

    function closeCancellationRequestForEthEscrowId(uint256 escrowId) public {
        require(raisedCancellationRequestForEthEscrowId[escrowId] == true, "Cancellation request not raised");
        require(msg.sender == raisedCancellationRequestBy[escrowId], "Caller must be the one who raised cancellation request");
        raisedCancellationRequestForEthEscrowId[escrowId] = false;
    }

    function acceptCancellationRequest(uint256 escrowId) public {
        if (raisedCancellationRequestBy[escrowId] == ethEscrowId[escrowId].buyer) {
            require(msg.sender == ethEscrowId[escrowId].seller, "Caller not seller");
            ethEscrowId[escrowId].escrowState = EscrowState.Cancelled;
            raisedCancellationRequestForEthEscrowId[escrowId] = false;
            sendValue(payable(ethEscrowId[escrowId].buyer), ethEscrowId[escrowId].ethAmount);
        } else {
            require(msg.sender == ethEscrowId[escrowId].buyer, "Caller not buyer");
            ethEscrowId[escrowId].escrowState = EscrowState.Cancelled;
            raisedCancellationRequestForEthEscrowId[escrowId] = false;
            sendValue(payable(ethEscrowId[escrowId].buyer), ethEscrowId[escrowId].ethAmount);
        }
    }

    // ISSUE HANDLING //

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
    }

    function closeIssueForEthEscrowId(uint256 escrowId) public {
        require(raisedIssueForEthEscrowId[escrowId] == true, "Issue not raised");
        require(msg.sender == arbiter || msg.sender == raisedIssueBy[escrowId], "Caller not arbiter or the one who raised issue");
        raisedIssueForEthEscrowId[escrowId] = false;
    }

    function resolveIssueForEthEscrow(uint256 escrowId, uint256 buyerAmount, uint256 sellerAmount) public {
        require(raisedIssueForEthEscrowId[escrowId] == true, "Issue not raised");
        require(msg.sender == arbiter, "Caller not arbiter");
        uint256 arbiterAmount = ethEscrowId[escrowId].ethAmount * ethEscrowId[escrowId].escrowProviderIssueResolutionFeeForEscrow / 100;
        require(buyerAmount + sellerAmount + arbiterAmount == ethEscrowId[escrowId].ethAmount, "Total amount not equal to ETH amount");
        sendValue(payable(ethEscrowId[escrowId].buyer), buyerAmount);
        sendValue(payable(ethEscrowId[escrowId].seller), sellerAmount);
        sendValue(payable(arbiter), arbiterAmount);
        ethEscrowId[escrowId].escrowState == EscrowState.Resolved;
        raisedIssueForEthEscrowId[escrowId] = false;
    }

    // CONFIGURATIONS //

    function setAutomaticWithdrawTime(uint8 _automaticWithdrawTime) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        automaticWithdrawTime = _automaticWithdrawTime;
    }

    function setCanCreateNewEscrow(bool state) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        canCreateNewEscrow = state;
    }

    function setCanFundEscrow(bool state) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        canFundEscrow = state;
    }

    function setEscrowProviderFee(uint8 _escrowProviderFee) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        require(_escrowProviderFee <= 100, "Fee must be less than 100%");
        escrowProviderFee = _escrowProviderFee;
    }

    function setIssueResolutionFeeForEscrowProvider(uint8 _issueResolutionFeeForEscrowProvider) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        require(_issueResolutionFeeForEscrowProvider <= 100, "Fee must be less than 100%");
        issueResolutionFeeForEscrowProvider = _issueResolutionFeeForEscrowProvider;
    }

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

    function viewMyEscrowsAsBuyer(address myAddress) public view returns (uint256[] memory escrowIds) {
        escrowIds = myEscrowsAsBuyer[myAddress];
    }

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

    function viewMyEscrowsAsSeller(address myAddress) public view returns (uint256[] memory escrowIds) {
        escrowIds = myEscrowsAsSeller[myAddress];
    }

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
    }

}

// TO BE DONE:- 

// VIEW FUNCTION - ACTIVE ISSUES TO BE RESOLVED BY ARBITER
// VIEW FUNCTION - ACTIVE CANCELLATION REQUESTS AS BUYER / SELLER
// EVENTS TO BE EMITTED WHEN ISSUE RESOLVED
