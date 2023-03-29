// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NativeToken is ERC20, ERC20Burnable, Ownable {

    uint256 public constant INITIAL_SUPPLY = 7_500_000_000 * 10**18;

    constructor() ERC20("NativeToken", "NT") {
       _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

}