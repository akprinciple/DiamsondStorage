// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Test.sol";
// import "../contracts/facets/ERC721Facet.sol";

// /// @notice A mock receiver that correctly implements IERC721Receiver
// contract MockReceiver is IERC721Receiver {
//     function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
//         return IERC721Receiver.onERC721Received.selector;
//     }
// }

// /// @notice A mock receiver that does NOT implement IERC721Receiver
// contract BadReceiver {}

// contract ERC721FacetTest is Test {
//     ERC721Facet public facet;

//     address public user1 = address(0x111);
//     address public user2 = address(0x222);

//     function setUp() public {
//         facet = new ERC721Facet();

//         // Since this is a fresh isolated deployment, the Diamond owner is address(0).
//         // We can prank as address(0) to pass LibDiamond.enforceIsContractOwner()
//         vm.prank(address(0));
//         facet.initERC721("LEO NFT", "LEO");
//     }

//     // --- Initialization & View Tests ---

//     function test_InitERC721() public {
//         assertEq(facet.name(), "LEO NFT");
//         assertEq(facet.symbol(), "LEO");
//         assertTrue(facet.supportsInterface(0x80ac58cd)); // ERC721 Interface ID
//         assertTrue(facet.supportsInterface(0x5b5e139f)); // ERC721Metadata Interface ID
//     }

//     function test_OwnerOf_RevertInvalidToken() public {
//         vm.expectRevert("ERC721: invalid token ID");
//         facet.ownerOf(999);
//     }

//     function test_TokenURI() public {
//         facet.mint(user1, 777);
//         facet.mintERC721(user1, 777);
//         string memory uri = facet.tokenURI(777);
        
//         // Check that the URI was generated and populated with our on-chain data
//         assertTrue(bytes(uri).length > 0);
//     }

//     function test_TokenURI_RevertInvalidToken() public {
//         vm.expectRevert("ERC721: invalid token ID");
//         facet.tokenURI(999);
//     }

//     // --- Minting Tests ---

//     function test_Mint() public {
//         facet.mint(user1, 1);
//         facet.mintERC721(user1, 1);
//         assertEq(facet.ownerOf(1), user1);
//     }

//     function test_Mint_RevertZeroAddress() public {
//         vm.expectRevert("ERC721: mint to the zero address");
//         facet.mint(address(0), 1);
//         facet.mintERC721(address(0), 1);
//     }

//     function test_Mint_RevertAlreadyMinted() public {
//         facet.mint(user1, 1);
//         facet.mintERC721(user1, 1);
//         vm.expectRevert("ERC721: token already minted");
//         facet.mint(user2, 1);
//         facet.mintERC721(user2, 1);
//     }

//     // --- Transfer Tests ---

//     function test_TransferFrom() public {
//         facet.mint(user1, 1);
//         facet.mintERC721(user1, 1);

//         vm.prank(user1);
//         facet.transferFrom(user1, user2, 1);

//         assertEq(facet.ownerOf(1), user2);
//     }

//     function test_TransferFrom_RevertNotOwner() public {
//         facet.mint(user1, 1);
//         facet.mintERC721(user1, 1);

//         // user2 maliciously tries to transfer user1's token
//         vm.prank(user2);
//         vm.expectRevert("ERC721: caller is not token owner");
//         facet.transferFrom(user1, user2, 1);
//     }

//     function test_TransferFrom_RevertZeroAddress() public {
//         facet.mint(user1, 1);
//         facet.mintERC721(user1, 1);

//         vm.prank(user1);
//         vm.expectRevert("ERC721: transfer to the zero address");
//         facet.transferFrom(user1, address(0), 1);
//     }

//     function test_SafeTransferFrom_ToContract() public {
//         MockReceiver receiver = new MockReceiver();
//         facet.mint(user1, 1);
//         facet.mintERC721(user1, 1);

//         vm.prank(user1);
//         facet.safeTransferFrom(user1, address(receiver), 1);

//         assertEq(facet.ownerOf(1), address(receiver));
//     }

//     function test_SafeTransferFrom_RevertBadContract() public {
//         BadReceiver badReceiver = new BadReceiver();
//         facet.mint(user1, 1);
//         facet.mintERC721(user1, 1);

//         vm.prank(user1);
//         vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");
//         facet.safeTransferFrom(user1, address(badReceiver), 1);
//     }
// }