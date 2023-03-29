// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
 
  // We get the contract to deploy
  const NativeToken = await hre.ethers.getContractFactory("NativeToken");
  const nativeToken = await NativeToken.deploy();

  await nativeToken.deployed();

  console.log("NativeToken deployed to:", nativeToken.address);

const NftMint = await hre.ethers.getContractFactory("NftMint");
const nftMint = await NftMint.deploy();

await nftMint.deployed();

console.log("NftMint deployed to:", nftMint.address);

const LiquidityPool = await hre.ethers.getContractFactory("LiquidityPool");
const liquidityPool = await LiquidityPool.deploy();

await liquidityPool.deployed();

console.log("LiquidityPool deployed to:", liquidityPool.address);

const ReservePool = await hre.ethers.getContractFactory("ReservePool");
const reservePool = await ReservePool.deploy(liquidityPool.address, nativeToken.address);

await reservePool.deployed();

console.log("ReservePool deployed to:", reservePool.address);

const StakingPool = await hre.ethers.getContractFactory("StakingPool");
const stakingPool = await StakingPool.deploy(nativeToken.address, nftMint.address);

await stakingPool.deployed();

console.log("StakingPool deployed to:", stakingPool.address);


}



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
