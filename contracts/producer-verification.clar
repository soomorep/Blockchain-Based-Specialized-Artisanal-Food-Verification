;; producer-verification.clar
;; This contract validates legitimate small-scale food producers

(define-data-var contract-owner principal tx-sender)

;; Map of producer principals to their verified status
(define-map producers
  { producer-id: principal }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    verified: bool,
    registration-date: uint
  }
)

;; Register a new producer (only contract owner can register)
(define-public (register-producer (producer-id principal) (name (string-ascii 100)) (location (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (asserts! (is-none (map-get? producers { producer-id: producer-id })) (err u2))
    (ok (map-set producers
      { producer-id: producer-id }
      {
        name: name,
        location: location,
        verified: false,
        registration-date: block-height
      }
    ))
  )
)

;; Verify a producer (only contract owner can verify)
(define-public (verify-producer (producer-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (match (map-get? producers { producer-id: producer-id })
      producer-data (ok (map-set producers
                          { producer-id: producer-id }
                          (merge producer-data { verified: true })
                        ))
      (err u3)
    )
  )
)

;; Check if a producer is verified
(define-read-only (is-producer-verified (producer-id principal))
  (match (map-get? producers { producer-id: producer-id })
    producer-data (ok (get verified producer-data))
    (err u4)
  )
)

;; Get producer details
(define-read-only (get-producer-details (producer-id principal))
  (map-get? producers { producer-id: producer-id })
)

;; Transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok (var-set contract-owner new-owner))
  )
)
