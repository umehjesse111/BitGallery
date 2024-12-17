;; BitGallery - NFT Marketplace Smart Contract
;; Allows users to mint, list, buy, and trade NFTs using Bitcoin

;; Define SIP-009 NFT Trait
(define-trait nft-trait
    (
        ;; Last token ID, limited to uint range
        (get-last-token-id () (response uint uint))
        
        ;; URI for metadata associated with the token
        (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
        
        ;; Owner of a given token identifier
        (get-owner (uint) (response (optional principal) uint))
        
        ;; Transfer from the sender to a new principal
        (transfer (uint principal principal) (response bool uint))
    )
)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant listing-enabled true)
(define-constant err-not-owner (err u100))
(define-constant err-not-listed (err u101))
(define-constant err-wrong-price (err u102))
(define-constant err-listing-disabled (err u103))
(define-constant err-owner-not-found (err u104))
(define-constant err-invalid-nft-contract (err u105))
(define-constant err-invalid-token-id (err u106))
(define-constant err-invalid-price (err u107))

;; Data Variables
(define-data-var platform-fee uint u25) ;; 2.5% fee
(define-map listings
    { nft-id: principal, token-id: uint }
    { price: uint, seller: principal }
)

;; Helper function to check if a contract implements the NFT trait
(define-private (is-valid-nft-contract (nft-contract <nft-trait>))
    (is-ok (contract-call? nft-contract get-last-token-id))
)

;; NFT Listing
(define-public (list-nft (nft-contract <nft-trait>) (token-id uint) (price uint))
    (let
        (
            (owner-response (try! (contract-call? nft-contract get-owner token-id)))
            (owner (unwrap! owner-response err-owner-not-found))
        )
        (asserts! (is-valid-nft-contract nft-contract) err-invalid-nft-contract)
        (asserts! (> token-id u0) err-invalid-token-id)
        (asserts! (> price u0) err-invalid-price)
        (asserts! (is-eq tx-sender owner) err-not-owner)
        (asserts! listing-enabled err-listing-disabled)
        (try! (contract-call? nft-contract transfer token-id tx-sender (as-contract tx-sender)))
        (map-set listings { nft-id: (contract-of nft-contract), token-id: token-id }
                         { price: price, seller: tx-sender })
        (ok true)
    )
)

;; NFT Purchase
(define-public (buy-nft (nft-contract <nft-trait>) (token-id uint) (price uint))
    (let
        (
            (listing (unwrap! (map-get? listings { nft-id: (contract-of nft-contract), token-id: token-id })
                             err-not-listed))
            (seller (get seller listing))
            (listing-price (get price listing))
            (fee (/ (* price (var-get platform-fee)) u1000))
        )
        (asserts! (is-valid-nft-contract nft-contract) err-invalid-nft-contract)
        (asserts! (> token-id u0) err-invalid-token-id)
        (asserts! (> price u0) err-invalid-price)
        (asserts! (is-eq price listing-price) err-wrong-price)
        ;; Transfer STX payment
        (try! (stx-transfer? price tx-sender seller))
        ;; Transfer platform fee
        (try! (stx-transfer? fee tx-sender contract-owner))
        ;; Transfer NFT
        (try! (as-contract (contract-call? nft-contract transfer token-id tx-sender seller)))
        ;; Clear listing
        (map-delete listings { nft-id: (contract-of nft-contract), token-id: token-id })
        (ok true)
    )
)

;; Cancel Listing
(define-public (cancel-listing (nft-contract <nft-trait>) (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? listings { nft-id: (contract-of nft-contract), token-id: token-id })
                             err-not-listed))
            (seller (get seller listing))
        )
        (asserts! (is-valid-nft-contract nft-contract) err-invalid-nft-contract)
        (asserts! (> token-id u0) err-invalid-token-id)
        (asserts! (is-eq tx-sender seller) err-not-owner)
        (try! (as-contract (contract-call? nft-contract transfer token-id tx-sender seller)))
        (map-delete listings { nft-id: (contract-of nft-contract), token-id: token-id })
        (ok true)
    )
)

;; Getter Functions
(define-read-only (get-listing (nft-contract principal) (token-id uint))
    (map-get? listings { nft-id: nft-contract, token-id: token-id })
)

(define-read-only (get-platform-fee)
    (ok (var-get platform-fee))
)

;; Admin Functions
(define-public (set-platform-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (asserts! (<= new-fee u1000) err-invalid-price) ;; Ensure fee is not more than 100%
        (var-set platform-fee new-fee)
        (ok true)
    )
)