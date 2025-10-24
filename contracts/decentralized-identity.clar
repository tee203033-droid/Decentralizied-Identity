;; Decentralized Identity Management Contract

(define-map did-documents principal 
  {
    public-key: (buff 64),
    auth-method: (string-ascii 32)
  }
)

(define-map credentials 
  {
    holder: principal,
    issuer: principal,
    cred-type: (string-ascii 32)
  } 
  {
    data: (buff 32),  ;; Hashed or minimal data for privacy
    revoked: bool
  }
)

(define-constant ERR-ALREADY-EXISTS u1)
(define-constant ERR-NOT-OWNER u2)
(define-constant ERR-NOT-FOUND u3)
(define-constant ERR-ALREADY-REVOKED u4)

;; Register a new DID document for the caller
(define-public (register-identity (public-key (buff 64)) (auth-method (string-ascii 32)))
  (match (map-get? did-documents tx-sender)
    existing (err ERR-ALREADY-EXISTS)
    (ok (map-insert did-documents tx-sender {public-key: public-key, auth-method: auth-method}))
  )
)

;; Update the caller's DID document
(define-public (update-identity (new-public-key (buff 64)) (new-auth-method (string-ascii 32)))
  (match (map-get? did-documents tx-sender)
    existing 
      (ok (map-set did-documents tx-sender {public-key: new-public-key, auth-method: new-auth-method}))
    (err ERR-NOT-OWNER)
  )
)

;; Issue a credential to a holder
(define-public (issue-credential (holder principal) (cred-type (string-ascii 32)) (data (buff 32)))
  (let ((key {holder: holder, issuer: tx-sender, cred-type: cred-type}))
    (match (map-get? credentials key)
      existing (err ERR-ALREADY-EXISTS)
      (ok (map-insert credentials key {data: data, revoked: false}))
    )
  )
)

;; Revoke a credential (issuer-only)
(define-public (revoke-credential (holder principal) (cred-type (string-ascii 32)))
  (let ((key {holder: holder, issuer: tx-sender, cred-type: cred-type}))
    (match (map-get? credentials key)
      some-cred 
        (if (not (get revoked some-cred))
          (ok (map-set credentials key {data: (get data some-cred), revoked: true}))
          (err ERR-ALREADY-REVOKED)
        )
      (err ERR-NOT-FOUND)
    )
  )
)

;; Verify an attribute (existence check without revealing data)
(define-read-only (verify-attribute (holder principal) (issuer principal) (cred-type (string-ascii 32)))
  (match (map-get? credentials {holder: holder, issuer: issuer, cred-type: cred-type})
    some-cred 
      (if (not (get revoked some-cred))
        (ok true)
        (ok false)
      )
    (ok false)
  )
)

;; Get DID document (read-only for verifiers)
(define-read-only (get-did-document (user principal))
  (map-get? did-documents user)
)

;; Get credential details (for holder or issuer only, to preserve privacy)
(define-read-only (get-credential (holder principal) (issuer principal) (cred-type (string-ascii 32)))
  (if (or (is-eq tx-sender holder) (is-eq tx-sender issuer))
    (map-get? credentials {holder: holder, issuer: issuer, cred-type: cred-type})
    none
  )
)