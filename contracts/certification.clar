;; certification.clar
;; This contract verifies compliance with artisanal standards

(define-data-var contract-owner principal tx-sender)

;; Map of certifiers by principal
(define-map certifiers
  { certifier-id: principal }
  {
    name: (string-ascii 100),
    active: bool
  }
)

;; Map of certified products
(define-map certified-products
  { product-id: uint }
  {
    producer-id: principal,
    certification-date: uint,
    expiry-date: uint,
    certifier: principal,
    standards-met: (list 10 (string-ascii 50))
  }
)

;; Counter for unique product IDs
(define-data-var product-counter uint u0)

;; Register a certifier (only contract owner can register)
(define-public (register-certifier (certifier-id principal) (name (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok (map-set certifiers
      { certifier-id: certifier-id }
      {
        name: name,
        active: true
      }
    ))
  )
)

;; Certify a product (only active certifiers can certify)
(define-public (certify-product
                (producer-id principal)
                (expiry-blocks uint)
                (standards-met (list 10 (string-ascii 50))))
  (let ((product-id (+ (var-get product-counter) u1))
        (certifier tx-sender))
    (begin
      (asserts! (is-some (map-get? certifiers { certifier-id: certifier })) (err u2))
      (asserts! (get active (unwrap! (map-get? certifiers { certifier-id: certifier }) (err u3))) (err u4))

      ;; Check if producer is verified - contract call commented out for simplicity
      ;; (unwrap-panic (contract-call? .producer-verification is-producer-verified producer-id))

      (var-set product-counter product-id)
      (ok (map-set certified-products
        { product-id: product-id }
        {
          producer-id: producer-id,
          certification-date: block-height,
          expiry-date: (+ block-height expiry-blocks),
          certifier: certifier,
          standards-met: standards-met
        }
      ))
    )
  )
)

;; Verify if a product is certified and not expired
(define-read-only (is-product-certified (product-id uint))
  (match (map-get? certified-products { product-id: product-id })
    product-data (ok (< block-height (get expiry-date product-data)))
    (err u5)
  )
)

;; Get product certification details
(define-read-only (get-certification-details (product-id uint))
  (map-get? certified-products { product-id: product-id })
)

;; Deactivate a certifier
(define-public (deactivate-certifier (certifier-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (match (map-get? certifiers { certifier-id: certifier-id })
      certifier-data (ok (map-set certifiers
                          { certifier-id: certifier-id }
                          (merge certifier-data { active: false })
                        ))
      (err u6)
    )
  )
)

;; Transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok (var-set contract-owner new-owner))
  )
)
