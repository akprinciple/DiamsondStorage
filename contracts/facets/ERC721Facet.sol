// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibAppStorage} from "../libraries/LibAppStorage.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface ISVGFacet {
    function generateSVG(uint256 tokenId) external view returns (string memory);
}

contract ERC721Facet {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /// @notice Initialize the Token Name and Symbol
    function initERC721(string memory _name, string memory _symbol) external {
        LibDiamond.enforceIsContractOwner();
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        s.name = _name;
        s.symbol = _symbol;
        
        // Note: You should register your supported interfaces centrally here or in your deployment script.
        // Example (if using standard LibDiamond):
        // LibDiamond.addSupportedInterface(0x80ac58cd); // ERC721
        // LibDiamond.addSupportedInterface(0x5b5e139f); // ERC721Metadata
    }

    function name() external view returns (string memory) {
        return LibAppStorage.appStorage().name;
    }

    function symbol() external view returns (string memory) {
        return LibAppStorage.appStorage().symbol;
    }

    // function balanceOf(address _owner) external view returns (uint256) {
    //     require(_owner != address(0), "ERC721: address zero is not a valid owner");
    //     return LibAppStorage.appStorage().balanceOf[_owner];
    // }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = LibAppStorage.appStorage().ownerOf[_tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /// @notice Generates simple on-chain metadata and SVG artwork
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(LibAppStorage.appStorage().ownerOf[tokenId] != address(0), "ERC721: invalid token ID");
        
        string memory idStr = _toString(tokenId);
        
        return string(
            abi.encodePacked(
                'data:application/json;utf8,{"name":"LEO NFT #',
                idStr,
                '", "description":"A simple onchain ERC721 token using AppStorage.", "image":"data:image/svg+xml;utf8,',
                ISVGFacet(address(this)).generateSVG(tokenId),
                '"}'
            )
        );
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(owner == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        require(msg.sender == owner, "ERC721: caller is not token owner");

        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        s.balanceOf[from] -= 1;
        s.balanceOf[to] += 1;
        s.ownerOf[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /// @notice Public minting function
    function mintERC721(address to, uint256 tokenId) external {
        require(to != address(0), "ERC721: mint to the zero address");
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(s.ownerOf[tokenId] == address(0), "ERC721: token already minted");

        s.balanceOf[to] += 1;
        s.ownerOf[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // --- Internal Helpers ---

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}