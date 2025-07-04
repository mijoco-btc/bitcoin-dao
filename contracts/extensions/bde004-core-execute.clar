;; Title: BDE004 Core Execute
;; Author: Mike Cohen (based on Marvin Janssen)
;; Depends-On: 
;; Synopsis:
;; This extension allows a small number of very trusted principals to immediately
;; execute a proposal once a super majority is reached.
;; Description:
;; An extension meant for the bootstrapping period of a DAO. It temporarily gives
;; some very trusted principals the ability to perform an "executive action";
;; meaning, they can skip the voting process to immediately executive a proposal.
;; The Core execute extension has an optional sunset period of ~1 month from deploy
;; time, set it to 0 to disable. The core executive team, parameters, and sunset period may be changed
;; by means of a future proposal.

(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-data-var executive-team-sunset-height uint u0) ;; does not expire by default - can be changed by proposal

(define-constant err-unauthorised (err u3400))
(define-constant err-not-executive-team-member (err u3401))
(define-constant err-already-executed (err u3402))
(define-constant err-sunset-height-reached (err u3403))
(define-constant err-sunset-height-in-past (err u3404))

(define-map executive-team principal bool)
(define-map executive-action-signals {proposal: principal, team-member: principal} bool)
(define-map executive-action-signal-count principal uint)

(define-data-var executive-signals-required uint u1) ;; signals required for an executive action.

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .bitcoin-dao) (contract-call? .bitcoin-dao is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

(define-public (set-executive-team-sunset-height (height uint))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (> height burn-block-height) err-sunset-height-in-past)
		(ok (var-set executive-team-sunset-height height))
	)
)

(define-public (set-executive-team-member (who principal) (member bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set executive-team who member))
	)
)

(define-public (set-signals-required (new-requirement uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set executive-signals-required new-requirement))
	)
)

;; --- Public functions

(define-read-only (is-executive-team-member (who principal))
	(default-to false (map-get? executive-team who))
)

(define-read-only (has-signalled (proposal principal) (who principal))
	(default-to false (map-get? executive-action-signals {proposal: proposal, team-member: who}))
)

(define-read-only (get-signals-required)
	(var-get executive-signals-required)
)

(define-read-only (get-signals (proposal principal))
	(default-to u0 (map-get? executive-action-signal-count proposal))
)

(define-public (executive-action (proposal <proposal-trait>))
	(let
		(
			(proposal-principal (contract-of proposal))
			(signals (+ (get-signals proposal-principal) (if (has-signalled proposal-principal tx-sender) u0 u1)))
		)
		(asserts! (is-executive-team-member tx-sender) err-not-executive-team-member)
		(asserts! (or (is-eq (var-get executive-team-sunset-height) u0) (< burn-block-height (var-get executive-team-sunset-height))) err-sunset-height-reached)
		(and (>= signals (var-get executive-signals-required))
			(try! (contract-call? .bitcoin-dao execute proposal tx-sender))
		)
		(map-set executive-action-signals {proposal: proposal-principal, team-member: tx-sender} true)
		(map-set executive-action-signal-count proposal-principal signals)
		(ok signals)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)