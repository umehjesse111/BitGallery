# BitGallery

BitGallery is a decentralized NFT marketplace built on the Stacks blockchain, enabling seamless NFT trading with Bitcoin integration.

## Features

- Mint and trade NFTs using Stacks blockchain
- Bitcoin-based payments for NFTs
- Royalty system for creators
- Auction functionality
- Social features including creator following and artwork commenting
- Secure smart contract implementation

## Smart Contract Overview

The BitGallery smart contract provides core functionality for:

- Listing NFTs for sale
- Purchasing NFTs
- Managing listings
- Handling platform fees
- Implementing security measures

### Key Functions

1. `list-nft`: Allow users to list their NFTs for sale
2. `buy-nft`: Enable NFT purchases with automatic fee handling
3. `cancel-listing`: Permit sellers to remove their listings
4. `get-listing`: Retrieve listing information
5. `get-platform-fee`: Check current platform fee
6. `set-platform-fee`: Admin function to update platform fee

## Technical Requirements

- Clarity CLI
- Stacks blockchain access
- Node.js environment
- Web3 wallet (Hiro or similar)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bit-gallery.git
cd bit-gallery
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment:
```bash
cp .env.example .env
# Edit .env with your configuration
```

## Development

1. Start local Stacks blockchain:
```bash
stacks-node start
```

2. Deploy contract:
```bash
clarinet contract deploy
```

3. Run tests:
```bash
clarinet test
```

## Security

- Contract implements ownership checks
- Transfer validations
- Fee management
- Listing state management

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request