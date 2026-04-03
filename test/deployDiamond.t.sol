// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/Diamond.sol";

import "../contracts/facets/StakingFacet.sol";
import "../contracts/facets/ERC721BorrowerFacet.sol";
import "../contracts/facets/SVGFacet.sol";
import "../contracts/facets/MultisigFacet.sol";
import "../contracts/facets/MarketplaceFacet.sol";
import "../contracts/facets/ERC20Facet.sol";
import "../contracts/facets/ERC721Facet.sol";

import "./helpers/DiamondUpgradeHelper.sol";

contract DiamondDeployerTest is Test, DiamondUpgradeHelper {
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;

    function setUp() public {
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();

        address[] memory addAddrs = new address[](9);
        addAddrs[0] = address(dLoupe);
        addAddrs[1] = address(ownerF);
        addAddrs[2] = address(new StakingFacet());
        addAddrs[3] = address(new ERC721BorrowerFacet());
        addAddrs[4] = address(new SVGFacet());
        addAddrs[5] = address(new MultisigFacet());
        addAddrs[6] = address(new MarketplaceFacet());
        addAddrs[7] = address(new ERC20Facet());
        addAddrs[8] = address(new ERC721Facet());

        string[] memory names = new string[](9);
        names[0] = "DiamondLoupeFacet";
        names[1] = "OwnershipFacet";
        names[2] = "StakingFacet";
        names[3] = "ERC721BorrowerFacet";
        names[4] = "SVGFacet";
        names[5] = "MultisigFacet";
        names[6] = "MarketplaceFacet";
        names[7] = "ERC20Facet";
        names[8] = "ERC721Facet";

        IDiamondCut.FacetCut[] memory cuts = buildAddCutsByNames(addAddrs, names);
        executeDiamondCut(IDiamondCut(address(diamond)), cuts, address(0), "");
    }

    function testCombinedMarketplaceMultisig() public {
        
        address[] memory owners = new address[](2);
        owners[0] = address(this);
        owners[1] = address(0x1337);
        MultisigFacet(address(diamond)).initMultisig(owners, 2);

        uint256 price = 100;
        ERC20Facet(address(diamond)).mintERC20(address(diamond), price);

        address seller = address(0x123);
        ERC721Facet(address(diamond)).mintERC721(seller, 1);

        vm.prank(seller);
        MarketplaceFacet(address(diamond)).listNFT(1, price);

        bytes memory data = abi.encodeWithSelector(MarketplaceFacet.buyNFT.selector, 1);
        uint txIndex = MultisigFacet(address(diamond)).submitTransaction(address(diamond), 0, data);

        MultisigFacet(address(diamond)).confirmTransaction(txIndex);
        vm.prank(address(0x1337));
        MultisigFacet(address(diamond)).confirmTransaction(txIndex);

        MultisigFacet(address(diamond)).executeTransaction(txIndex);

        assertEq(ERC721Facet(address(diamond)).ownerOf(1), address(diamond));
        assertEq(ERC20Facet(address(diamond)).balanceOf(seller), price);
    }

    function testStakingFacet() public {
        vm.deal(address(this), 1 ether);
        StakingFacet(address(diamond)).stake{value: 1 ether}();
        assertEq(StakingFacet(address(diamond)).getStakedBalance(address(this)), 1 ether);
    }

    function testSVGFacet() public {
        SVGFacet(address(diamond)).setSVGColors("#000", "#fff");
        string memory svg = SVGFacet(address(diamond)).generateSVG(1);
        assertTrue(bytes(svg).length > 0);
    }

    function testERC721BorrowerFacet() public {
        ERC721Facet(address(diamond)).mintERC721(address(this), 2);
        ERC721Facet(address(diamond)).safeTransferFrom(address(this), address(diamond), 2);
        (address lender, ) = ERC721BorrowerFacet(address(diamond)).getBorrowedTokenDetails(address(diamond), 2);
        assertEq(lender, address(this));
    }
}
