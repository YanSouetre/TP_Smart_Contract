const hre = require("hardhat");

async function main() {
    //Get the contract
    const Voting = await hre.ethers.getContractFactory("Voting");

    //Deploy the contract
    const voting = await Voting.deploy();
    await voting.waitForDeployment();

    //Get the address of the deployed contract
    const contractAddress = await voting.getAddress();
    console.log(`Voting contract deployed to: ${contractAddress}`);
}

//Execute the contract deployment
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
