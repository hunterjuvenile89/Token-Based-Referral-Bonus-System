(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-REGISTERED (err u102))
(define-constant ERR-INVALID-REFERRAL (err u103))
(define-constant ERR-ALREADY-CONFIRMED (err u104))
(define-constant ERR-INSUFFICIENT-BALANCE (err u105))
(define-constant ERR-INVALID-AMOUNT (err u106))
(define-constant ERR-REFERRAL-NOT-FOUND (err u107))

(define-constant REFERRAL-REWARD u1000000)
(define-constant CONFIRMATION-BLOCKS u144)

(define-data-var contract-balance uint u0)
(define-data-var next-referral-id uint u1)

(define-map users 
  principal 
  {
    registered: bool,
    referrer: (optional principal),
    total-rewards: uint,
    referral-count: uint
  }
)

(define-map referrals
  uint
  {
    referrer: principal,
    referred: principal,
    created-at: uint,
    confirmed: bool,
    reward-claimed: bool
  }
)

(define-map user-referrals principal (list 100 uint))

(define-public (register (referrer (optional principal)))
  (let (
    (sender tx-sender)
    (existing-user (map-get? users sender))
  )
    (asserts! (is-none existing-user) ERR-ALREADY-REGISTERED)
    (match referrer
      ref-principal 
        (begin
          (asserts! (is-some (map-get? users ref-principal)) ERR-NOT-REGISTERED)
          (asserts! (not (is-eq ref-principal sender)) ERR-INVALID-REFERRAL)
          (map-set users sender {
            registered: true,
            referrer: (some ref-principal),
            total-rewards: u0,
            referral-count: u0
          })
          (try! (create-referral ref-principal sender))
          (ok true)
        )
      (begin
        (map-set users sender {
          registered: true,
          referrer: none,
          total-rewards: u0,
          referral-count: u0
        })
        (ok true)
      )
    )
  )
)

(define-private (create-referral (referrer principal) (referred principal))
  (let (
    (referral-id (var-get next-referral-id))
    (current-block stacks-block-height)
  )
    (map-set referrals referral-id {
      referrer: referrer,
      referred: referred,
      created-at: current-block,
      confirmed: false,
      reward-claimed: false
    })
    (var-set next-referral-id (+ referral-id u1))
    (let (
      (current-referrals (default-to (list) (map-get? user-referrals referrer)))
    )
      (map-set user-referrals referrer (unwrap! (as-max-len? (append current-referrals referral-id) u100) ERR-INVALID-REFERRAL))
    )
    (ok referral-id)
  )
)

(define-public (confirm-referral (referral-id uint))
  (let (
    (referral (unwrap! (map-get? referrals referral-id) ERR-REFERRAL-NOT-FOUND))
    (current-block stacks-block-height)
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (not (get confirmed referral)) ERR-ALREADY-CONFIRMED)
    (asserts! (>= current-block (+ (get created-at referral) CONFIRMATION-BLOCKS)) ERR-INVALID-REFERRAL)
    
    (map-set referrals referral-id (merge referral { confirmed: true }))
    
    (let (
      (referrer (get referrer referral))
      (referrer-data (unwrap! (map-get? users referrer) ERR-NOT-REGISTERED))
    )
      (map-set users referrer (merge referrer-data {
        referral-count: (+ (get referral-count referrer-data) u1)
      }))
    )
    (ok true)
  )
)

(define-public (claim-reward (referral-id uint))
  (let (
    (referral (unwrap! (map-get? referrals referral-id) ERR-REFERRAL-NOT-FOUND))
    (referrer (get referrer referral))
  )
    (asserts! (is-eq tx-sender referrer) ERR-UNAUTHORIZED)
    (asserts! (get confirmed referral) ERR-INVALID-REFERRAL)
    (asserts! (not (get reward-claimed referral)) ERR-ALREADY-CONFIRMED)
    (asserts! (>= (var-get contract-balance) REFERRAL-REWARD) ERR-INSUFFICIENT-BALANCE)
    
    (try! (stx-transfer? REFERRAL-REWARD (as-contract tx-sender) referrer))
    (var-set contract-balance (- (var-get contract-balance) REFERRAL-REWARD))
    
    (map-set referrals referral-id (merge referral { reward-claimed: true }))
    
    (let (
      (referrer-data (unwrap! (map-get? users referrer) ERR-NOT-REGISTERED))
    )
      (map-set users referrer (merge referrer-data {
        total-rewards: (+ (get total-rewards referrer-data) REFERRAL-REWARD)
      }))
    )
    (ok true)
  )
)

(define-public (fund-contract)
  (let (
    (amount (stx-get-balance tx-sender))
  )
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set contract-balance (+ (var-get contract-balance) amount))
    (ok amount)
  )
)

(define-public (withdraw-funds (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (>= (var-get contract-balance) amount) ERR-INSUFFICIENT-BALANCE)
    (try! (stx-transfer? amount (as-contract tx-sender) CONTRACT-OWNER))
    (var-set contract-balance (- (var-get contract-balance) amount))
    (ok true)
  )
)

(define-read-only (get-user-info (user principal))
  (map-get? users user)
)

(define-read-only (get-referral-info (referral-id uint))
  (map-get? referrals referral-id)
)

(define-read-only (get-user-referrals (user principal))
  (map-get? user-referrals user)
)

(define-read-only (get-contract-balance)
  (var-get contract-balance)
)

(define-read-only (get-reward-amount)
  REFERRAL-REWARD
)

(define-read-only (get-confirmation-blocks)
  CONFIRMATION-BLOCKS
)
