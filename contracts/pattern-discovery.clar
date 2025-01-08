;; Pattern Discovery Contract

(define-map cmb-patterns
  uint
  {
    discoverer: principal,
    task-id: uint,
    name: (string-ascii 100),
    description: (string-utf8 1000),
    pattern-hash: (buff 32),
    significance: uint,
    timestamp: uint,
    status: (string-ascii 20)
  }
)

(define-data-var pattern-count uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_PATTERN (err u404))

(define-public (register-cmb-pattern (task-id uint) (name (string-ascii 100)) (description (string-utf8 1000)) (pattern-hash (buff 32)) (significance uint))
  (let
    (
      (pattern-id (+ (var-get pattern-count) u1))
    )
    (asserts! (is-some (contract-call? .analysis-task-management get-analysis-task task-id)) ERR_INVALID_PATTERN)
    (map-set cmb-patterns
      pattern-id
      {
        discoverer: tx-sender,
        task-id: task-id,
        name: name,
        description: description,
        pattern-hash: pattern-hash,
        significance: significance,
        timestamp: block-height,
        status: "unverified"
      }
    )
    (var-set pattern-count pattern-id)
    (ok pattern-id)
  )
)

(define-public (verify-pattern (pattern-id uint))
  (let
    (
      (pattern (unwrap! (map-get? cmb-patterns pattern-id) ERR_INVALID_PATTERN))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set cmb-patterns
      pattern-id
      (merge pattern { status: "verified" })
    ))
  )
)

(define-read-only (get-cmb-pattern (pattern-id uint))
  (map-get? cmb-patterns pattern-id)
)

(define-read-only (get-pattern-count)
  (var-get pattern-count)
)

