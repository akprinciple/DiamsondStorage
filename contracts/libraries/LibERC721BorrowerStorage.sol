// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibERC721BorrowerStorage {
    bytes32 internal constant BORROWER_STORAGE_POSITION = keccak256("diamond.borrower.storage");

    struct BorrowedToken {
        address tokenAddress;
        uint256 tokenId;
        address lender;
        uint256 borrowedAt;
    }

    struct BorrowerStorage {
        mapping(bytes32 => BorrowedToken) borrowedTokens;
        bytes32[] activeBorrows;
    }

    function layout() internal pure returns (BorrowerStorage storage ds) {
        bytes32 position = BORROWER_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}