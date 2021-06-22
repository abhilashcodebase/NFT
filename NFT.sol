// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GameItem is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("GameItem", "ITM") {}
    uint256[]public position;
    struct awardStruct{
        address player;
        uint256 tokenId;
        uint256 awardPosition;
    }
    event awardNotification(address player, uint256 tokenId, uint256 awardPosition);
    mapping(uint256 => awardStruct)public awardMap;

    function issueToken(address player, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
    
    function isAwardExist(uint256 tokenId) public view returns(bool isIndeed){
        if(position.length == 0) return false;
        return(position[awardMap[tokenId].tokenId] == tokenId);
    }
    
    
    function setAwardToken(address player, uint256 awardPosition, string memory tokenURI )public returns(bool){
        if(isAwardExist(awardPosition)) revert("already exist");
        uint256 ID = issueToken(player,tokenURI);
        awardMap[ID].awardPosition = awardPosition;
        awardMap[ID].player = player;
        awardMap[ID].tokenId = ID;
        emit awardNotification(player,awardPosition,ID);
        position.push(awardPosition);
        return true;
        
    }
    
    function getOwnership(uint256 tokenId)public returns(address){
        address owner = ERC721.ownerOf(tokenId);
        return owner;
    }
    
    function transferToken(address _from, address _to, uint256 _tokenID  )public {
      if(isAwardExist(_tokenID)) revert("awarded token cannot be transferrable");  
      ERC721.transferFrom(_from,_to,_tokenID);
      
    }
}
