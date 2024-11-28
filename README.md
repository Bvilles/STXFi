# STXFi - Decentralized Lending Platform

STXFi is a decentralized lending protocol built on the Stacks blockchain that enables users to lend and borrow STX tokens in a secure, transparent, and efficient manner.

## Features

- Deposit STX tokens to earn interest
- Borrow STX tokens using over-collateralization
- Dynamic interest rate model based on supply and demand
- Automated liquidation system for under-collateralized positions
- Real-time monitoring of collateral ratios
- Secure smart contract implementation in Clarity

## Technical Overview

### Smart Contract Architecture

The protocol consists of the following key components:

1. **Deposit System**
   - Users can deposit STX tokens into the lending pool
   - Deposits are tracked using data maps
   - Interest accrual based on utilization rate

2. **Borrowing System**
   - Over-collateralization required for all loans
   - Minimum collateral ratio: 150%
   - Dynamic interest rates based on pool utilization

3. **Liquidation Mechanism**
   - Automatic liquidation below 130% collateral ratio
   - Liquidation incentives for maintainers
   - Protection against flash loan attacks

### Key Parameters

- Minimum Collateral Ratio: 150%
- Liquidation Threshold: 130%
- Interest Rate Model: Dynamic based on utilization
- Protocol Fee: 0.1% of interest

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/stxfi.git
cd stxfi
```

2. Install dependencies:
```bash
clarinet install
```

## Development

To run tests:
```bash
clarinet test
```

To deploy locally:
```bash
clarinet console
```

## Usage

### Depositing STX

```clarity
(contract-call? .stxfi deposit u1000000)
```

### Borrowing STX

```clarity
(contract-call? .stxfi borrow u500000)
```

### Adding Collateral

```clarity
(contract-call? .stxfi add-collateral u1500000)
```

### Repaying Loan

```clarity
(contract-call? .stxfi repay u500000)
```

## Security

The smart contract implements several security measures:

- Checks for overflow/underflow
- Reentrancy protection
- Access control mechanisms
- Emergency pause functionality

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
