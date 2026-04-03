// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibERC721BorrowerStorage {

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
        assembly {
            ds.slot := 0
        }
    }
}