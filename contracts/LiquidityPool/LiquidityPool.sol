// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../ReservePool/ReservePool.sol";

/// @title LiquidityPool contract for Storing Funds deducted as Fee From Investors

contract LiquidityPool{
    /// @notice Project owner
    address public owner;

    /// @notice fallback Function to Collect the funds
    receive() external payable{
        _requireReservePool();
    }
    
    /// @notice using Owner in the functions called only by Owner
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner!!");
        _;
    }    

    /// @notice setting the Owner who deploys the contract
    constructor(){
        owner = msg.sender;
        }

    /// @notice ReservePool instance
    ReservePool public reservepool;

    /// @notice Set Reservepool, Owner will use to Recieve the funds in Liquidity pool as fees from here
    /// @param  _reservepool address of ReservePool contract
    function setAddress(address payable _reservepool) external onlyOwner{
        reservepool = ReservePool(_reservepool);
    }

    /// @notice Only the Owner can call this 
    function _requireReservePool() internal view{
        require(msg.sender == address(reservepool), "Only reservepool address");
    } 
    
    /// @notice returns the Balance of the LiquidityPool
    /// @return bal (balance) of the contract
    function getBalance() external view returns(uint bal){
      return bal = address(this).balance;
    }

}