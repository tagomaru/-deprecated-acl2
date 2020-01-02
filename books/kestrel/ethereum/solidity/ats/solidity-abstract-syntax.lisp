; Ethereum Library
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Teruhiro Tagomori

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ETHEREUM")

; (include-book "../language/primitive-types")

(include-book "centaur/fty/top" :dir :system)
(include-book "kestrel/std/util/deffixer" :dir :system)
(include-book "std/basic/two-nats-measure" :dir :system)
(include-book "kestrel/utilities/xdoc/defxdoc-plus" :dir :system)

; this is to have FTY::DEFLIST generate more theorems:
(local (include-book "std/lists/top" :dir :system))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc+ ats-solidity-abstract-syntax
;  :parents (XXX)
  :short "An abstract syntax Solidity for ATS's implementations."
  :long
  (xdoc::topstring
   (xdoc::p
    "This is not meant as a complete formalization
     of an abstract syntax for Solidity."))
  :order-subtopics t
  :default-parent t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Library extensions.

(defsection string-list
  :short "Fixtype of true of ACL2 strings,
          i.e. values recognized by @tsee string-list)."
  :long
  (xdoc::topstring-p
   "This is not specific to Solidity,
    and it should ber moved to a more general Library eventually.")

  (std::deffixer string-list-fix
    :pred string-listp
    :body-fix nil
    :parents (string-list)
    :short "Fixer for @(tsee string-list).")

  (fty::deffixtype string-list
    :pred string-listp
    :fix string-list-fix
    :equiv string-list-equiv
    :define t
    :forward t))

(defsection maybe-string
  :short "Fixtype of ACL2 strings and @('nil'),
          i.e. values recognized by @(tsee maybe-stringp)."
  :long
  (xdoc::topstring-p
   "This is not specific to Solidity,
    and it should be moved to a more general library eventually.")

  (std::deffixer maybe-string-fix
    :pred maybe-stringp
    :body-fix nil
    :parents (maybe-string)
    :short "Fixer for @(tsee maybe-string).")

  (fty::deffixtype maybe-string
    :pred maybe-stringp
    :fix maybe-string-fix
    :equiv maybe-string-equiv
    :define t
    :forward t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; https://solidity.readthedocs.io/en/v0.6.0/miscellaneous.html#language-grammar
; https://solidity.readthedocs.io/en/v0.6.0/types.html#integer-types

(fty::deftagsum snumbase
  :short "Solidity base for number literals"
  (:decimal ())
  (:hexadecimal ())
  :pred snumbasep)

(fty::deftagsum sliteral
  :short "Solidity literals"
  (:number ((value acl2::nat) (base snumbase))))
   
;(include-book "centaur/fty/top" :dir :system)
;(fty::deftagsum sliteral
;  (:string ((value string))))