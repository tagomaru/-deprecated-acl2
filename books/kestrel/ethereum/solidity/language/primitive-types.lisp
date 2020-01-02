; Ethereum Library
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Teruhiro Tagomori

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ETHEREUM")

(include-book "centaur/fty/top" :dir :system)
(include-book "kestrel/utilities/xdoc/defxdoc-plus" :dir :system)
(include-book "std/util/defrule" :dir :system)

(defxdoc+ primitive-types
  :parents (syntax)
  :short "Solidity primitive types."
  :long
  (xdoc::topstring
   (xdoc::p
    "XXX"
    (xdoc::seeurl "primitive-values" "here")
    ".")
   (xdoc::p
    "XXX")
   (xdoc::p
    "XXX"))
  :order-subtopics t
  :default-parent t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fty::deftagsum numeric-type
  :short "Fixtype of Solidity numeric types."
  (:int ())
  (:long ())
  :pred numeric-typep)

  
(fty::deftagsum primitive-type
  :short "Rixtype of Solidity primitive types."
  (:int ())
  (:long ())
  :pred primitive-typep)


