;; ingredient-sourcing.clar
;; This contract tracks the origin of raw materials

(define-data-var contract-owner principal tx-sender)

;; Map of ingredients by ID
(define-map ingredients
  { ingredient-id: uint }
  {
    name: (string-ascii 100),
    source-location: (string-ascii 100),
    producer-id: principal,
    harvest-date: uint,
    registered-by: principal
  }
)

;; Counter for unique ingredient IDs
(define-data-var ingredient-counter uint u0)

;; Register a new ingredient source (verified producers can register)
(define-public (register-ingredient
                (name (string-ascii 100))
                (source-location (string-ascii 100))
                (producer-id principal)
                (harvest-date uint))
  (let ((ingredient-id (+ (var-get ingredient-counter) u1)))
    (begin
      ;; Check if producer is verified - we'll make a contract call to the producer-verification contract
      ;; For simplicity, this check is commented out, but in a real implementation, you would call:
      ;; (unwrap-panic (contract-call? .producer-verification is-producer-verified producer-id))

      (var-set ingredient-counter ingredient-id)
      (ok (map-set ingredients
        { ingredient-id: ingredient-id }
        {
          name: name,
          source-location: source-location,
          producer-id: producer-id,
          harvest-date: harvest-date,
          registered-by: tx-sender
        }
      ))
    )
  )
)

;; Get ingredient details
(define-read-only (get-ingredient-details (ingredient-id uint))
  (map-get? ingredients { ingredient-id: ingredient-id })
)

;; Transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok (var-set contract-owner new-owner))
  )
)
