// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

 interface NFTContract {
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function burnedTokensPerAddress(address checkAddress) external view returns (uint32);
    function resetBurnCounter(address addressToBeReset) external;
    function buyNFTWithToken(uint8 qty) external;
    
}

interface SquareMenTokenInterface {
    function transfer(address _to, uint256 _amount) external returns (bool);
}

contract SquareMenToken is ERC20, ERC20Burnable, Ownable {
    
    /**
     * @dev Set the max supply
     */
    uint256 private _maxSupply = 1000000 * 10 ** decimals();
    using SafeMath for uint256;

    constructor() ERC20("squaremen.xyz", "SQTOK") {
        /**
         * @dev Set the premint amount
         */
        _mint(msg.sender, 200000 * 10 ** decimals());
        _mint(address(this), 800000 * 10 ** decimals());
    }

    /**
     * @dev Returns max supply of the token.
     */
     function getMaxSupply() public view returns (uint256) {
         return _maxSupply;
     }

    /**
     * @dev Only the owner will be able to mint tokens and ensures
     * total supply doesn't go beyond the max supply
     */
     function mint(address to, uint256 amount) public onlyOwner {
         /**
          * @dev Total Spply + Mint Amount should not exceed Max Supply
          */
         require(totalSupply() + amount <= getMaxSupply(), "Max Supply Exceeded");
         _mint(to, amount);
     }
     
     //definitions
     uint public claimReward = 0.00 ether;
     uint public NFTprice = 0.00 ether;
     uint public rate = 4000;
     uint public weiRaised;
     bool public presaleActive = true;
     uint public presaleAmount = 0;
     
     address public NFTcoreAddress;
     NFTContract nftcontract;
     SquareMenTokenInterface squareMenTokenInterface;
     
       function SetClaimReward(uint _Price) external onlyOwner {
        claimReward = _Price;
    }
    
    function setNFTPrice(uint _Price) external onlyOwner {
        NFTprice = _Price;
    }

    function setCoreAddress(address _newCoreAddress) external onlyOwner {
        NFTcoreAddress = _newCoreAddress;
        nftcontract = NFTContract(NFTcoreAddress);
    }

    function claimToken() external  {
        squareMenTokenInterface = SquareMenTokenInterface(address(this));
        uint256 claims = nftcontract.burnedTokensPerAddress(msg.sender);
        require(claims>0,"Not eligible");
        nftcontract.resetBurnCounter(msg.sender);
        squareMenTokenInterface.transfer(msg.sender, claims.mul(claimReward));
        }  
        
    function buyNFT (uint8 qty) external{
        transfer(address(this), NFTprice.mul(qty));
        nftcontract.buyNFTWithToken(qty);
    }
    
      function setPreSaleActive(bool val) public onlyOwner {
        presaleActive = val;
    }
    
      function setRate(uint _Price) external onlyOwner {
        rate = _Price;
    }
    
    function buyTokens(address _beneficiary) public payable {
        require(_beneficiary != address(0), "insert a valid address");
        require(msg.value != 0, "Amount is zero");
        require(presaleActive!=false, "Presale is not active");
        require(presaleAmount<=15000 ether, "Presale amount exceeded");
        
    
        uint256 tokens = msg.value.mul(rate);
        uint256 tokensDivided = tokens.div(100);
        weiRaised = weiRaised.add(msg.value);
    
        transfer(_beneficiary, tokensDivided);
        presaleAmount+=tokensDivided;
        }
        
    function withdrawOwner() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
    }
        
    }