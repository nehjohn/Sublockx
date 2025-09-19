;; ---------------------------------------------
;; Contract: SubLockX
;; Tokenized Subscription Access
;; ---------------------------------------------

;; -----------------------
;; Errors
;; -----------------------
(define-constant ERR-NOT-SUBSCRIBER (err u100))
(define-constant ERR-NOT-OWNER (err u101))
(define-constant ERR-PAYMENT-FAILED (err u102))
(define-constant ERR-NOT-ACTIVE (err u103))

;; -----------------------
;; Constants & Variables
;; -----------------------
(define-constant contract-owner tx-sender)

;; Default subscription price (in microstx)
(define-data-var subscription-price-ustx uint u1000000) ;; 1 STX

;; Subscription duration in blocks
(define-data-var subscription-duration uint u144) ;; ~1 day (144 blocks)

;; Track subscriptions
(define-map subscriptions
  { user: principal }
  { expiry: uint }) ;; block height of expiration

;; -----------------------
;; Functions
;; -----------------------

;; (1) Update subscription price (only owner)
(define-public (set-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
    (var-set subscription-price-ustx new-price)
    (ok new-price)
  )
)

;; (2) Update duration (only owner)
(define-public (set-duration (new-duration uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR-NOT-OWNER)
    (var-set subscription-duration new-duration)
    (ok new-duration)
  )
)

;; (3) Subscribe or renew subscription
(define-public (subscribe)
  (let
    (
      (price (var-get subscription-price-ustx))
      (duration (var-get subscription-duration))
      (existing (map-get? subscriptions { user: tx-sender }))
    )
    (begin
      ;; Transfer subscription fee to contract owner
      (try! (stx-transfer? price tx-sender contract-owner))

      ;; Determine expiry
      (if (is-some existing)
          ;; extend subscription if still active
          (let ((expiry (get expiry (unwrap-panic existing))))
            (if (> expiry stacks-block-height)
                (map-set subscriptions { user: tx-sender }
                         { expiry: (+ expiry duration) })
                (map-set subscriptions { user: tx-sender }
                         { expiry: (+ stacks-block-height duration) })
            )
          )
          ;; New subscription
          (map-set subscriptions { user: tx-sender }
                   { expiry: (+ stacks-block-height duration) })
      )
      (ok "Subscription active")
    )
  )
)

;; (4) Check if user is subscribed
(define-read-only (is-subscribed (user principal))
  (let ((existing (map-get? subscriptions { user: user })))
    (if (is-some existing)
        (>= (get expiry (unwrap-panic existing)) stacks-block-height)
        false
    )
  )
)

;; (5) Get subscription expiry
(define-read-only (get-expiry (user principal))
  (let ((subscription (map-get? subscriptions { user: user })))
    (if (is-some subscription)
        (ok (get expiry (unwrap-panic subscription)))
        (err u104) ;; Error: User not subscribed
    )
  )
)
