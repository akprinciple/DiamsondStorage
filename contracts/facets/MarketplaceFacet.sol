// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibMarketplaceStorage} from "../libraries/LibMarketplaceStorage.sol";
import {LibAppStorage} from "../libraries/LibAppStorage.sol";
import {LibERC20Storage} from "../libraries/LibERC20Storage.sol";

contract MarketplaceFacet {
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event ListingCanceled(uint256 indexed tokenId, address indexed seller);
    event NFTBought(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);
    
    // Mirroring the ERC721 transfer event so indexers track the sale transfer properly
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function listNFT(uint256 _tokenId, uint256 _price) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(s.ownerOf[_tokenId] == msg.sender, "MarketplaceFacet: Caller is not token owner");
        require(_price > 0, "MarketplaceFacet: Price must be greater than 0");

        LibMarketplaceStorage.MarketplaceStorage storage ms = LibMarketplaceStorage.layout();
        ms.listings[_tokenId] = LibMarketplaceStorage.Listing({
            seller: msg.sender,
            price: _price,
            active: true
        });

        emit NFTListed(_tokenId, msg.sender, _price);
    }

    function cancelListing(uint256 _tokenId) external {
        LibMarketplaceStorage.MarketplaceStorage storage ms = LibMarketplaceStorage.layout();
        require(ms.listings[_tokenId].active, "MarketplaceFacet: Listing is not active");
        require(ms.listings[_tokenId].seller == msg.sender, "MarketplaceFacet: Caller is not the seller");

        ms.listings[_tokenId].active = false;

        emit ListingCanceled(_tokenId, msg.sender);
    }

    function buyNFT(uint256 _tokenId) external {
        LibMarketplaceStorage.MarketplaceStorage storage ms = LibMarketplaceStorage.layout();
        LibMarketplaceStorage.Listing storage listing = ms.listings[_tokenId];

        require(listing.active, "MarketplaceFacet: NFT is not listed for sale");

        address seller = listing.seller;
        uint256 price = listing.price;

        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(s.ownerOf[_tokenId] == seller, "MarketplaceFacet: Seller no longer owns this NFT");

        listing.active = false;

        s.balanceOf[seller] -= 1;
        s.balanceOf[msg.sender] += 1;
        s.ownerOf[_tokenId] = msg.sender;
        emit Transfer(seller, msg.sender, _tokenId);
        emit NFTBought(_tokenId, msg.sender, seller, price);

        LibERC20Storage.ERC20Storage storage erc20ds = LibERC20Storage.layout();
        require(erc20ds.balances[msg.sender] >= price, "MarketplaceFacet: Insufficient ERC20 balance");

        unchecked {
            erc20ds.balances[msg.sender] -= price;
            erc20ds.balances[seller] += price;
        }
    }

    function getListing(uint256 _tokenId) external view returns (address seller, uint256 price, bool active) {
        LibMarketplaceStorage.Listing memory listing = LibMarketplaceStorage.layout().listings[_tokenId];
        return (listing.seller, listing.price, listing.active);
    }
}