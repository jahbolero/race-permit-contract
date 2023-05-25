// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./operator-filter-registry/DefaultOperatorFiltererUpgradeable.sol";
import "./extensions/ERC721AQueryableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface iDrivrs {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract RacePermitUpgradeable is
    OwnableUpgradeable,
    DefaultOperatorFiltererUpgradeable,
    ERC721AQueryableUpgradeable
{
    iDrivrs public Drivrs;

    uint256 public MAX_SUPPLY;

    bool public isPresaleActive;

    bool _revealed;

    string private baseURI;

    mapping(address => uint256) addressBlockBought;
    mapping(uint256 => bool) public claimed;
    mapping(bytes32 => bool) public usedDigests;

    modifier isSecured(uint8 mintType) {
        require(
            addressBlockBought[msg.sender] < block.timestamp,
            "CANNOT_MINT_ON_THE_SAME_BLOCK"
        );
        require(tx.origin == msg.sender, "CONTRACTS_NOT_ALLOWED_TO_MINT");
        if (mintType == 3) {
            require(isPresaleActive, "FREE_MINT_IS_NOT_YET_ACTIVE");
        }

        _;
    }

    modifier supplyMintLimit(uint256 numberOfTokens) {
        require(
            numberOfTokens + totalSupply() <= MAX_SUPPLY,
            "NOT_ENOUGH_SUPPLY"
        );
        _;
    }

    function mint(uint256[] memory tokenIds)
        external
        isSecured(3)
        supplyMintLimit(tokenIds.length)
    {
        for (uint256 id = 0; id < tokenIds.length; id++) {
            require(
                Drivrs.ownerOf(tokenIds[id]) == msg.sender,
                "MUST_OWN_ALL_TOKENS"
            );
            require(claimed[tokenIds[id]] == false, "TOKEN_ALREADY_CLAIMED");
            claimed[tokenIds[id]] = true;
        }
        addressBlockBought[msg.sender] = block.timestamp;

        _mint(msg.sender, tokenIds.length);
    }

    function devMint(address[] memory _addresses, uint256[] memory quantities)
        external
        onlyOwner
    {
        require(_addresses.length == quantities.length, "WRONG_PARAMETERS");
        uint256 totalTokens = 0;
        for (uint256 i = 0; i < quantities.length; i++) {
            totalTokens += quantities[i];
        }
        require(totalTokens + totalSupply() <= MAX_SUPPLY, "NOT_ENOUGH_SUPPLY");
        for (uint256 i = 0; i < _addresses.length; i++) {
            _safeMint(_addresses[i], quantities[i]);
        }
    }

    //Essential
    function setBaseURI(string calldata URI) external onlyOwner {
        baseURI = URI;
    }

    function reveal(bool revealed, string calldata _baseURI) public onlyOwner {
        _revealed = revealed;
        baseURI = _baseURI;
    }

    function setPreSaleStatus() external onlyOwner {
        isPresaleActive = !isPresaleActive;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721AUpgradeable, IERC721AUpgradeable)
        returns (string memory)
    {
        if (_revealed) {
            return string(abi.encodePacked(baseURI, Strings.toString(tokenId)));
        } else {
            return string(abi.encodePacked(baseURI));
        }
    }

    function decreaseSupply(uint256 _maxSupply) external onlyOwner {
        require(_maxSupply < MAX_SUPPLY, "CANT_INCREASE_SUPPLY");
        MAX_SUPPLY = _maxSupply;
    }

    function getClaimed(uint256 start, uint256 batchSize)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory claimedTokens = new uint256[](batchSize);
        uint256 index = 0;
        for (uint256 i = start; i < start + batchSize && i < MAX_SUPPLY; i++) {
            if (claimed[i] == true) {
                claimedTokens[index] = i;
                index++;
            }
        }
        uint256[] memory trimmedArray = new uint256[](index);
        for (uint256 i = 0; i < index; i++) {
            trimmedArray[i] = claimedTokens[i];
        }
        return trimmedArray;
    }

    //OS FILTERER
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        payable
        override(ERC721AUpgradeable, IERC721AUpgradeable)
        onlyAllowedOperator(from)
    {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        payable
        override(ERC721AUpgradeable, IERC721AUpgradeable)
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    )
        public
        payable
        override(ERC721AUpgradeable, IERC721AUpgradeable)
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function initialize(address DrivrsAddress)
        public
        initializerERC721A
        initializer
    {
        __ERC721A_init("DRIVRSPASS", "DRIVRSPASS");
        __Ownable_init();
        Drivrs = iDrivrs(DrivrsAddress);
        DefaultOperatorFiltererUpgradeable.__DefaultOperatorFilterer_init();
        MAX_SUPPLY = 2888;
        isPresaleActive = false;
        _revealed = false;
        baseURI = "";
    }
}
