// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SquaremenGame is ERC1155, Ownable {

    bool public saleActive = true;

    string public name;
    string public symbol;
    uint32 public counter=0;
    uint32 public limit=10;


    mapping (uint256 => string) private _uris;
    mapping (uint32 => uint32) public TotalSupply;
    mapping (uint32 => uint32) public CurrentSupply;
    mapping (uint32 => uint32) public prices;

  

    constructor() ERC1155("") {
        name = "SquaremenGame";
        symbol = "SQGame";
    }
       
    function mint(uint32 nonce, uint32 qty) external payable {
        require(saleActive, "TRANSACTION: sale is not active");
        require(nonce<=limit, "cannot mint, nonce too high");
        require(CurrentSupply[nonce] + qty <= TotalSupply[nonce], "SUPPLY: Value exceeds totalSupply");
        require(msg.value >= prices[nonce]*qty, "PAYMENT: invalid value");
      
        _mint(msg.sender, nonce, qty, "");
        CurrentSupply[nonce]=CurrentSupply[nonce]+qty;
        
           
    }

    function SetTotalSupply(uint32[] memory _values, uint32[] memory _ids) external onlyOwner {
        for(uint32 i; i < _values.length; i++){
            TotalSupply[_ids[i]] = _values[i];
        }   
    }

    function SetPrices(uint32[] memory _values, uint32[] memory _ids) external onlyOwner {
        for(uint32 i; i < _values.length; i++){
            prices[_ids[i]] = _values[i];
        }   
    }

    function setUri(string calldata _uri, uint32 index )  external onlyOwner {
        _uris[index]=_uri;
    }

    function withdrawOwner() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setSaleActive(bool val) public onlyOwner {
        saleActive = val;
    }

     function setLimit(uint32 _limit) public onlyOwner {
        limit = _limit;
    }

    function uri(uint256 tokenId) override public view returns (string memory) {
        return(_uris[tokenId]);
    }

     function Giveaway(address[] calldata _addresses, string calldata _uri, uint32 nonce)
        external
        onlyOwner
    {
        uint256 arrayLength = _addresses.length;
        require(CurrentSupply[nonce] + arrayLength <= TotalSupply[nonce], "SUPPLY: Value exceeds totalSupply");
        for (uint256 i = 0; i < arrayLength; i++) {
            address current = _addresses[i];
            if (current != address(0)) {
                CurrentSupply[nonce]++;
                _mint(current, nonce, 1, "");
            }
        }
        _uris[nonce]=_uri;
    }

}