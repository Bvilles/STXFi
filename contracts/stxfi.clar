;; STXFi - DeFi Lending Platform
;; A decentralized lending protocol built on Stacks

;; Constants
(define-constant contract-owner tx-sender)
(define-constant minimum-collateral-ratio u150) ;; 150% collateralization required
(define-constant liquidation-threshold u130) ;; Liquidation occurs below 130% collateral
(define-constant interest-rate-multiplier u100000) ;; For precision in interest calculations
(define-constant MAX-UINT u340282366920938463463374607431768211455) ;; Maximum uint value

;; Data Variables
(define-data-var total-deposits uint u0)
(define-data-var total-borrows uint u0)
(define-data-var last-interest-update uint block-height)

;; Data Maps
(define-map user-deposits principal uint)
(define-map user-borrows principal uint)
(define-map user-collateral principal uint)
(define-map interest-rates uint uint)

;; Error Codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-ARITHMETIC-OVERFLOW (err u104))

;; Helper Functions
(define-private (check-add (a uint) (b uint))
    (let ((sum (+ a b)))
        (if (< sum a)
            (err u104)
            (ok sum))))

;; Public Functions

;; Deposit STX into the lending pool
(define-public (deposit (amount uint))
    (let (
        (current-balance (stx-get-balance tx-sender))
        (current-deposits (default-to u0 (map-get? user-deposits tx-sender)))
    )
    (if (>= current-balance amount)
        (let ((new-deposit (try! (check-add current-deposits amount))))
            (begin
                (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
                (map-set user-deposits tx-sender new-deposit)
                (var-set total-deposits (+ (var-get total-deposits) amount))
                (ok amount)))
        ERR-INSUFFICIENT-FUNDS)))

;; Borrow STX from the lending pool
(define-public (borrow (amount uint))
    (let (
        (user-collateral-amount (default-to u0 (map-get? user-collateral tx-sender)))
        (current-borrows (default-to u0 (map-get? user-borrows tx-sender)))
        (collateral-value (* user-collateral-amount (get-collateral-price)))
        (new-borrow-amount (try! (check-add current-borrows amount)))
    )
    (if (is-collateral-sufficient? collateral-value new-borrow-amount)
        (begin
            (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
            (map-set user-borrows tx-sender new-borrow-amount)
            (var-set total-borrows (+ (var-get total-borrows) amount))
            (ok amount))
        ERR-INSUFFICIENT-COLLATERAL)))

;; Add collateral
(define-public (add-collateral (amount uint))
    (let (
        (current-collateral (default-to u0 (map-get? user-collateral tx-sender)))
        (new-collateral (try! (check-add current-collateral amount)))
    )
    (begin
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set user-collateral tx-sender new-collateral)
        (ok amount))))

;; Repay borrowed STX
(define-public (repay (amount uint))
    (let (
        (current-borrows (default-to u0 (map-get? user-borrows tx-sender)))
    )
    (if (> amount current-borrows)
        (let ((repay-amount current-borrows))
            (begin
                (try! (stx-transfer? repay-amount tx-sender (as-contract tx-sender)))
                (map-set user-borrows tx-sender u0)
                (var-set total-borrows (- (var-get total-borrows) repay-amount))
                (ok repay-amount)))
        (begin
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            (map-set user-borrows tx-sender (- current-borrows amount))
            (var-set total-borrows (- (var-get total-borrows) amount))
            (ok amount)))))

;; Liquidate under-collateralized position
(define-public (liquidate (borrower principal))
    (let (
        (collateral (default-to u0 (map-get? user-collateral borrower)))
        (debt (default-to u0 (map-get? user-borrows borrower)))
        (collateral-value (* collateral (get-collateral-price)))
    )
    (if (and 
            (> debt u0)
            (is-liquidatable? collateral-value debt))
        (begin
            (map-set user-collateral borrower u0)
            (map-set user-borrows borrower u0)
            (try! (as-contract (stx-transfer? collateral (as-contract tx-sender) tx-sender)))
            (ok true))
        (err u401))))

;; Read-only functions

;; Check if position is sufficiently collateralized
(define-read-only (is-collateral-sufficient? (collateral-value uint) (borrow-value uint))
    (if (is-eq borrow-value u0)
        true
        (>= (* collateral-value u100) (* borrow-value minimum-collateral-ratio))))

;; Check if position can be liquidated
(define-read-only (is-liquidatable? (collateral-value uint) (borrow-value uint))
    (if (is-eq borrow-value u0)
        false
        (< (* collateral-value u100) (* borrow-value liquidation-threshold))))

;; Get current collateral price (mock implementation)
(define-read-only (get-collateral-price)
    u1) ;; In a real implementation, this would fetch from an oracle

;; Get user's deposit balance
(define-read-only (get-user-deposits (user principal))
    (default-to u0 (map-get? user-deposits user)))

;; Get user's borrow balance
(define-read-only (get-user-borrows (user principal))
    (default-to u0 (map-get? user-borrows user)))

;; Get user's collateral balance
(define-read-only (get-user-collateral (user principal))
    (default-to u0 (map-get? user-collateral user)))