# Simple Payment Splitter (ETH)

Split incoming ETH among partners by shares (pull-based withdrawals).

## Deployed (Sepolia)
- **Contract:** `<0xDE8925FfA065274fB2B4809D3DdCa7cA87dfE608>`
- **Creation Tx:** `< 0x9a943b7e208d17075577a013f33edf6112fb0dc93698c4eaf7f5f3c81772ef94>`
- **Example Deposit Tx:** `<0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266>`
- **Release Tx (payee A):** `<0x9413cfd898e2fbd5b500ee8b303d822ac7031b55>`
- **Verified on Etherscan:** <Yes>

## Constructor
- `_payees`: `["0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266","0x9413cFD898E2FBd5b500eE8B303d822Ac7031B55"]`
- `_shares`: `[70,30]`

## How it works
1. Fund the contract via `deposit()` or plain `receive()`.
2. Each payee calls `release(address)` to withdraw their owed share.
3. Uses Checks-Effects-Interactions; pull payments (gas-efficient & safer).

## Try it in Remix
1. Compile (0.8.20+).
2. Deploy with your addresses & shares.
3. Fund using Remix Value (e.g., `0.05 ether`) → call `deposit()`.
4. Check `pendingPayment(addr)` → call `release(addr)`.

## Screenshots
Add 2–3 images in `/assets` (creation, deposit, release).
