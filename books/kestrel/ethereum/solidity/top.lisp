; Ethereum Library
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Teruhiro Tagomori

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ETHEREUM")

; the order of the following INCLUDE-BOOKs determines
; the order of the subtopics of the LANGUAGE topic below:
(include-book "syntax")
(include-book "semantics")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc+ language
  :parents (solidity)
  :short "A formal model of some aspects of the Solidity language."
  :long
  (xdoc::topstring
   (xdoc::p
    "It is expected that more aspects of the Solidity language
     will be formalized here over time."))
  :order-subtopics t)
