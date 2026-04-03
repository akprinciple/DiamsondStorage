// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Script.sol";
// import "../contracts/facets/ERC721Facet.sol";
// import "../test/helpers/DiamondUpgradeHelper.sol";

// contract AddERC721Facet is Script, DiamondUpgradeHelper {
//     ERC721Facet nftDiamond = ERC721Facet(diamondAddress);

// nftDiamond.mint(msg.sender, 1);
// string memory uri = nftDiamond.tokenURI(1);
// ERC721Facet nftDiamond = ERC721Facet(diamondAddress);

// nftDiamond.mint(msg.sender, 1);
// string memory uri = nftDiamond.tokenURI(1);
// ERC721Facet nftDiamond = ERC721Facet(diamondAddress);

// nftDiamond.mint(msg.sender, 1);
// string memory uri = nftDiamond.tokenURI(1);
// ERC721Facet nftDiamond = ERC721Facet(diamondAddress);

// nftDiamond.mint(msg.sender, 1);
// string memory uri = nftDiamond.tokenURI(1);
// ERC721Facet nftDiamond = ERC721Facet(diamondAddress);

// nftDiamond.mint(msg.sender, 1);
// string memory uri = nftDiamond.tokenURI(1);
//     function run() external {
//         address diamond = 0x0000000000000000000000000000000000000000; 
        
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         vm.startBroadcast(deployerPrivateKey);

//         ERC721Facet erc721Facet = new ERC721Facet();

//         IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
//         cuts[0] = buildAddCutByName(address(erc721Facet), "ERC721Facet");

//         bytes memory initCalldata = abi.encodeWithSelector(
//             ERC721Facet.initERC721.selector, 
//             "LEO NFT", 
//             "LEO"
//         );

//         executeDiamondCut(
//             IDiamondCut(diamond), 
//             cuts, 
//             address(erc721Facet), 
//             initCalldata
//         );

//         vm.stopBroadcast();
//     }
// }