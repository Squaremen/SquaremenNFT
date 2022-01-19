// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SquareMen is ERC721, Ownable { 

    bool public saleActive = false;
    bool public presaleActive = false;
    
    string internal baseTokenURI;

    uint public price = 0.00 ether;
    uint public totalSupply = 10000;
    uint public nonce = 0;
    uint public maxTx = 3;
    
    event Mint(address owner, uint qty);
    event Giveaway(address to, uint qty);
    event Withdraw(uint amount);

    address public m1;
    address public ERC20Contract;
    

    mapping (address => uint256) public presaleWallets;
    mapping (address => uint32) public burnedTokens;
    mapping (uint256 => bool) public isBurned;
    mapping (uint32 => uint8) public rareNFT;

    
    
    constructor() ERC721("squaremen.xyz", "SQMEN") {}
    
    function setPrice(uint newPrice) external onlyOwner {
        price = newPrice;
    }
    
    function setBaseTokenURI(string calldata _uri) external onlyOwner {
        baseTokenURI = _uri;
    }
    
    function setTotalSupply(uint newSupply) external onlyOwner {
        totalSupply = newSupply;
    }

    function setPresaleActive(bool val) public onlyOwner {
        presaleActive = val;
    }

    function setSaleActive(bool val) public onlyOwner {
        saleActive = val;
    }

    function setPresaleWallets(address[] memory _a, uint256[] memory _amount) public onlyOwner {
        for(uint256 i; i < _a.length; i++){
            presaleWallets[_a[i]] = _amount[i];
        }
    }

    function editPresaleWallets(address[] memory _a, uint256[] memory _amount) public onlyOwner {
        for(uint256 i; i < _a.length; i++){
            presaleWallets[_a[i]] = _amount[i];
        }
    }

    function setMembersAddresses(address _a) public onlyOwner {
        m1 = _a;
    }
    
    function setERC20ContractAddress(address _a) public onlyOwner {
        ERC20Contract = _a;
    }
    

    function withdraw(uint256 amount) public payable onlyOwner {
        require(payable(m1).send(amount));
    }
    
    function setMaxTx(uint newMax) external onlyOwner {
        maxTx = newMax;
    }
    
      function getAssetsByOwner(address _owner) public view returns(uint[] memory) {
        uint[] memory result = new uint[](balanceOf(_owner));
        uint counter = 0;
        for (uint i = 0; i < nonce; i++) {
            if (isBurned[i] == false) {
                if (ownerOf(i)==_owner){
                result[counter] = i;
                counter++;
                }
            }
        }
        return result;
    }
    
    function getMyAssets() external view returns(uint[] memory){
        return getAssetsByOwner(tx.origin);
    }

    function _baseURI() internal override view returns (string memory) {
        return baseTokenURI;
    }
    
    function giveaway(address to, uint qty) external onlyOwner {
        require(qty + nonce <= totalSupply, "SUPPLY: Value exceeds totalSupply");
        for(uint i = 0; i < qty; i++){
            uint tokenId = nonce;
            _safeMint(to, tokenId);
            nonce++;
        }
        emit Giveaway(to, qty);
    }

    function buyPresale(uint qty) external payable {
        uint256 qtyAllowed = presaleWallets[msg.sender];
        require(presaleActive, "TRANSACTION: Presale is not active");
        require(qtyAllowed > 0, "TRANSACTION: You can't mint on presale");
        require(qty + nonce <= totalSupply, "SUPPLY: Value exceeds totalSupply");
        require(msg.value == price * qty, "PAYMENT: invalid value");
        presaleWallets[msg.sender] = qtyAllowed - qty;
        for(uint i = 0; i < qty; i++){
            uint tokenId = nonce;
            _safeMint(msg.sender, tokenId);
            nonce++;
        }
        emit Mint(msg.sender, qty);
    }
    
    function buy(uint qty) external payable {
        require(saleActive, "TRANSACTION: sale is not active");
        require(qty <= maxTx || qty < 1, "TRANSACTION: qty of mints not alowed");
        require(qty + nonce <= totalSupply, "SUPPLY: Value exceeds totalSupply");
        require(msg.value >= price * qty, "PAYMENT: invalid value");
        for(uint i = 0; i < qty; i++){
            uint tokenId = nonce;
            _safeMint(msg.sender, tokenId);
            nonce++;
        }
        emit Mint(msg.sender, qty);
    }
    
    function withdrawOwner() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function BurnToken(uint32 _id) external {
           require(ownerOf(_id) == msg.sender, "You don't Own this NFT");
           super._burn(_id);
           burnedTokens[msg.sender]++;
           isBurned[_id]=true;
           
           if (rareNFT[_id]>0)
           {
           burnedTokens[msg.sender]+=rareNFT[_id];
           }
    }
            
    function resetBurnCounter(address addressToBeReset) external {
        require(msg.sender==ERC20Contract, "only the SQMEN ERC20 Contract can do this");
        burnedTokens[tx.origin]=0;
    }
    
     function buyNFTWithToken(uint8 qty) external {
        require(msg.sender==ERC20Contract, "only the SQMEN ERC20 Contract can do this");
        for(uint i = 0; i < qty; i++){
            uint tokenId = nonce;
            _safeMint(tx.origin, tokenId);
            nonce++;
        }
        emit Mint(tx.origin, qty);
    }

    function burnedTokensPerAddress(address checkAddress) external view returns (uint32) {
        return burnedTokens[checkAddress];
    }
    
    function SetRares(uint8[] memory _values, uint32[] memory _ids) external onlyOwner {
        for(uint256 i; i < _values.length; i++){
            rareNFT[_ids[i]] = _values[i];
        }
        
        
    }
        
      
    }