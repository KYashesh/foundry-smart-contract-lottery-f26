# 🎰 Provably Fair Smart Contract Lottery (Foundry)

A decentralized, tamper-proof raffle smart contract built using Solidity and the Foundry toolchain. This project implements cryptographically verifiable randomness via **Chainlink VRF (v2.5)** and automated autonomous execution via **Chainlink Automation**.

---

## 🛠️ Tech Stack 
- **Solidity** — Smart contract development
- **Foundry** — Compilation, deployment, and testing
- **Chainlink VRF** — Verifiable random number generation
- **Chainlink Automation** — Automated lottery execution
- **Ethereum / EVM** — Smart contract execution
- **Git & GitHub** — Version control

## 🎯 What Do We Want It To Do?

1. **Ticket Entry System**:
   - Users can enter the lottery by paying a fixed ticket fee (`entranceFee`).
   - All collected ticket fees pool into the contract prize balance to be awarded to the winner during the draw.
2. **Automated Winner Draw**:
   - After a configurable period ($X$ duration), the lottery automatically picks a winner programmatically without requiring manual initiation.
3. **Decentralized Infrastructure Integration**:
   - **Chainlink VRF**: Provides cryptographically provable, untamperable randomness for selecting a fair winner via the modulo operation.
   - **Chainlink Automation**: Acts as a decentralized cron job using `checkUpkeep` and `performUpkeep` to execute the draw when interval and state requirements are met.

---

## 📂 Project Structure 
```text 
foundry-smart-contract-lottery-f26/
├── src/ # Lottery smart contract
├── script/ # Deployment and interaction scripts
├── test/ # Unit and integration tests
├── lib/ # Dependencies
├── foundry.toml # Foundry configuration
└── README.md # Project documentation
```

## ⚙️ Configuration & Changes You Must Make

When cloning, running, or modifying this repository, update the following configurations:

1. **Environment Variables (`.env`)**:
   - Create a `.env` file in the root directory:
     ```bash
     SEPOLIA_RPC_URL=<YOUR_SEPOLIA_RPC_URL>
     MAINNET_RPC_URL=<YOUR_MAINNET_RPC_URL>
     PRIVATE_KEY=<YOUR_PRIVATE_KEY_OR_KEYSTORE_ACCOUNT>
     ETHERSCAN_API_KEY=<YOUR_ETHERSCAN_API_KEY>
     ```

2. **Raffle Parameters (`HelperConfig.s.sol` / `DeployRaffle.s.sol`)**:
   - **`entranceFee`**: Set your desired entry cost (e.g., `0.01 ether`).
   - **`interval`**: Configure the duration of each raffle round in seconds (e.g., `30` for rapid local testing, `86400` for 24 hours).

3. **Chainlink VRF Settings**:
   - **`subscriptionId`**: If deploying to a live network (Sepolia/Mainnet), create a subscription on [vrf.chain.link](https://vrf.chain.link) and update this field in your configuration.
   - **`gasLane` (`keyHash`)**: Set the maximum gas price ceiling key hash appropriate for your target chain.
   - **`callbackGasLimit`**: Modify if your `fulfillRandomWords` callback logic requires additional compute gas.

4. **Subscription Funding & Consumer Authorization**:
   - Add the deployed `Raffle` contract address as an approved consumer on your Chainlink VRF dashboard or execute the automated script:
     ```bash
     forge script script/Interactions.s.sol:AddConsumer --rpc-url <RPC_URL> --broadcast
     ```
   - Fund your subscription balance with testnet LINK tokens.

5. **Chainlink Automation Registration**:
   - Register a new custom-logic upkeep pointing to your deployed `Raffle` contract on [automation.chain.link](https://automation.chain.link).

---

## 🧪 Testing Suite & Environments

This project includes multi-layer unit, integration, and fuzz testing across different chain environments:

- **Local Chain (Anvil)**:
  - Uses `HelperConfig.s.sol` to automatically deploy mocks (`VRFCoordinatorV2_5Mock`, `LinkToken`).
  - Simulates VRF requests and callbacks programmatically.
- **Forked Testnet (Sepolia)**:
  - Validates interaction with real or pre-configured Chainlink infrastructure.
- **Forked Mainnet**:
  - Tests against real-world state and network gas conditions.
- **zkSync Note**: Standard EVM deployment and cheatcode scripts in this repository are designed for EVM/Foundry architectures and will **not** work directly on zkSync without using `foundry-zksync` plugins and compiler modifications.

### Running Tests

```bash
# Run all unit and state tests locally (Anvil + Mocks)
forge test

# Run tests with detailed stack traces
forge test -vvvv

# Run forked tests (Sepolia)
forge test --fork-url $SEPOLIA_RPC_URL

# Run forked tests (Mainnet)
forge test --fork-url $MAINNET_RPC_URL

# Run test coverage
forge coverage
