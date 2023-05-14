// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract Escrow {

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
        Completed
    }

    mapping(uint256 => EthEscrow) public ethEscrowId;
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
        require(ethEscrowId[totalEthEscrowsCreated + 1].escrowState == EscrowState.NonExistent, "Escrow id exists");
        ethEscrowId[totalEthEscrowsCreated + 1].buyer = _buyer;
        ethEscrowId[totalEthEscrowsCreated + 1].seller = msg.sender;
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
        require(ethEscrowId[escrowId].escrowState == EscrowState.Funded, "Escrow id not funded yet");
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
        ethEscrowId[escrowId].escrowState = EscrowState.Funded;
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
            sendValue(payable(ethEscrowId[escrowId].buyer), ethEscrowId[escrowId].ethAmount);
        } else {
            require(msg.sender == ethEscrowId[escrowId].buyer, "Caller not buyer");
            ethEscrowId[escrowId].escrowState = EscrowState.Cancelled;
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

}
