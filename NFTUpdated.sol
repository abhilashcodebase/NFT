// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GameItem is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;


//gift data storage
struct giftData{
    
    uint256 amount;
    address purchaser;
    string content;
    uint256 date;
    uint256 style;
} 

//event data storage
struct eventData{
    
    string eventName;
    uint256 eventID;
    uint256 amount;
    address purchaser;
    uint256 tokenID;
    uint256 end_Date;
}
//gift mapping
mapping(uint256 => address)private tokenMapping;
mapping(uint256 => giftData)private giftMapping;
mapping(uint256 => eventData) private eventMapping;
    constructor() ERC721("GameItem", "ITM") {}
//mint
    function awardItem(address player, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        
        return newItemId;
    }
//newGift collectibles    
    function newGift(
        
    uint256 amount,
    address purchaser,
    string memory content,
    uint256 date,
    uint256 style
        ) public returns(uint256,uint256){
            
            uint256 tokenID = awardItem(purchaser,"token uRI");
            giftMapping[tokenID] = giftData(
                amount,
                purchaser,
                content,
                date,
                style
                
                );
            uint time = block.timestamp;    
            return (tokenID,time);
            
        }
//get collectibles        
    function getGift(uint256 tokenID) public view returns(
        uint256,address,string memory,uint256,uint256)
        {
            giftData storage gift = giftMapping[tokenID];
            
            return(
                gift.amount,
                gift.purchaser, 
                gift.content,
                gift.date,
                gift.style
                
                );
        }
    //epoch time    
    function createEvents(
        string memory eventName,
        uint256 eventID,
        uint256 amount,
        address purchaser,
        string memory tokenURI,
        uint256 end_Date
        )
        public returns(uint256,uint256,uint256){
        
        uint256 tokenID = awardItem(purchaser,tokenURI);
        if(block.timestamp > end_Date) revert("revert");
        eventMapping[tokenID]= eventData(
            eventName,
            eventID,
            amount,
            purchaser,
            tokenID,
            end_Date
            );
        tokenMapping[tokenID]=purchaser ;    
        return(
            eventID,
            tokenID,
            end_Date
             
            );    
    }  
    
    function getEventDetails(
        uint256 tokenID)
        public view returns(string memory,uint256,uint256,address,uint256,uint256) {
          
          eventData storage eventDeatails = eventMapping[tokenID];
          
          return(
              eventDeatails.eventName,
              eventDeatails.eventID,
              eventDeatails.amount,
              eventDeatails.purchaser,
              eventDeatails.tokenID,
              eventDeatails.end_Date
              );
        }
    function isTokenExist(address purchaser,uint256 tokenID)public view returns(bool){
       return (tokenMapping[tokenID] == purchaser);
        
    }    
        
    function eventTokenTransfer(address owner, address purchaser, uint256 tokenID)public returns(bool){
        if(!isTokenExist(owner,tokenID)) revert("reverted"); 
        eventData storage eventDeatails = eventMapping[tokenID];
        uint256 end_Date = eventDeatails.end_Date;
        if(block.timestamp > end_Date) revert("Times up");
        transferFrom(owner,purchaser,tokenID);
        return true;
        
    }    
        
        
    
    
}