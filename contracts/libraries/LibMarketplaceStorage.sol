// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibMarketplaceStorage {

    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    struct MarketplaceStorage {
        mapping(uint256 => Listing) listings;
    }

    function layout() internal pure returns (MarketplaceStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}