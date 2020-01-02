; Ethereum Library
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Teruhiro Tagomori

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ETHEREUM")

(include-book "primitive-types")
(include-book "primitive-values")

(include-book "ihs/basic-definitions" :dir :system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrulel sbyte32p-of-logext32
  (sbyte32p (logext 32 x))
  :enable sbyte32p
  :prep-books ((include-book "arithmetic-5/top" :dir :system)))

(defrulel sbyte64p-of-logext64
  (sbyte64p (logext 64 x))
  :enable sbyte64p
  :prep-books ((include-book "arithmetic-5/top" :dir :system)))

(local (in-theory (disable logext)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define primitive-type-predicate ((type primitive-typep))
  :returns (predicate symbolp)
  :short "The recognizer of the fixtype of the values of a primitive type."
  (packn-pos (list (symbol-name (primitive-type-kind type)) '-value-p)
             (pkg-witness "ETHEREUM")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define primitive-type-constructor ((type primitive-typep))
  :returns (constructor symbolp)
  :short "The constructor of the fixtype of the values of a primitive type."
  (packn-pos (list (symbol-name (primitive-type-kind type)) '-value)
             (pkg-witness "ETHEREUM")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define primitive-type-destructor ((type primitive-typep))
  :returns (destructor symbolp)
  :short "The destructor of the fixtype of the values of a primitive type."
  (primitive-type-case type
                       :int 'int-value->int
                       :long 'long-value->int))


(defsection def-primitive-binary-op
  :short "Macro to formalize a Solidity primitive binary operation."
  :long
  (xdoc::topstring
   (xdoc::p
    "XXX")
   (xdoc::p
    "XXX")
   (xdoc::@def "def-primitive-binary-op"))

  (define def-primitive-binary-op-fn ((name symbolp)
                                      (in-type-left primitive-typep)
                                      (in-type-right primitive-typep)
                                      (out-type primitive-typep)
                                      (operation "An untranslated term.")
                                      (nonzero booleanp)
                                      (parents symbol-listp)
                                      (parents-suppliedp booleanp)
                                      (short "A string or form or @('nil').")
                                      (short-suppliedp booleanp)
                                      (long "A string or form or @('nil').")
                                      (long-suppliedp booleanp))
    :returns (event "A @(tsee acl2::maybe-pseudo-event-formp).")
    :parents nil
    (b* ((in-predicate-left (primitive-type-predicate in-type-left))
         (in-predicate-right (primitive-type-predicate in-type-right))
         (in-destructor-left (primitive-type-destructor in-type-left))
         (in-destructor-right (primitive-type-destructor in-type-right))
         (out-predicate (primitive-type-predicate out-type))
         (out-constructor (primitive-type-constructor out-type))
         ((when (and nonzero
                     (not (primitive-type-case in-type-right :int))
                     (not (primitive-type-case in-type-right :long))))
          (raise "The :NONZERO argument may be T ~
                  only if the right operand type is int or long, ~
                  but it is ~x0 instead."
                 (primitive-type-kind in-type-right)))
         (guard? (and nonzero
                      `(not (equal (,in-destructor-right operand-right) 0)))))
      `(define ,name ((operand-left ,in-predicate-left)
                      (operand-right ,in-predicate-right))
         ,@(and guard? (list :guard guard?))
         :returns (result ,out-predicate)
         ,@(and parents-suppliedp (list :parents parents))
         ,@(and short-suppliedp (list :short short))
         ,@(and long-suppliedp (list :long long))
         (b* ((x (,in-destructor-left operand-left))
              (y (,in-destructor-right operand-right)))
           (,out-constructor ,operation))
         :hooks (:fix)
         :no-function t)))

  (defmacro def-primitive-binary-op (name
                                     &key
                                     in-type-left
                                     in-type-right
                                     out-type
                                     operation
                                     nonzero
                                     (parents 'nil parents-suppliedp)
                                     (short 'nil short-suppliedp)
                                     (long 'nil long-suppliedp))
    `(make-event
      (def-primitive-binary-op-fn
        ',name
        ,in-type-left
        ,in-type-right
        ,out-type
        ',operation
        ,nonzero
        ',parents ,parents-suppliedp
        ,short ,short-suppliedp
        ,long ,long-suppliedp))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defsection def-int-binary-op
  :short "Specialization of @(tsee def-primitive-binary-op) to
          the case in which input and output types are @('int')."
  :long (xdoc::topstring-@def "def-int-binary-op")

  (defmacro def-int-binary-op (name
                               &key
                               operation
                               nonzero
                               (parents 'nil parents-suppliedp)
                               (short 'nil short-suppliedp)
                               (long 'nil long-suppliedp))
    `(def-primitive-binary-op ,name
       :in-type-left (primitive-type-int)
       :in-type-right (primitive-type-int)
       :out-type (primitive-type-int)
       :operation ,operation
       :nonzero ,nonzero
       ,@(and parents-suppliedp (list :parents parents))
       ,@(and short-suppliedp (list :short short))
       ,@(and long-suppliedp (list :long long)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(def-int-binary-op int-add
  :operation (logext 32 (+ x y))
  :short "Addition @('+') on @('int')s [JLS:4.2.2] [JLS:15.18.2].")
