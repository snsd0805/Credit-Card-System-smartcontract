# Crypto-Credit-System(Smart Contract)

It's final project for 1112 NCNU CSIE "Principles and Practice of Blockchains"

We have implemented a Crypto Credit Card System consisting of two smart contracts: Soulbound Token and Bank.

## What we did

We have implemented a simple Soulbound Token (SBT), which is non-transferable. The SBT logs all credit-related activities, including borrowing, repaying, and warning events.

After minting your own SBT, you can register with any bank that trusts this SBT. Each bank can access the client's credit information to establish a credit limit. The registered client can then call the bank's pay() function to request the bank to make payments to the shop on their behalf. The client will repay the bank once they are able to cover the outstanding balance.

Additionally, we have implemented a web interface for interacting with this repository. You can find the web interface repository [here]().

## Deploy (localhost)
1. Open Ganache on your localhost
2. Install the project dependencies:
    ```
    npm install
    ```

3. clone this repo
    ```
    git clone $THIS_REPO_LINK
    ```
4. Open the Truffle console
    ```
    cd Credit-Card-System-smartcontract
    truffle console
    ```
5. Deploy the contracts in the Truffle console:
    ```
    truffle(development)> deploy    
    ```
6. Once the contracts are deployed, you can set up and interact with the web interface repository [here]().
