// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Simple ETH Payment Splitter
/// @notice Send ETH to this contract; payees can withdraw their share on demand.
contract SimplePaymentSplitter {
    uint256 public totalShares;
    uint256 public totalReleased;

    mapping(address => uint256) public shares;   // payee => share units
    mapping(address => uint256) public released; // payee => ETH already withdrawn
    address[] public payees;

    event PayeeAdded(address account, uint256 shares);
    event PaymentReceived(address from, uint256 amount);
    event PaymentReleased(address to, uint256 amount);

    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        require(_payees.length == _shares.length && _payees.length > 0, "bad input");
        for (uint256 i; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    // Accept plain ETH transfers
    receive() external payable { emit PaymentReceived(msg.sender, msg.value); }
    function deposit() external payable { emit PaymentReceived(msg.sender, msg.value); }

    /// @notice How much this account can withdraw right now
    function pendingPayment(address account) public view returns (uint256) {
        uint256 totalReceived = address(this).balance + totalReleased;
        return (totalReceived * shares[account]) / totalShares - released[account];
    }

    /// @notice Withdraw the caller's (or any payee's) due amount
    function release(address payable account) public {
        uint256 payment = pendingPayment(account);
        require(payment != 0, "no payment due");
        // Effects
        released[account] += payment;
        totalReleased += payment;
        // Interaction (CEI pattern to prevent reentrancy issues)
        (bool ok, ) = account.call{value: payment}("");
        require(ok, "ETH transfer failed");
        emit PaymentReleased(account, payment);
    }

    function payee(uint256 index) external view returns (address) { return payees[index]; }

    function _addPayee(address account, uint256 _shares) internal {
        require(account != address(0), "zero address");
        require(_shares > 0, "shares are 0");
        require(shares[account] == 0, "payee exists");
        payees.push(account);
        shares[account] = _shares;
        totalShares += _shares;
        emit PayeeAdded(account, _shares);
    }
}
