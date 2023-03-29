const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Launchpad TEST", async function () {

    let Launchpad;

    async function deploy() {
      const NativeToken = await hre.ethers.getContractFactory("NativeToken");
      nativeToken = await NativeToken.deploy();
    
      await nativeToken.deployed();
    
      console.log("NativeToken deployed to:", nativeToken.address);
    
    const NftMint = await hre.ethers.getContractFactory("NftMint");
    nftMint = await NftMint.deploy();
    
    await nftMint.deployed();
    
    console.log("NftMint deployed to:", nftMint.address);
    
    const LiquidityPool = await hre.ethers.getContractFactory("LiquidityPool");
    liquidityPool = await LiquidityPool.deploy();
    
    await liquidityPool.deployed();
    
    console.log("LiquidityPool deployed to:", liquidityPool.address);
    
    const ReservePool = await hre.ethers.getContractFactory("ReservePool");
    reservePool = await ReservePool.deploy(liquidityPool.address, nativeToken.address);
    
    await reservePool.deployed();
    
    console.log("ReservePool deployed to:", reservePool.address);
    
    const StakingPool = await hre.ethers.getContractFactory("StakingPool");
    stakingPool = await StakingPool.deploy(nativeToken.address, nftMint.address);
    
    await stakingPool.deployed();
    
    console.log("StakingPool deployed to:", stakingPool.address);

    }

    before("Before", async () => {
        accounts = await ethers.getSigners();
        await deploy();
    })

    it('Set the Reserve Pool address in LiquidityPool', async () => {
    
      SetReservepool = await liquidityPool.setAddress(reservePool.address)

    })

    it("Invest in the Project After Research", async () => {

        //investment is done by the person 1
        await reservePool.connect(accounts[1]).invest({value: ethers.utils.parseEther("5")})

        // We collect 10% fee for the investment in the project in a liquidity pool which is non-refundable.
        console.log("Liquidity Balance of account", await reservePool.LiquidityBalance(accounts[1].address));

        //We Collect 90% fee in the Reserve pool which to be whithdrawn with some Time period of investment.
        console.log("Reserve Balance of account", await reservePool.ReserveBalances(accounts[1].address));

        //Balance of Reserve Pool in wei
        console.log("Balance of Reserve Pool", await reservePool.getBalance());
        
        console.log("Balance Of Native Token Minted after Investing", await nativeToken.balanceOf(accounts[1].address))
    })

    it("Check the LiquidityPool Balance", async () => {

      //Total Funds collected for project as fee in wei
      console.log("Balance of Liquidity Pool", await liquidityPool.getBalance());

      //Owner of the Liquidity pool 
      console.log("Owner of Liquidity Pool", await liquidityPool.owner());
    })

    it("Staking Native Token", async () => {

      //add person 1 as a stake holder
      await stakingPool.addStakeholder(accounts[1].address)

      //Giving Approve to Staking Pool for Staking
      await nativeToken.connect(accounts[1]).approve(stakingPool.address, await nativeToken.balanceOf(accounts[1].address))

      console.log("allowance given", await nativeToken.allowance(accounts[1].address, stakingPool.address))

      //Create Stake by putiing No. of Token Person 1 want to stake 
      await stakingPool.connect(accounts[1]).createStake(nativeToken.balanceOf(accounts[1].address))

      //Native Token of person 1 becomes 0 after staking
      console.log("Person 1 Account Balance Should be 0", await nativeToken.balanceOf(accounts[1].address))

      //Total Stakes of Native Token
      console.log("Total Stakes of NativeToken in Staking Pool", await stakingPool.totalStakes())

    })

    it("Calculate the Reward for Staking and DISITRIBUTE THE REWARD", async () => {
      
      // calculate The Reward of the Staked Token 
      console.log("Reward for the person1 who staked", await stakingPool.calculateReward(accounts[1].address))

      //Total Rewrd Before Distribution 
      console.log("Total Reward in the contract Before", await stakingPool.totalRewards())

      await stakingPool.connect(accounts[0]).distributeRewards()

      // Total Reward after Distribution 
      console.log("Total Reward in the contract After Distribution of Reward", await stakingPool.totalRewards())

    })
    
    it("As Rewards distributed person can claim NFt ", async () => {

      console.log("Reward for the person1 Before Claiming Nft ", await stakingPool.rewardOf(accounts[1].address))

      // Person 1 Claims Nft
      await stakingPool.connect(accounts[1]).ClaimNft()
      
      // reward after claiming nft 
      console.log("Reward for the person1 After Claiming Nft ", await stakingPool.rewardOf(accounts[1].address))
      
      //Nft Minted to the person 1
      console.log("Nft person1 have ", await nftMint.balanceOf(accounts[1].address))

    })

    it("As the staking ends Person can remove with the stake", async () => {
 
      // Stake of Person 1 in the contract
      console.log("Stake of Person 1", await stakingPool.stakeOf(accounts[1].address))

      console.log("Person 1 NativeToken Balance Before removing Stake", await nativeToken.balanceOf(accounts[1].address))

      // Remove Stake after the Reward is finally Distributed
      await stakingPool.connect(accounts[1]).removeStake(ethers.BigNumber.from("60000000000000000000"))

      //Balance of NativeToken 
      console.log("Person 1 NativeToken Balance after removing Stake", await nativeToken.balanceOf(accounts[1].address))


    })

});
