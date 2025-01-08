;; Analysis Task Management Contract

(define-map analysis-tasks
  uint
  {
    creator: principal,
    dataset-id: uint,
    algorithm-id: uint,
    name: (string-ascii 100),
    description: (string-utf8 1000),
    status: (string-ascii 20),
    result-hash: (optional (buff 32)),
    timestamp: uint
  }
)

(define-data-var task-count uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_TASK (err u404))

(define-public (create-analysis-task (dataset-id uint) (algorithm-id uint) (name (string-ascii 100)) (description (string-utf8 1000)))
  (let
    (
      (task-id (+ (var-get task-count) u1))
    )
    (asserts! (is-some (contract-call? .cmb-data-management get-cmb-dataset dataset-id)) ERR_INVALID_TASK)
    (asserts! (is-some (contract-call? .quantum-inspired-algorithm-integration get-algorithm algorithm-id)) ERR_INVALID_TASK)
    (map-set analysis-tasks
      task-id
      {
        creator: tx-sender,
        dataset-id: dataset-id,
        algorithm-id: algorithm-id,
        name: name,
        description: description,
        status: "pending",
        result-hash: none,
        timestamp: block-height
      }
    )
    (var-set task-count task-id)
    (ok task-id)
  )
)

(define-public (update-task-status (task-id uint) (new-status (string-ascii 20)))
  (let
    (
      (task (unwrap! (map-get? analysis-tasks task-id) ERR_INVALID_TASK))
    )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get creator task))) ERR_NOT_AUTHORIZED)
    (ok (map-set analysis-tasks
      task-id
      (merge task { status: new-status })
    ))
  )
)

(define-public (set-task-result (task-id uint) (result-hash (buff 32)))
  (let
    (
      (task (unwrap! (map-get? analysis-tasks task-id) ERR_INVALID_TASK))
    )
    (asserts! (is-eq tx-sender (get creator task)) ERR_NOT_AUTHORIZED)
    (ok (map-set analysis-tasks
      task-id
      (merge task {
        status: "completed",
        result-hash: (some result-hash)
      })
    ))
  )
)

(define-read-only (get-analysis-task (task-id uint))
  (map-get? analysis-tasks task-id)
)

(define-read-only (get-task-count)
  (var-get task-count)
)

