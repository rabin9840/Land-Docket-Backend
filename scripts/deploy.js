const hre=require('hardhat');
const main= async()=> {
  const LandRegistration= await hre.ethers.getContractFactory("LandRegistration");
  const landregistrations=await LandRegistration.deploy();
  await landregistrations.deployed();

  console.log(
    "Transactions deployed to: ",landregistrations.address
  );
}

const runMain= async()=>{
  try {
    await main();
    process.exit(0);

    
  } catch (error) {
    console.log(error);
    process.exit(0);

    
  }
}

runMain();
