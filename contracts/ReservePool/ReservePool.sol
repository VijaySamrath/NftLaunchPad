// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../LiquidityPool/LiquidityPool.sol";
import "../NativeToken/NativeToken.sol";

/// @notice ReservePool Contract for Investing in the Project and storing the funds Invested after deduction as fees
contract ReservePool {

    /// @notice fallback Function to Collect the funds
    receive() external payable{
  
    }

    /// @notice Instance for the Native Token
    NativeToken public nativeToken;

    /// @notice Instancs for the Liquiditypool contract
    LiquidityPool public liquidity;

    /// @notice Tracks locktime for the address 
    mapping (address => uint) lockTime; //LockTime
    
    /// @notice Tracks the msg.value invested by addresses
    mapping(address => uint) public ReserveBalances; //90%

    /// @notice Tracks the Fees collected by addressses as an Investment
    mapping(address => uint) public LiquidityBalance; //10%

   /// @param _liquidity address of Liquiditypool
   /// @param _nativeToken address of native token to be purschased while investing 
    constructor(address payable _liquidity, address _nativeToken){
        nativeToken = NativeToken(_nativeToken);
        liquidity = LiquidityPool(_liquidity);
    }
    
    /// @notice Investment made More than 1 eth and nativeToken is minted on the behalf calculation according to
    /// invested amount and the 10% Fee is deducted as per the Total Invested Amount 
    function invest() public payable{

        require(msg.value >=1, "ETH value is less than 1 ETH");

        uint reserveAmount = (msg.value * 90)/100;
        lockTime[msg.sender] = block.timestamp + 20 seconds;
       
        ReserveBalances[msg.sender] += reserveAmount; //90%

        uint liquidAmount = msg.value - reserveAmount; //100% - 90% = 10% // will make as a fee amount for the Token to be minted 
        LiquidityBalance[msg.sender] += liquidAmount;

        (bool success, ) = address(liquidity).call{value:liquidAmount}(""); // 10% goes to Liquidity pool as Fees 
        require(success, "Sending ETH to LiquidityPool failed");

        uint n = msg.value / 1 ether;   // 1 ether is equal to 1000 token
        uint tokenAmount = n * 1000 * 10**18; 

        if( msg.value > 1 ether && msg.value < 5 ether){
            uint bonus = tokenAmount + (tokenAmount * 10)/100 ;

            nativeToken.mint(msg.sender, bonus);
        }
        else if(msg.value >= 5 ether){
            uint bonus = tokenAmount + (tokenAmount * 20)/100 ;

            nativeToken.mint(msg.sender, bonus);
        }
    }

    /// @notice Withdraw the invested amount in the the Reserve pool after deduction 
    function withdraw() external {
        require(ReserveBalances[msg.sender] > 0, "insufficient funds");

        require(block.timestamp > lockTime[msg.sender], "lock time has not expired");

        //to avaoid reeentrancy attack we are doing accounting first and then transfer of value
        uint amount = ReserveBalances[msg.sender];
        ReserveBalances[msg.sender] = 0;

        uint tokenBalance = nativeToken.balanceOf(msg.sender);
        nativeToken.approve(address(this), tokenBalance); 
        nativeToken.burnFrom(msg.sender, tokenBalance);

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ether");
    }

     function getBalance() external view returns(uint bal){
      return bal = address(this).balance;
    }


}