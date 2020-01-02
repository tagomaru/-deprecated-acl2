; Ethereum Library
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Teruhiro Tagomori

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ETHEREUM")

(include-book "kestrel/fty/ubyte16" :dir :system)
(include-book "kestrel/fty/sbyte8" :dir :system)
(include-book "kestrel/fty/sbyte16" :dir :system)
(include-book "kestrel/fty/sbyte32" :dir :system)
(include-book "kestrel/fty/sbyte64" :dir :system)
(include-book "kestrel/std/util/deffixer" :dir :system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc+ primitive-values
  :parents (semantics)
  :short "Ethereum primitive values"
  :long
  (xdoc::topstring
   (xdoc::p
    "We formalize the Java boolean and integral values.
     We also provide abstract notions of the Java floating-point values,
     as a placeholder for a more precise formalization of them.")
   (xdoc::p
    "Our formalization tags the Java primitive values
     with an indication of their types
     (and, for floating-point values, of their value sets),
     making values of different types (and of floating-point value sets)
     disjoint.
     This will allow us
     to define a defensive semantics of Ethereum
     and to prove that the static checks at compile time
     guarantee type safety at run time,
     as often done in programming language formalizations."))
  :order-subtopics t
  :default-parent t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fty::defprod char-value
  :short "Fixtype of Solidity @('char') values."
  ((nat ubyte16))
  :tag :char
  :layout :list
  ///

  (defrule char-value->nat-upper-bound
    (<= (char-value->nat x) 65535)
    :rule-classes :linear
    :enable (char-value->nat
             acl2::ubyte16p
             acl2::ubyte16-fix)))

(fty::defprod int-value
  :short "Fixtype of Ethereum."
  ((int sbyte32))
  :tag :int
  :layout :list
  ///

  (defrule int-value->int-lower-bound
    (<= -2147483648 (int-value->int x))
     :rule-classes :linear
    :enable (int-value->int
             acl2::sbyte32p
             acl2::sbyte32-fix))

  (defrule int-value->int-upper-bound
    (<= (int-value->int x) 2147483647)
    :rule-classes :linear
    :enable (int-value->int
             acl2::sbyte32p
             acl2::sbyte32-fix)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fty::defprod long-value
  :short "Fixtype of Java @('long') values [JLS:4.2.1]."
  ((int sbyte64))
  :tag :long
  :layout :list
  ///

  (defrule long-value->int-lower-bound
    (<= -9223372036854775808 (long-value->int x))
     :rule-classes :linear
    :enable (long-value->int
             acl2::sbyte64p
             acl2::sbyte64-fix))

  (defrule long-value->int-upper-bound
    (<= (long-value->int x) 9223372036854775807)
    :rule-classes :linear
    :enable (long-value->int
             acl2::sbyte64p
             acl2::sbyte64-fix)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fty::defflexsum integral-value
  :short "Fixtype of Java integral values [JLS:4.2.1]."
  (:int
   :fields ((get :type int-value :acc-body x))
   :ctor-body get
   :cond (int-value-p x))
  (:long
   :fields ((get :type long-value :acc-body x))
   :ctor-body get)
  :prepwork ((local (in-theory (enable byte-value-p
                                       short-value-p
                                       int-value-p
                                       long-value-p
                                       byte-value-fix
                                       short-value-fix
                                       int-value-fix
                                       long-value-fix))))
  ///

  (local (in-theory (enable integral-value-p)))

  (defrule integral-value-p-when-int-value-p
    (implies (int-value-p x)
             (integral-value-p x)))

  (defrule integral-value-p-when-long-value-p
    (implies (long-value-p x)
             (integral-value-p x))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fty::defflexsum numeric-value
  :short "Fixtype of Java numeric values [JLS:4.2],
          excluding extended-exponent values [JLS:4.2.3]."
  (:int
   :fields ((get :type int-value :acc-body x))
   :ctor-body get
   :cond (int-value-p x))
  (:long
   :fields ((get :type long-value :acc-body x))
   :ctor-body get
   :cond (long-value-p x))
  :prepwork ((local (in-theory (enable int-value-p
                                       long-value-p))))
  ///

  (local (in-theory (enable numeric-value-p)))

  (defrule numeric-value-p-when-integral-value-p
    (implies (integral-value-p x)
             (numeric-value-p x))
    :enable integral-value-p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defsection numericx-value
  :short "Fixtype of Java numeric values [JLS:4.2],
          including extended-exponent values [JLS:4.2.3]."

  (define numericx-value-p (x)
    :returns (yes/no booleanp)
    :parents (numericx-value)
    :short "Recognizer for @(tsee numericx-value)."
    (or (numeric-value-p x))
    ///

    (defrule numericx-value-p-when-numeric-value-p
      (implies (numeric-value-p x)
               (numericx-value-p x)))))

;    (defrule numericx-value-p-when-floatx-value-p
;      (implies (numericx-value-p x))))

;  (std::deffixer numericx-value-fix
;    :pred numericx-value-p
;    :body-fix (char-value 0))

;  (fty::deffixtype numericx-value
;    :pred numericx-value-p
;    :fix numericx-value-fix
;    :equiv numericx-value-equiv
;    :define t
;    :forward t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fty::defflexsum primitive-value
  :short "Fixtype of Java primitive values [JLS:4.2],
          excluding extended-exponent values [JLS:4.2.3]."
  (:int
   :fields ((get :type int-value :acc-body x))
   :ctor-body get
   :cond (int-value-p x))
  (:long
   :fields ((get :type long-value :acc-body x))
   :ctor-body get
   :cond (long-value-p x))
  :prepwork ((local (in-theory (enable int-value-p
                                       long-value-p
                                       int-value-fix
                                       long-value-fix))))
  ///

  (local (in-theory (enable primitive-value-p)))


  (defrule primitive-value-p-when-numeric-value-p
    (implies (numeric-value-p x)
             (primitive-value-p x))
    :enable numeric-value-p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defsection primitivex-value
  :short "Fixtype of Java primitive values [JLS:4.2],
          including extended-exponent values [JLS:4.2.3]."

  (define primitivex-value-p (x)
    :returns (yes/no booleanp)
    :parents (primitivex-value)
    :short "Recognizer for @(tsee primitivex-value)."
    (or (primitive-value-p x))
    ///

    (defrule primitivex-value-p-when-primitive-value-p
      (implies (primitive-value-p x)
               (primitivex-value-p x)))

    (defrule primitivex-value-p-when-numericx-value-p
      (implies (numericx-value-p x)
               (primitivex-value-p x))
      :enable numericx-value-p))

  (std::deffixer primitivex-value-fix
    :pred primitivex-value-p
    :body-fix (char-value 0)
    :parents (primitivex-value)
    :short "Fixer for @(tsee primitivex-value).")

  (fty::deffixtype primitivex-value
    :pred primitivex-value-p
    :fix primitivex-value-fix
    :equiv primitivex-value-equiv
    :define t
    :forward t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defruled disjoint-primitive-values
  :short "The tagging keywords make all the primitive values disjoint."
  (and (implies (int-value-p x)
                (and (not (long-value-p x)))))
  :enable (int-value-p
           long-value-p))
