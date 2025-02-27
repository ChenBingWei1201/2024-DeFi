// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}


contract NFinTech is IERC721 {
    string private _name;
    string private _symbol;

    uint256 private _tokenId;

    mapping(uint256 => address) private _owner;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private isClaim;

    error ZeroAddress();

    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
    }

    function claim() public {
        if (isClaim[msg.sender] == false) {
            uint256 id = _tokenId;
            _owner[id] = msg.sender;

            _balances[msg.sender] += 1;
            isClaim[msg.sender] = true;

            _tokenId += 1;
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owner[tokenId];
        if (owner == address(0)) revert ZeroAddress();
        return owner;
    }

    // New mappings for approvals
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // TODO: Implement setApproveForAll function
    function setApprovalForAll(address operator, bool approved) public {
        if (operator == address(0)) revert ZeroAddress();
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // TODO: Implement isApprovedForAll function
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    
    // TODO: Implement approve function
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        if (to == owner) revert("Approval to current owner");
        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) {
            revert("Approve caller is not owner nor approved for all");
        }
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
    // TODO: Implement getApproved function
    function getApproved(uint256 tokenId) public view returns (address) {
        if (_owner[tokenId] == address(0)) revert("Token does not exist");
        return _tokenApprovals[tokenId];
    }

    // TODO: Implement transferFrom function
    function transferFrom(address from, address to, uint256 tokenId) public {
        if (to == address(0)) revert ZeroAddress();
        if (from != ownerOf(tokenId)) revert("From address is not owner");
        if (msg.sender != from && !isApprovedForAll(from, msg.sender) && msg.sender != getApproved(tokenId)) {
            revert("Transfer caller is not owner nor approved");
        }

        _balances[from] -= 1;
        _balances[to] += 1;
        _owner[tokenId] = to;

        delete _tokenApprovals[tokenId];

        emit Transfer(from, to, tokenId);
    }
    
    // TODO: Implement safeTransferFrom function
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        if (to.code.length > 0) {
            try IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721TokenReceiver.onERC721Received.selector) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}
