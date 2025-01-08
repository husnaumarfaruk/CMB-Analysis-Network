;; CMB Data Management Contract

(define-data-var dataset-count uint u0)

(define-map cmb-datasets
  uint
  {
    uploader: principal,
    name: (string-ascii 100),
    description: (string-utf8 1000),
    data-hash: (buff 32),
    resolution: uint,
    timestamp: uint,
    status: (string-ascii 20)
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_DATASET (err u404))

(define-public (upload-cmb-dataset (name (string-ascii 100)) (description (string-utf8 1000)) (data-hash (buff 32)) (resolution uint))
  (let
    (
      (dataset-id (+ (var-get dataset-count) u1))
    )
    (map-set cmb-datasets
      dataset-id
      {
        uploader: tx-sender,
        name: name,
        description: description,
        data-hash: data-hash,
        resolution: resolution,
        timestamp: block-height,
        status: "active"
      }
    )
    (var-set dataset-count dataset-id)
    (ok dataset-id)
  )
)

(define-public (update-dataset-status (dataset-id uint) (new-status (string-ascii 20)))
  (let
    (
      (dataset (unwrap! (map-get? cmb-datasets dataset-id) ERR_INVALID_DATASET))
    )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get uploader dataset))) ERR_NOT_AUTHORIZED)
    (ok (map-set cmb-datasets
      dataset-id
      (merge dataset { status: new-status })
    ))
  )
)

(define-read-only (get-cmb-dataset (dataset-id uint))
  (map-get? cmb-datasets dataset-id)
)

(define-read-only (get-dataset-count)
  (var-get dataset-count)
)

