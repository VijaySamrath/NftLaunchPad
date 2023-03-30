// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/// @notice contract which keeps the tarck of the project Native Token. 
contract NativeToken is ERC20, ERC20Burnable, Ownable {
    
    /// @notice Initial supply of the Native Tokens for the project.
    uint256 public constant INITIAL_SUPPLY = 7_500_000_000 * 10**18;

    constructor() ERC20("NativeToken", "NT") {
       _mint(msg.sender, INITIAL_SUPPLY);
    }
    
    /// @notice method to mint the Native Token.
    /// @param to address of the Investor to whom Tokens will be Minted.
    /// @param amount uint256 no.of tokens to be minted to the Investor according to his Investment
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

}