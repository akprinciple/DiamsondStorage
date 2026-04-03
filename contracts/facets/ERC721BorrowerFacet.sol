// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibERC721BorrowerStorage} from "../libraries/LibERC721BorrowerStorage.sol";

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract ERC721BorrowerFacet {
    event ERC721Borrowed(address indexed tokenAddress, uint256 indexed tokenId, address indexed lender);
    event ERC721Returned(address indexed tokenAddress, uint256 indexed tokenId, address indexed lender);

     function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata 
    ) external returns (bytes4) {
        LibERC721BorrowerStorage.BorrowerStorage storage ds = LibERC721BorrowerStorage.layout();
        
        bytes32 borrowId = keccak256(abi.encodePacked(msg.sender, tokenId));
        
        ds.borrowedTokens[borrowId] = LibERC721BorrowerStorage.BorrowedToken({
            tokenAddress: msg.sender,
            tokenId: tokenId,
            lender: from,
            borrowedAt: block.timestamp
        });
        ds.activeBorrows.push(borrowId);

             emit ERC721Borrowed(msg.sender, tokenId, from);

            return ERC721BorrowerFacet.onERC721Received.selector;
    }

    function returnBorrowedERC721(address tokenAddress, uint256 tokenId) external {
        LibERC721BorrowerStorage.BorrowerStorage storage ds = LibERC721BorrowerStorage.layout();
        bytes32 borrowId = keccak256(abi.encodePacked(tokenAddress, tokenId));
        
        address lender = ds.borrowedTokens[borrowId].lender;
        require(lender != address(0), "ERC721BorrowerFacet: Token not borrowed or already returned");

        delete ds.borrowedTokens[borrowId];

        
        IERC721(tokenAddress).safeTransferFrom(address(this), lender, tokenId);

        emit ERC721Returned(tokenAddress, tokenId, lender);
    }

    function getBorrowedTokenDetails(address tokenAddress, uint256 tokenId) 
        external 
        view 
        returns (address lender, uint256 borrowedAt) 
    {
        LibERC721BorrowerStorage.BorrowerStorage storage ds = LibERC721BorrowerStorage.layout();
        bytes32 borrowId = keccak256(abi.encodePacked(tokenAddress, tokenId));
        LibERC721BorrowerStorage.BorrowedToken memory token = ds.borrowedTokens[borrowId];
        return (token.lender, token.borrowedAt);
    }
}
