# BitGallery - Decentralized NFT Marketplace

BitGallery is a comprehensive NFT marketplace smart contract built on the Stacks blockchain, enabling secure and flexible NFT trading with advanced auction and listing capabilities.

## Features

- Fixed Price Listings
- Dynamic Auction Mechanism
- Platform Fee Management
- SIP-009 NFT Standard Compatibility
- Secure NFT Transfer and Trading
- Flexible Auction Configuration

## Smart Contract Capabilities

### Listing Functions
- `list-nft`: List an NFT for a fixed price
- `buy-nft`: Purchase an NFT at the listed price
- `cancel-listing`: Remove an NFT from sale

### Auction Functions
- `start-auction`: Create a new auction with configurable parameters
  - Custom start price
  - Minimum bid increment
  - Auction duration
- `end-auction`: Conclude an auction, transferring NFT and funds

### Admin Functions
- `set-platform-fee`: Adjust marketplace commission (max 10%)

## Marketplace Parameters

- **Platform Fee**: Configurable, default 2.5% of sale price
- **Token Support**: Compatible with SIP-009 NFT contracts
- **Minimum Token ID**: Greater than 0
- **Price Validation**: Prevents zero-value listings/bids

## Error Handling

The contract includes comprehensive error management with specific error codes:
- Ownership verification
- Listing state checks
- Price validation
- Auction mechanism constraints

## Technical Requirements

- Stacks Blockchain
- Clarity Smart Contract Language
- SIP-009 Compatible NFT Contracts

## Security Measures

- Owner-only administrative functions
- Pre-transaction validation
- Secure asset transfers
- Explicit error reporting

## Auction Mechanics

1. NFT owner starts an auction
2. Bidders place incrementing bids
3. Auction concludes automatically
4. Highest bidder receives NFT
5. Seller receives funds minus platform fee

## Usage Example

```clarity
;; List an NFT
(list-nft nft-contract token-id price)

;; Start an auction
(start-auction 
    nft-contract 
    token-id 
    start-price 
    min-increment 
    auction-duration
)
```

## Contributing

Contributions welcome! Please review contract implementation and submit pull requests with improvements or bug fixes.
