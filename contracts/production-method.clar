;; production-method.clar
;; This contract documents traditional techniques used in production

(define-data-var contract-owner principal tx-sender)

;; Map of production methods by ID
(define-map production-methods
  { method-id: uint }
  {
    name: (string-ascii 100),
    description: (string-utf8 500),
    traditional: bool,
    region: (string-ascii 100),
    registered-by: principal
  }
)

;; Map of products to their production methods
(define-map product-methods
  { product-id: uint }
  { methods: (list 10 uint) }
)

;; Counter for unique method IDs
(define-data-var method-counter uint u0)

;; Register a new production method
(define-public (register-method
                (name (string-ascii 100))
                (description (string-utf8 500))
                (traditional bool)
                (region (string-ascii 100)))
  (let ((method-id (+ (var-get method-counter) u1)))
    (begin
      (var-set method-counter method-id)
      (ok (map-set production-methods
        { method-id: method-id }
        {
          name: name,
          description: description,
          traditional: traditional,
          region: region,
          registered-by: tx-sender
        }
      ))
    )
  )
)

;; Associate methods with a product
(define-public (set-product-methods (product-id uint) (methods (list 10 uint)))
  (begin
    (ok (map-set product-methods
      { product-id: product-id }
      { methods: methods }
    ))
  )
)

;; Get method details
(define-read-only (get-method-details (method-id uint))
  (map-get? production-methods { method-id: method-id })
)

;; Get product methods
(define-read-only (get-product-methods (product-id uint))
  (map-get? product-methods { product-id: product-id })
)

;; Transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok (var-set contract-owner new-owner))
  )
)
