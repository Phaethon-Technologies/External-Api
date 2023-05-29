// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LoanData {
    struct Loan {
        string loanId;
        uint256 stage2FinanceFee;
        uint256 penaltyCommitmentFee;
        uint256 penaltyFinanceFee;
        uint256 newRepaymentAmount;
    }

    Loan[] public loans;


    function getLoanById(uint256 index) public view returns (Loan memory) {
        require(index < loans.length, "Invalid index");
        return loans[index];
    }
}
