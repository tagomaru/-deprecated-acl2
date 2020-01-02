; Ethereum Library
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Teruhiro Tagomori

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ETHEREUM")

;(include-book "types")

;(include-book "../language/primitive-conversions")

;(include-book "kestrel/std/system/function-name-listp" :dir :system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO: primitive should be Elementary?
; https://github.com/ethereum/solidity/blob/develop/docs/grammar.txt#L150
; ElementaryTypeName

(defxdoc+ ats-solidity-primitives
  :parents (ats-implementation)
  :short "Representation of Solidity primitive types and operations for ATS."
  :long
  (xdoc::topstring
   (xdoc::p
    "In order to have ATS generate Solidity code
     that manipulates Solidity primitive values,
     we use ACL2 functions that correspond to
     the Solidity primitive values and operations:
     when ATS encounters these specific ACL2 functions,
     it translate them to corresponding Solidity constructs
     that operate on primitive types;
     this happens only when @(':deep') is @('nil') and @(':guards') is @('t').")
   (xdoc::p
    "When deriving a Solidity implementation from a specification,
     where ATS is used as the last step of the derivation,
     the steps just before the last one can refine the ACL2 code
     to use the aforementioned ACL2 functions,
     ideally using " (xdoc::seetopic "apt::apt" "APT") " transformations,
     so that ATS can produce Solidity code
     that operates on primitive values where needed.
     Such refinement steps could perhaps be somewhat automated,
     and incorporated into a code generation step that actually encompasses
     some APT transformation steps
     before the final ATS code generation step.")
   (xdoc::p
    "The natural place for the aforementioned ACL2 functions
     that correspond to Solidity primitive values and operations is the "
    (xdoc::seetopic "language" "language formalization")
    " that is being developed.
     So ATS recognizes those functions from the language formalization,
     and translates them to Solidity code that manipulates Solidity primitive values.")
   (xdoc::p
    "Needless to say, here `primitive' refers to
     Solidity primitive types, values, and operations.
     It has nothing to do with the ACL2 primitive functions."))
  :order-subtopics t
  :default-parent t)
