
const contractAddress = "0x27E28AF6af81C0a47bFA3eBCEfCbADc245f0C441";


const abi = [
   
    "function contribute() external payable",
    "function extendDeadline(uint _extraDays) external",
    "function changeGoal(uint _newGoal) external",
    "function removeContributor(address _contributor) external",
    "function withdraw() external",
    "function togglePause() external",
    "function getBalance() external view returns (uint)",
    "function getContribution() external view returns (uint)",
    "function goal() external view returns (uint)",
    "function totalRaised() external view returns (uint)",
    "function getTimeLeft() external view returns (uint)",
    "function isGoalReached() external view returns (bool)",
];

let provider;
let signer;
let contract;

async function connectWallet() {
    if (window.ethereum) {
        provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        signer = provider.getSigner();
        contract = new ethers.Contract(contractAddress, abi, signer);
        alert("Wallet Connected");
    } else {
        alert("Please install MetaMask!");
    }
}

async function contribute() {
    const amount = document.getElementById("amount").value;
    if (!amount) return alert("Please enter an amount!");

    const tx = await contract.contribute({ value: ethers.utils.parseEther(amount) });
    await tx.wait();
    alert("Contribution successful!");
}

async function extendDeadline() {
    const extraDays = document.getElementById("extraDays").value;
    if (!extraDays) return alert("Please enter extra days!");

    const tx = await contract.extendDeadline(extraDays);
    await tx.wait();
    alert("Deadline extended!");
}

async function changeGoal() {
    const newGoal = document.getElementById("newGoal").value;
    if (!newGoal) return alert("Please enter new goal!");

    const tx = await contract.changeGoal(newGoal);
    await tx.wait();
    alert("Goal changed!");
}

async function removeContributor() {
    const address = document.getElementById("removeAddress").value;
    if (!address) return alert("Please enter an address!");

    const tx = await contract.removeContributor(address);
    await tx.wait();
    alert("Contributor removed!");
}

async function withdraw() {
    const tx = await contract.withdraw();
    await tx.wait();
    alert("Funds withdrawn!");
}

async function togglePause() {
    const tx = await contract.togglePause();
    await tx.wait();
    alert("Campaign paused/resumed!");
}

async function getDetails() {
    const balance = await contract.getBalance();
    const contribution = await contract.getContribution();
    const goal = await contract.goal();
    const totalRaised = await contract.totalRaised();
    const timeLeft = await contract.getTimeLeft();
    const goalReached = await contract.isGoalReached();

    document.getElementById("info").innerHTML = `
        <p><b>Balance:</b> ${ethers.utils.formatEther(balance)} ETH</p>
        <p><b>Your Contribution:</b> ${ethers.utils.formatEther(contribution)} ETH</p>
        <p><b>Goal:</b> ${ethers.utils.formatEther(goal)} ETH</p>
        <p><b>Total Raised:</b> ${ethers.utils.formatEther(totalRaised)} ETH</p>
        <p><b>Time Left:</b> ${timeLeft} seconds</p>
        <p><b>Goal Reached:</b> ${goalReached ? "Yes" : "No"}</p>
    `;
}
