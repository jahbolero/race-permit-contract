interface iMetakages {
    function ownerOf(uint256 tokenId) external view returns (address);
    }
contract KageOrb is ERC721A, Ownable {
     iMetakages public Metakages;

    uint256 public MAX_SUPPLY = 3000;

    bool public isPresaleActive = false;

    bool _revealed = false;

    string private baseURI = "";

    bytes32 freemintRoot;

    struct UserPurchaseInfo {
        uint256 freeMinted;
    }

    mapping(address => UserPurchaseInfo) public userPurchase;
    mapping(address => uint256) addressBlockBought;
    mapping(uint256 => bool) public claimed;
    uint256[] public claimedIds;
    mapping(bytes32 => bool) public usedDigests;

    constructor(address MetakagesAddress) ERC721A("KageOrb", "KageOrb") {
          Metakages = iMetakages(MetakagesAddress);
    }

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
        for(uint256 id = 0; id < tokenIds.length; id++) {
            require(Metakages.ownerOf(tokenIds[id]) == msg.sender, "MUST_OWN_ALL_TOKENS");
            require(claimed[tokenIds[id]] == false, "TOKEN_ALREADY_CLAIMED");
            claimed[tokenIds[id]] = true;
            claimedIds.push(tokenIds[id]);
        }
        addressBlockBought[msg.sender] = block.timestamp;
        
        _mint(msg.sender, tokenIds.length);
    }

    function freeMint(
        bytes32[] memory proof,
        uint256 numberOfTokens,
        uint256 maxMint
    ) external isSecured(3) supplyMintLimit(numberOfTokens) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, maxMint));
        require(MerkleProof.verify(proof, freemintRoot, leaf), "PROOF_INVALID");
        require(
            userPurchase[msg.sender].freeMinted + numberOfTokens <= maxMint,
            "EXCEED_ALLOCATED_MINT_LIMIT"
        );
        addressBlockBought[msg.sender] = block.timestamp;
        userPurchase[msg.sender].freeMinted += numberOfTokens;
        _mint(msg.sender, numberOfTokens);
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
        override
        returns (string memory)
    {
        if (_revealed) {
            return string(abi.encodePacked(baseURI, Strings.toString(tokenId)));
        } else {
            return string(abi.encodePacked(baseURI));
        }
    }

    function setFreeMintRoot(bytes32 _freemintRoot) external onlyOwner {
        freemintRoot = _freemintRoot;
    }

    function decreaseSupply(uint256 _maxSupply) external onlyOwner {
        require(_maxSupply < MAX_SUPPLY, "CANT_INCREASE_SUPPLY");
        MAX_SUPPLY = _maxSupply;
    }

    function getClaimed()
        public
        view
        returns (uint256[] memory)
    {
        return claimedIds;
    }
}