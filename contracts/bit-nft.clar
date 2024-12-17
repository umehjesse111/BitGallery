;; BitGallery - NFT Marketplace Smart Contract
;; Allows users to mint, list, buy, and trade NFTs using Bitcoin

(use-trait nft-trait .sip-009.nft-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant listing-enabled true)
(define-constant err-not-owner (err u100))
(define-constant err-not-listed (err u101))
(define-constant err-wrong-price (err u102))
(define-constant err-listing-disabled (err u103))

;; Data Variables
(define-data-var platform-fee uint u25) ;; 2.5% fee
(define-map listings
    { nft-id: uint, token-id: uint }
    { price: uint, seller: principal }
)

;; NFT Listing
(define-public (list-nft (nft-contract <nft-trait>) (token-id uint) (price uint))
    (let
        (
            (owner (unwrap! (contract-call? nft-contract get-owner token-id) err-not-owner))
        )
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
        (var-set platform-fee new-fee)
        (ok true)
    )
)