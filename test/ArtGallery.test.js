const { expect } = require("chai");
const signers = {};

let contractFactory;
let contractInstance;

describe("Testing on ArtGallery Contract", function () {

    it("Should deploy the smart contract", async function () {

        const [deployer, firstUser, secondUser] = await ethers.getSigners();
        signers.deployer = deployer;
        signers.firstUser = firstUser;
        signers.secondUser = secondUser;

        contractFactory = await ethers.getContractFactory("ArtGallery");
        contractInstance = await contractFactory.deploy("MalbaArt", "MLB");
        await contractInstance.deployed();

    })


    it(`Should not allow to MINT if its not the owner`, async function () {
        const contractInstanceFirstUser = await contractInstance.connect(signers.firstUser)
        const Minting = contractInstanceFirstUser._publishNFTGallery('https:www/fdsafds.com', 4, 500);
        await expect(Minting).to.be.revertedWith('Ownable: caller is not the owner')
    })

    it(`Should Mint an NFT - Gallery is the owner`, async function () {
        const Minting = await contractInstance._publishNFTGallery('https:www/fdsafds.com', 4, 500);
        const NFTAdress = contractInstance.NFTContractTokenInstance();
        const NFTContractFactory = await ethers.getContractFactory("NFTContract", signers.deployer);
        const NFTInstance = NFTContractFactory.attach(NFTAdress)
        const NFTOwner = await NFTInstance.ownerOf(0)
        expect(NFTOwner).to.equal(contractInstance.address)
    })

    it(`Should Mint an NFT for another address`, async function () {
        const newAddress = signers.firstUser.address
        const Minting = await contractInstance._publishNFT('https:www/fdsafds.com', 5, newAddress, 500);
        const NFTAdress = contractInstance.NFTContractTokenInstance();
        const NFTContractFactory = await ethers.getContractFactory("NFTContract", signers.deployer);
        const NFTInstance = NFTContractFactory.attach(NFTAdress)
        const NFTOwner = await NFTInstance.ownerOf(1)
        expect(NFTOwner).to.equal(newAddress)
    })

    describe('Tests on Price Setting', function () {

        it('Should not allow to Set Price if Setter is not the owner', async function () {
            const contractInstanceFirstUser = await contractInstance.connect(signers.firstUser)
            const setingPrice = contractInstanceFirstUser._setPrice(1, 3)
            await expect(setingPrice).to.be.revertedWith('Ownable: caller is not the owner')
        })

        it('Owner Could Set/Get Price', async function () {
            const setingPrice = await contractInstance._setPrice(1, 3)
            const getPrice = await contractInstance._getPrice(1)
            expect(getPrice).to.equal(3)
        })
    })

    describe('Test Getting ETH Balance of Contract', function () {

        it('Should not allow to get ETH Balance of Contract if is not the owner', async function () {
            const contractInstanceFirstUser = await contractInstance.connect(signers.firstUser)
            const getETHBalance = contractInstanceFirstUser._ethContractBalance()
            await expect(getETHBalance).to.be.revertedWith('Ownable: caller is not the owner')
        })

        it('Should return ETH Balance of Contract', async function () {
            const getETHBalance = await contractInstance._ethContractBalance()
            const ETHBalance = await ethers.provider.getBalance(contractInstance.address);
            expect(getETHBalance).to.equal(ETHBalance)
        })

    })

    describe('Test Getting NFT Balance', function () {

        it('Should return NFTs Quantity owned by the CONTRACT', async function () {
            const newGalleryMint = contractInstance._publishNFTGallery('https:www/fdsafds.com2', 3, 8000);
            const NFTAdress = contractInstance.NFTContractTokenInstance();
            const NFTContractFactory = await ethers.getContractFactory("NFTContract", signers.deployer);
            const NFTInstance = NFTContractFactory.attach(NFTAdress)
            const contractNFTs = await await NFTInstance.balanceOf(contractInstance.address)
            expect(contractNFTs).to.equal(2)
        })

        
        it('Should return NFTs Quantity owned by the OTHER ADDRESS', async function () {
            const newAddress = signers.firstUser.address
            const newMintOtherAddress = await contractInstance._publishNFT('https:www/fdsafds.com', 5, newAddress, 500);
            const NFTAdress = contractInstance.NFTContractTokenInstance();
            const NFTContractFactory = await ethers.getContractFactory("NFTContract", signers.deployer);
            const NFTInstance = NFTContractFactory.attach(NFTAdress)
            const userNFTs = await NFTInstance.balanceOf(signers.firstUser.address)
            expect(userNFTs).to.equal(2)
        })

    })


    describe('Test on Withdrawing', function () {

        it('Should not allow to Withdrwau ETH Balance if is not the owner', async function () {
            const contractInstanceFirstUser = await contractInstance.connect(signers.firstUser)
            const WithdrawBalance = contractInstanceFirstUser.withdraw()
            await expect(WithdrawBalance).to.be.revertedWith('Ownable: caller is not the owner')
        })

    })

    


    describe('Test on Selling/Buying', function () {

        it('Should not allow to sell if ETH sends are incorrect', async function () {
            const contractInstanceFirstUser = await contractInstance.connect(signers.firstUser)
            const Buying = contractInstanceFirstUser._BuyNFT(1, {
                value: ethers.utils.parseEther("2.0") / (10 ** 18)
            })
            await expect(Buying).to.be.revertedWith('You didnt send the correct NFT Price')
        })

        it('Should transfer NFT to a new address', async function () {
        
            const price = await contractInstance._getPrice(1)
            console.log('Precio: ' + price)

            const NFTAdress = contractInstance.NFTContractTokenInstance();
            const NFTContractFactory = await ethers.getContractFactory("NFTContract", signers.deployer);
            const NFTInstance = NFTContractFactory.attach(NFTAdress)

            const actualOwner = await NFTInstance.ownerOf(1)
            console.log('Actual Owner: ' + actualOwner)
            console.log('Buyer: ' + signers.secondUser.address)

            const contractInstanceSecondUser = await contractInstance.connect(signers.secondUser)
            const Buying = await contractInstanceSecondUser._BuyNFT('1', {
                value: ethers.utils.parseEther("3.0") / (10 ** 18)
            })
        
            const newOwner = await NFTInstance.ownerOf(1)
            console.log("New Owner: "+ newOwner)
        
        })

    })
        

})


