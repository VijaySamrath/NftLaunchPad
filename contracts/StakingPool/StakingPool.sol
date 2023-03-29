// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../NftMint/NftMint.sol";
import "../ReservePool/ReservePool.sol";
import "../NativeToken/NativeToken.sol";
/// @notice Staking Pool contract for the staking the Native Tokends and earning the Reward used for 
/// Purchasing the Nft
contract StakingPool is Ownable {

    using SafeMath for uint256;
    
    /// @notice List of stake holders that have staked 
    address[] public stakeholders;

    /// @notice Keeping Track of the investors total nativeToken staked 
    mapping(address => uint256) internal stakes;
    
    /// @notice Keeping tracks of the reward of the investors who staked 
    mapping(address => uint256) internal rewards;

    /// @notice nftmint for Minting the NFT  
    NftMint public nftMint;
 
    /// @notice container for all the Native token staked or not staked   
    NativeToken public nativeToken;

    /// @param _nativeToken address of native token to be staked  
    /// @param _nftMint address of NFT to minted by investors
    constructor(address _nativeToken, address _nftMint){
        nftMint = NftMint(_nftMint);
        nativeToken = NativeToken(_nativeToken);
    }
     
    /// @notice return the balance of the native token for particular address
    /// @return balance of investors  
    function balanceOf(address _address) external view returns(uint){
        uint balance = nativeToken.balanceOf(_address);
        return balance;
    }
    
    /// @notice Register as a Stakeholders who are interseted to stake 
    /// @param _stakeholder address investors who wish to stake 
    function addStakeholder(address _stakeholder) public {
       (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeholders.push(_stakeholder);
   }

    /// @notice check address id the stakeholder or not 
    /// @param _address the address to be verified
    /// @return bool, uint256  whether the address is the atkw holder and its position 
     function isStakeholder(address _address)public view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < stakeholders.length; s++){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);
   }
   
   /// @notice To deregister stakeholder
   /// @param _stakeholder addres to be deregistered  
   function removeStakeholder(address _stakeholder)
       public
   {
       (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
           stakeholders[s] = stakeholders[stakeholders.length - 1];
           stakeholders.pop();
       }
   }
    
    /// @notice to get the total stakes by the stakeholder.
    /// @param _stakeholder address to get the total stakes made.
    /// @return uint256 The amount of nativetokens staked.
    function stakeOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder];
   }
    
    /// @notice to get all the stakes in the contract made by all the stakeholders
    /// @return uint256 the total staked collectively in the contract
    function totalStakes()
       public
       view
       returns(uint256)
   {
       uint256 _totalStakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s++){
           _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
       }
       return _totalStakes;
   }
     
    /// @notice function to create stake.
    /// @param _stake amount of nativeToken stake to be made. 
     function createStake(uint256 _stake)
       public
   {
       nativeToken.burnFrom(msg.sender, _stake);
       if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
       stakes[msg.sender] = stakes[msg.sender].add(_stake);
   }

   /// @notice function to remove stake.
   /// @param _stake the amount of nativeToken stake to be removed.
    function removeStake(uint256 _stake)
       public
   {
       stakes[msg.sender] = stakes[msg.sender].sub(_stake);
       if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
       nativeToken.mint(msg.sender, _stake);
   }
    
    /// @notice function to get the reward of the particular stakeholder
    /// @param _stakeholder To check the rewards of the stake holder.
    function rewardOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return rewards[_stakeholder];
   }

   /// @notice to check the rewards from all the stakeholders collectively.
   /// @return uin256  total rewards from all the stakeholders collectively.
   function totalRewards()
       public
       view
       returns(uint256)
   {
       uint256 _totalRewards = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
       }
       return _totalRewards;
   }

   /// @notice to calculate reward from the simple calculation for the particular stakeholders.
   /// @param  _stakeholder particular stakeholders whose reward should be calculated.
    function calculateReward(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder] / 100;
   }

   /// @notice To Distribute reward to all the stake holder in a single click
   function distributeRewards()
       public
       onlyOwner
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           address stakeholder = stakeholders[s];
           uint256 reward = calculateReward(stakeholder);
           rewards[stakeholder] = rewards[stakeholder].add(reward);
       }
   }

   /// @notice function to withdraw reward for a particular stake holders 
    function withdrawReward()
       public
   {
       uint256 reward = rewards[msg.sender];
       rewards[msg.sender] = 0;   
       nativeToken.mint(msg.sender, reward);
   }
    
   /// @notice returns the length og total stake holders in the staking pool contarct
   /// @return uint total no. of stakeholders 
   function stakeHolderCount() public view returns(uint){
    return stakeholders.length;
   }

   /// @notice function to claim the project Nft using the rewards based on the simple calculation
   /// can be modified according to the usecase and demands
   function ClaimNft() external{

       uint256 TotalReward = calculateReward(msg.sender);
    
       if(TotalReward > 5000000000000000 ){
           uint256 NftReward = TotalReward - 5000000000000000;
           rewards[msg.sender] = rewards[msg.sender] - NftReward;
           
           nftMint.safeMint(msg.sender);
           
       }
   } 

}