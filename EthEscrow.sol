// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract Escrow {

    address public arbiter;
    
    enum EscrowState {
        NonExistent,
        Created,
        Funded,
        Cancelled,
        Resolved,
        Delivered,
        Completed
    }

    struct EthEscrow {
       address buyer;
       address seller;
       EscrowState escrowState; 
       uint256 ethAmount;
       uint256 deliverdAtTime;
       uint256 revisionsOffered;
       uint256 totalDeliveries;
       uint256 revisionsRequested;
       uint8 escrowProviderCutForEscrow;
       uint8 automaticWithdrawTimeForEscrow;
    }

    mapping(uint256 => EthEscrow) public ethEscrowId;
    mapping(uint256 => bool) public raisedIssueForEthEscrowId;
    mapping(uint256 => address) public raisedIssueBy;
    mapping(uint256 => bool) public raisedCancellationRequestForEthEscrowId;
    mapping(uint256 => address) public raisedCancellationRequestBy;

    uint8 public escrowProviderCut;
    uint8 public automaticWithdrawTime;
    uint256 public totalEthEscrowCreated;

    constructor() {
        arbiter = msg.sender;
    }

    // CREATE ETH ESCROW //

    function createNewEthEscrow (
        address _buyer,
        address _seller,
        uint256 _ethAmount,
        uint256 _revisionsOffered) public {
        require(_seller != _buyer, "Seller and buyer should not be same");
        require(msg.sender == _seller, "Seller should create escrow");
        require(ethEscrowId[totalEthEscrowCreated + 1].escrowState == EscrowState.NonExistent, "Escrow id exists");
        ethEscrowId[totalEthEscrowCreated + 1].buyer = _buyer;
        ethEscrowId[totalEthEscrowCreated + 1].seller = _seller;
        ethEscrowId[totalEthEscrowCreated + 1].ethAmount = _ethAmount;
        ethEscrowId[totalEthEscrowCreated + 1].revisionsOffered = _revisionsOffered;
        ethEscrowId[totalEthEscrowCreated + 1].escrowProviderCutForEscrow = escrowProviderCut;
        ethEscrowId[totalEthEscrowCreated + 1].automaticWithdrawTimeForEscrow = automaticWithdrawTime;
        ethEscrowId[totalEthEscrowCreated + 1].escrowState = EscrowState.Created;
        totalEthEscrowCreated++;
    }

    // FUND ETH ESCROW //

    function fundEthEscrow(uint256 escrowId) public payable {
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
            sendValue(ethEscrowId[escrowId].seller, ethEscrowId[escrowId].ethAmount * (100 - ethEscrowId[escrowId].escrowProviderCutForEscrow) / 100);
            sendValue(arbiter, ethEscrowId[escrowId].ethAmount * ethEscrowId[escrowId].escrowProviderCutForEscrow / 100);
            ethEscrowId[escrowId].escrowState = EscrowState.Completed;
        } else {
            require(ethEscrowId[escrowId].escrowState == EscrowState.Delivered, "Not delivered yet for escrow id");
            require(msg.sender == ethEscrowId[escrowId].buyer, "You are not the buyer for this escrow id");
            sendValue(ethEscrowId[escrowId].seller, ethEscrowId[escrowId].ethAmount * (100 - ethEscrowId[escrowId].escrowProviderCutForEscrow) / 100);
            sendValue(arbiter, ethEscrowId[escrowId].ethAmount * ethEscrowId[escrowId].escrowProviderCutForEscrow / 100);
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
            sendValue(ethEscrowId[escrowId].buyer, ethEscrowId[escrowId].ethAmount);
        } else {
            require(msg.sender == ethEscrowId[escrowId].buyer, "Caller not buyer");
            ethEscrowId[escrowId].escrowState = EscrowState.Cancelled;
            sendValue(ethEscrowId[escrowId].buyer, ethEscrowId[escrowId].ethAmount);
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
        uint256 arbiterAmount = ethEscrowId[escrowId].ethAmount * ethEscrowId[escrowId].escrowProviderCutForEscrow / 100;
        require(buyerAmount + sellerAmount + arbiterAmount == ethEscrowId[escrowId].ethAmount, "Total amount not equal to ETH amount");
        sendValue(ethEscrowId[escrowId].buyer, buyerAmount);
        sendValue(ethEscrowId[escrowId].seller, sellerAmount);
        sendValue(arbiter, arbiterAmount);
        ethEscrowId[escrowId].escrowState == EscrowState.Resolved;
    }

    // CONFIGURATIONS //

    function setAutomaticWithdrawTime(uint8 _automaticWithdrawTime) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        automaticWithdrawTime = _automaticWithdrawTime;
    }

    function setEscrowProviderCut(uint8 _escrowProviderCut) public {
        require(msg.sender == arbiter, "Caller not arbiter");
        require(_escrowProviderCut <= 100, "Cut must be less than 100%");
        escrowProviderCut = _escrowProviderCut;
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
