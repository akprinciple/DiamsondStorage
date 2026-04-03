// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibMarketplaceStorage {
    bytes32 internal constant MARKETPLACE_STORAGE_POSITION = keccak256("diamond.marketplace.storage");

    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    struct MarketplaceStorage {
        mapping(uint256 => Listing) listings;
    }

    function layout() internal pure returns (MarketplaceStorage storage ds) {
        bytes32 position = MARKETPLACE_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}