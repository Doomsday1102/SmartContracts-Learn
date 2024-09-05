// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";


error NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD=5e18;

    address[] public funders;

    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(){
        i_owner=msg.sender;
    }

    function fund() public payable {
        
        require(msg.value.getConversionRate() >= MINIMUM_USD,"Din't send enough ETH"); //1e18=1 ETH 
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender]+=msg.value;
    }

    function withdraw()  public onlyOwner {
        
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder=funders[funderIndex];
            addressToAmountFunded[funder]=0;
        }

        funders = new address[](0);
        //withdraw the funds
        //payable(msg.sender).transfer(address(this).balance);
        // send
        //bool success= payable(msg.sender).send(address(this).balance);
        //require(success,"Transaction Fail"); 
        //call
        (bool success,)=payable(msg.sender).call{value: address(this).balance}("");
        require(success,"Call Fail"); 

    }
    modifier onlyOwner(){
        //require(msg.sender==i_owner,"Must be Owner");
        if(msg.sender!=i_owner) {revert NotOwner();}
        _;
    }
    receive() external payable {
        fund();
     }

    fallback() external payable { 
        fund();
    }
  

}