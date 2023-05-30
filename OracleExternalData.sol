// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";


contract OracleExternalData is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 private constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10;
    uint256 public currentPrice;

    struct LoanData {
        string loanId;
        uint256 stage2FinanceFee;
        uint256 penaltyCommitmentFee;
        uint256 penaltyFinanceFee;
        uint256 newRepaymentAmount;
    }

    event RequestLoanDataFulfilled(
        bytes32 indexed requestId,
        LoanData loanData
    );


    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
    }
    function uint2str(uint256 _num) internal pure returns (string memory) {
    if (_num == 0) {
        return "0";
    }

    uint256 tempNum = _num;
    uint256 digits;
    while (tempNum != 0) {
        digits++;
        tempNum /= 10;
    }

    bytes memory buffer = new bytes(digits);
    uint256 index = digits - 1;
    tempNum = _num;
    while (tempNum != 0) {
        buffer[index--] = bytes1(uint8(48 + (tempNum % 10)));
        tempNum /= 10;
    }

    return string(buffer);
}


    function requestLoanData(
        address _oracle,
        string memory _jobId,
        uint256 _loanId
    ) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillLoanData.selector
        );
        req.add(
            "get",
            string(
                abi.encodePacked(
                    "https://oracle-api-data.onrender.com/?loanid=",
                    uint2str(_loanId)
                )
            )
        );
        req.add("path", "loanData");
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function fulfillLoanData(
        bytes32 _requestId,
        string memory _loanId,
        uint256 _stage2FinanceFee,
        uint256 _penaltyCommitmentFee,
        uint256 _penaltyFinanceFee,
        uint256 _newRepaymentAmount
    ) public recordChainlinkFulfillment(_requestId) {
        LoanData memory loanData = LoanData(
            _loanId,
        _stage2FinanceFee,
        _penaltyCommitmentFee,
        _penaltyFinanceFee,
        _newRepaymentAmount
        );
        emit RequestLoanDataFulfilled(_requestId, loanData);
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }


    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        cancelChainlinkRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
    }

    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}

           
