;; Title: BDP000 Bootstrap
;; Author: Marvin Janssen
;; Synopsis:
;; Boot proposal that sets the governance token, DAO parameters, and extensions, and
;; mints the initial governance tokens.
;; Description:
;; Mints the initial supply of governance tokens and enables the the following 
;; extensions: "BDE000 Governance Token", "BDE001 Proposal Voting",
;; "BDE002 Proposal Submission", "BDE003 Core Proposals",
;; "BDE004 Core Execute".

(impl-trait .proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin
		;; Enable genesis extensions.
		(try! (contract-call? .bitcoin-dao set-extensions
			(list
				{extension: .bde000-governance-token, enabled: true}
				{extension: .bde003-core-proposals, enabled: true}
				{extension: .bde004-core-execute, enabled: true}
				{extension: .bde007-snapshot-proposal-voting, enabled: true}
				{extension: .bde008-flexible-funded-submission, enabled: true}
			)
		))

		;; Set core team members.
		(try! (contract-call? .bde003-core-proposals set-core-team-member 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM true))
		(try! (contract-call? .bde003-core-proposals set-core-team-member 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 true))

		;; Set executive team members.
		(try! (contract-call? .bde004-core-execute set-executive-team-member 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM true))
		(try! (contract-call? .bde004-core-execute set-executive-team-member 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 true))
		(try! (contract-call? .bde004-core-execute set-executive-team-member 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG true))
		(try! (contract-call? .bde004-core-execute set-executive-team-member 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC true))
		(try! (contract-call? .bde004-core-execute set-signals-required u1)) ;; signal from 3 out of 4 team members requied.

		;; Mint initial token supply.
		(try! (contract-call? .bde000-governance-token bdg-mint-many
			(list
				{amount: u1000, recipient: sender}
				{amount: u1000, recipient: 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5}
				{amount: u1000, recipient: 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG}
				{amount: u1000, recipient: 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC}
				{amount: u1000, recipient: 'ST2NEB84ASENDXKYGJPQW86YXQCEFEX2ZQPG87ND}
				{amount: u1000, recipient: 'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB}
				{amount: u1000, recipient: 'ST3AM1A56AK2C1XAFJ4115ZSV26EB49BVQ10MGCS0}
				{amount: u1000, recipient: 'ST3NBRSFKX28FQ2ZJ1MAKX58HKHSDGNV5N7R21XCP}
				{amount: u1000, recipient: 'ST3PF13W7Z0RRM42A8VZRVFQ75SV1K26RXEP8YGKJ}
				;;{amount: u1000, recipient: 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6}
			)
		))

		(print "Bitcoin DAO has risen.")
		(ok true)
	)
)
