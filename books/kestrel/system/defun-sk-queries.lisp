; DEFUN-SK Queries
;
; Copyright (C) 2015-2016 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains utilities
; for recognizing functions introduced via DEFUN-SK
; and for retrieving their DEFUN-SK-specific constituents.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "kestrel/system/world-queries" :dir :system)
(include-book "std/util/defenum" :dir :system)
(include-book "std/util/defaggregate" :dir :system)

(local (set-default-parents defun-sk-queries))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc defun-sk-queries

  :parents (kestrel-system-utilities system-utilities defun-sk)

  :short "Utilities to query @(tsee defun-sk) functions."

  :long

  "<p>
  @(tsee Defun-sk) mimics functions with (top-level) quantifiers
  in the quantifier-free logic of ACL2,
  by <see topic='@(url defchoose)'>conservatively axiomatizing</see>
  an associated witness function
  and by defining the @(tsee defun-sk) function
  in terms of the witness function;
  it also generates a rewrite rule to support reasoning
  about the function with the quantifier.
  This provides the desired logical properties,
  but programmatically accessing the @(tsee defun-sk)-specific constituents
  of the @(tsee defun-sk) function (quantifier, bound variables, etc.)
  is not immediate.
  </p>

  <p>
  These @(tsee defun-sk) query utilities provide facilities
  to check whether a function has been introduced via @(tsee defun-sk),
  and, if so, to retrieve its @(tsee defun-sk)-specific constituents.
  Constituents of the function that are not @(tsee defun-sk)-specific
  (formal arguments, guard, etc.)
  can be retrieved
  with <see topic='@(url system-utilities)'>more general utilities</see>.
  The @(tsee defun-sk-check) function is used to check
  whether a function has been introduced via @(tsee defun-sk):
  if so, @(tsee defun-sk-check) returns
  a non-@('nil') <see topic='@(url std::defaggregate)'>record</see>
  with the function's @(tsee defun-sk)-specific constituents,
  which can be accessed with the
  <see topic='@(url std::defaggregate)'>record</see>'s field accessors;
  otherwise, @(tsee defun-sk-check) returns @('nil').
  </p>

  <p>
  @(tsee Defun-sk) leaves no clearly recognizable trace of its use
  in the ACL2 @(see world).
  The user might directly enter the expansion of @(tsee defun-sk);
  there is no @(see table) of @(tsee defun-sk) functions.
  @(see Command) landmarks may not show the use of @(tsee defun-sk) either,
  e.g. a single @(tsee include-book) command
  may add several @(tsee defun-sk) functions to the @(see world).
  So @(tsee defun-sk-check) may return non-@('nil') in the unlikely case that
  the function has been introduced not via @(tsee defun-sk),
  but via @(see events) that are essentially identical
  to the @(see events) generated by @(tsee defun-sk).
  In this case, the function &ldquo;could&rdquo; have been introduced
  via @(tsee defun-sk),
  in the sense that it has the same logical properties
  (@(tsee defun-sk-check) checks whether
  the witness axiom and the function definition
  have the same form as in @(tsee defun-sk)).
  </p>")

(std::defenum defun-sk-quantifier-p (exists forall)
  :short
  "<see topic='@(url exists)'>Existential</see>
  and <see topic='@(url forall)'>universal</see>
  quantifiers.")

(std::defenum defun-sk-rewrite-kind-p (:default :direct :custom)
  :short
  "Kinds of rewrite rules associated to
  @(tsee defun-sk) functions with the
  <see topic='@(url forall)'>universal quantifier</see>."
  :long
  "<p>
  These correspond to the values
  of the @(':rewrite') option of @(tsee defun-sk),
  with @(':custom') standing for anything but @(':default') or @(':direct').
  </p>")

(std::defaggregate defun-sk-info
  :short
  "@(tsee defun-sk)-specific constituents of a @(tsee defun-sk) function."
  ((quantifier "Quantifier."
               defun-sk-quantifier-p)
   (bound-vars "Variables bound by the quantifier."
               symbol-listp)
   (matrix "Matrix (in <see topic='@(url term)'>translated form</see>)."
           pseudo-termp)
   (untrans-matrix "<see topic='@(url term)'>Untranslated form</see>
                   of the matrix.")
   (witness "Witness function."
            symbolp)
   (rewrite-name "Name of the rewrite rule."
                 symbolp)
   (rewrite-kind "Kind of the rewrite rule."
                 defun-sk-rewrite-kind-p)
   (strengthen "Value of the @(':strengthen') flag."
               booleanp)
   (non-executable "Value of the @(':non-executable') flag."
                   booleanp)
   (classicalp "Value of the @(':classicalp') flag
               (only relevant for <see topic='@(url real)'>ACL2(r)</see>;
               always @('t') when not running
               <see topic='@(url real)'>ACL2(r)</see>)."
               booleanp)))

(define maybe-defun-sk-info-p (x)
  :returns (yes/no booleanp)
  :short
  "True iff @('x') is a @(tsee defun-sk-info) record or is @('nil')."
  (or (defun-sk-info-p x)
      (null x)))

(define defun-sk-check-signature-result (sig-result)
  :returns (mv (yes/no booleanp) (bound-vars symbol-listp))
  :short
  "Check the result information of the @(see signature)
  of the @(tsee encapsulate) of a @(tsee defun-sk) function,
  retrieving the variables bound by the quantifier."
  :long
  "<p>
  The result information of the signature must be
  either a symbol for a single bound variable @('bvar'),
  or a list @('(mv bvar1 ... bvarM)') with @('M') &gt; 1 bound variables.
  </p>"
  (cond ((symbolp sig-result)
         (mv t (list sig-result)))
        ((and (symbol-listp sig-result)
              (>= (len sig-result) 3)
              (eq (car sig-result) 'mv))
         (mv t (cdr sig-result)))
        (t (mv nil nil))))

(define defun-sk-check-signature (signature
                                  (witness symbolp)
                                  (args symbol-listp))
  ;; :returns (mv (yes/no booleanp)
  ;;              (bound-vars symbol-listp)
  ;;              (classicalp booleanp))
  :short
  "Check the @(see signature)
  of the @(tsee encapsulate) of a @(tsee defun-sk) function,
  retrieving the variables bound by the quantifier
  and the @(':classicalp') flag (@('t') if absent)."
  :long
  "<p>
  The signature must have the form
  </p>
  @({
  (witness (arg1 ... argN) bvar)
  })
  <p>
  or
  </p>
  @({
  (witness (arg1 ... argN) (mv bvar1 ... bvarM))
  })
  <p>
  or
  </p>
  @({
  (witness (arg1 ... argN) bvar :classicalp t/nil)
  })
  <p>
  or
  </p>
  @({
  (witness (arg1 ... argN) (mv bvar1 ... bvarM) :classicalp t/nil)
  })
  <p>
  where @('witness') is the witness function,
  @('arg1'), ..., @('argN') are the formal arguments
  of the witness and @(tsee defun-sk) functions,
  and @(':classicalp') may be present
  only when running <see topic='@(url real)'>ACL2(r)</see>.
  </p>"
  (case-match signature
    ((!witness !args sig-result)
     (mv-let (yes/no bound-vars) (defun-sk-check-signature-result sig-result)
       (if yes/no
           (mv t bound-vars t)
         (mv nil nil nil))))
    ((!witness !args sig-result ':classicalp classicalp)
     (mv-let (yes/no bound-vars) (defun-sk-check-signature-result sig-result)
       (if yes/no
           (mv t bound-vars classicalp)
         (mv nil nil nil))))
    (& (mv nil nil nil))))

(define defun-sk-check-witness-def (witness-def
                                    (witness symbolp)
                                    (bound-vars symbol-listp)
                                    (args symbol-listp))
  :returns (mv (yes/no booleanp
                       :hints (("Goal" :in-theory
                                (enable defun-sk-check-signature-result))))
               witness-body
               (strengthen booleanp))
  :short
  "Check the local definition of the witness function
  in the @(tsee encapsulate) of a @(tsee defun-sk) function,
  retrieving
  the <see topic='@(url term)'>untranslated</see> body of the definition
  and the value of the @(':strengthen') flag."
  :long
  "<p>
  The local definition must have the form
  </p>
  @({
  (local (defchoose witness (bvar1 ... bvarM) (arg1 ... argN) body))
  })
  <p>
  or
  </p>
  @({
  (local
   (defchoose witness (bvar1 ... bvarM) (arg1 ... argN) body :strengthen t))
  })
  <p>
  where @('witness') is the witness function,
  @('bvar1'), ..., @('bvarM') are the variables bound by the quantifier,
  and @('arg1'), ..., @('argN') are the formal arguments
  of the witness and @(tsee defun-sk) functions.
  </p>"
  (case-match witness-def
    (('local ('defchoose !witness !bound-vars !args body . strengthen?))
     (cond ((equal strengthen? '(:strengthen t)) (mv t body t))
           ((eq strengthen? nil) (mv t body nil))
           (t (mv nil nil nil))))
    (& (mv nil nil nil))))

(define defun-sk-check-strengthen-defthm (strengthen-defthm
                                          (witness symbolp)
                                          (bound-vars symbol-listp)
                                          (args symbol-listp)
                                          witness-body)
  :returns (yes/no booleanp)
  :prepwork ((program))
  :short
  "Check the (optional) strengthening theorem
  in the @(tsee encapsulate) of a @(tsee defun-sk) function."
  :long
  "<p>
  The theorem must have the form
  calculated in the ACL2 source code of @(tsee defun-sk)
  (copied here, with variables suitably renamed).
  </p>"
  (equal
   strengthen-defthm
   `(defthm ,(packn (list witness '-strengthen))
      ,(defchoose-constraint-extra witness bound-vars args witness-body)
      :hints (("Goal"
               :use ,witness
               :in-theory (theory 'minimal-theory)))
      :rule-classes nil)))

(define defun-sk-check-function-def (function-def
                                     (fun symbolp)
                                     (args symbol-listp)
                                     (witness symbolp)
                                     witness-body
                                     (bound-vars symbol-listp))
  :returns (mv (yes/no booleanp)
               untrans-matrix
               (quantifier defun-sk-quantifier-p)
               (non-executable booleanp))
  :verify-guards nil
  :short
  "Check the (non-local) definition of the @(tsee defun-sk) function
  in its @(tsee encapsulate),
  retrieving the <see topic='@(url term)'>untranslated</see> matrix,
  the quantifier,
  and the @(':non-executable') flag."
  :long
  "<p>
  The definition must have one of the following forms,
  where @('fun') is the @(tsee defun-sk) function,
  @('arg1'), ..., @('argN') are the formal arguments
  of the witness and @(tsee defun-sk) functions,
  @('bvar1'), ..., @('bvarM') are the variables bound by the quantifier,
  @('witness') is the witness function,
  @('matrix') is the (<see topic='@(url term)'>untranslated</see>) matrix
  of the @(tsee defun-sk) function,
  and @('declares') are zero or more @('(declare ...)') forms:
  </p>
  <ul>
  <li>
    @({
    (defun fun (arg1 ... argN) declares
      (let ((bvar1 (witness arg1 ... argN))) matrix))
    })
    <p>
    if @('M') = 1 and @(':non-executable') is @('nil').
    </p>
  </li>
  <li>
    @({
    (defun-nx fun (arg1 ... argN) declares
      (let ((bvar1 (witness arg1 ... argN))) matrix))
    })
    <p>
    if @('M') = 1 and @(':non-executable') is @('t').
    </p>
  </li>
  <li>
    @({
    (defun fun (arg1 ... argN) declares
      (mv-let (bvar1 ... bvarM) (witness arg1 ... argN) matrix))
    })
    <p>
    if @('M') &gt; 1 and @(':non-executable') is @('nil').
    </p>
  </li>
  <li>
    @({
    (defun-nx fun (arg1 ... argN) declares
      (mv-let (bvar1 ... bvarM) (witness arg1 ... argN) matrix))
    })
    <p>
    if @('M') &gt; 1 and @(':non-executable') is @('t').
    </p>
  </li>
  </ul>
  <p>
  The body of the witness function is
  @('matrix') if the quantifier is existential,
  @('(not matrix)') if the quantifier is universal.
  </p>"
  (flet
   ((fail () (mv nil nil 'exists nil)))
   (case-match function-def
     ((defun/defun-nx !fun !args . declares-body)
      (b* (((unless (or (eq defun/defun-nx 'defun)
                        (eq defun/defun-nx 'defun-nx))) (fail))
           (non-executable (eq defun/defun-nx 'defun-nx))
           (body (car (last declares-body)))
           (pre-matrix (if (eql (len bound-vars) 1)
                           `(let ((,(car bound-vars) (,witness ,@args))))
                         `(mv-let ,bound-vars (,witness ,@args))))
           ((unless (equal (butlast body 1) pre-matrix)) (fail))
           (matrix (car (last body)))
           (quantifier (cond ((equal witness-body matrix) 'exists)
                             ((equal witness-body `(not ,matrix)) 'forall)
                             (t nil)))
           ((unless quantifier) (fail)))
        (mv t matrix quantifier non-executable)))
     (& (fail)))))

(define defun-sk-check-rewrite-rule (rewrite
                                     (fun symbolp)
                                     (args symbol-listp)
                                     (quantifier defun-sk-quantifier-p)
                                     untrans-matrix
                                     (witness symbolp))
  ;; :returns (mv (yes/no booleanp)
  ;;              (rewrite-name symbolp)
  ;;              (rewrite-kind defun-sk-rewrite-kind-p))
  :short
  "Check the rewrite rule in the @('encapsulate')
  of a @(tsee defun-sk) function,
  retrieving the name and kind of the rewrite rule."
  :long
  "<p>
  The rewrite rule has the form
  </p>
  @({
  (defthm name formula
    :hints ((&quot;Goal&quot;
            :use (witness fun) :in-theory (theory 'minimal-theory))))
  })
  <p>
  where @('fun') is the @(tsee defun-sk) function,
  @('witness') is the witness function,
  and @('formula') has one of the following forms,
  where @('arg1'), ..., @('argN') are the formal arguments
  of the witness and @(tsee defun-sk) functions,
  and @('matrix') is the <see topic='@(url term)'>untranslated</see> matrix
  of the @(tsee defun-sk) function:
  </p>
  <ul>
  <li>
    <p>
    @('(implies matrix (fun arg1 ... argN))')
    if the quantifier is <see topic='@(url exists)'>existential</see>.
    </p>
  </li>
  <li>
    <p>
    @('(implies (not matrix) (not (fun arg1 ... argN)))')
    if the quantifier is <see topic='@(url forall)'>universal</see>
    and @(':rewrite') is either @(':default') or exactly this formula.
    </p>
  </li>
  <li>
    <p>
    @('(implies (fun arg1 ... argN) matrix)')
    if the quantifier is <see topic='@(url forall)'>universal</see>
    and @(':rewrite') is either @(':direct') or exactly this formula.
    </p>
  </li>
  <li>
     <p>
     The formula passed to @(':rewrite'),
     if it does not match any of the above.
     </p>
  </li>
  </ul>"
  (flet
   ((fail () (mv nil nil :default)))
   (case-match rewrite
     (('defthm name formula
        ':hints (('"Goal"
                  ':use (!witness !fun)
                  ':in-theory ('theory ('quote 'minimal-theory)))))
      (cond ((eq quantifier 'exists)
             (cond ((equal formula
                           `(implies ,untrans-matrix (,fun ,@args)))
                    (mv t name :default))
                   (t (fail))))
            ((equal formula
                    `(implies (not ,untrans-matrix) (not (,fun ,@args))))
             (mv t name :default))
            ((equal formula
                    `(implies (,fun ,@args) ,untrans-matrix))
             (mv t name :direct))
            (t (mv t name :custom))))
     (& (fail)))))

(define defun-sk-retrieve-matrix ((fun (function-namep fun w))
                                  (bound-vars symbol-listp)
                                  (non-executable booleanp)
                                  (w plist-worldp))
  ;; :returns (matrix pseudo-termp)
  :verify-guards nil
  :short
  "Retrieve the matrix of a @(tsee defun-sk) function,
  in <see topic='@(url term)'>translated form</see>."
  :long
  "<p>
  After <see topic='@(url term)'>translation</see>,
  the (unnormalized) body of the @(tsee defun-sk) function
  should have the form
  @('(return-last 'progn (throw-nonexec-error ...) core)')
  if @(':non-executable') is @('t'),
  otherwise just @('core').
  @('Core') should have one of the following forms,
  where @('arg1'), ..., @('argN') are the formal arguments
  of the witness and @(tsee defun-sk) functions,
  and @('matrix') is the <see topic='@(url term)'>translated</see> matrix:
  </p>
  <ul>
  <li>
    @({
    ((lambda (bvar) matrix) (witness arg1 ... argN))
    })
    <p>
    if there is just one bound variable @('bvar'),
    as resulting from the <see topic='@(url term)'>translation</see>
    of the @(tsee let).
    </p>
  </li>
  <li>
    @({
    ((lambda (mv argN ... arg1)
             ((lambda (bvar1 ... bvarM argN ... arg1) matrix)
              (mv-nth '0 mv) ... (mv-nth 'M-1 mv) argN ... arg1))
     (witness arg1 ... argN) arg1 ... argN)
    })
    <p>
    if there are @('M') &gt; 1 bound variables,
    as resulting from the <see topic='@(url term)'>translation</see>
    of the @(tsee mv-let).
    </p>
  </li>
  </ul>
  <p>
  This @('defun-sk-retrieve-matrix') function should only be called
  when @('fun') is known to be a @(tsee defun-sk) function,
  as the code assumes without checking that the body of @('fun')
  has one of the forms above.
  </p>"
  (let* ((body (body fun nil w))
         (core (if non-executable
                   (car (last body))
                 body)))
    (if (eql (len bound-vars) 1)
        (case-match core
          (((& & matrix) . &) matrix)
          (& (raise "Unexpected body ~x0 of @(tsee defun-sk) function ~x1."
                    body fun)))
      (case-match core
        (((& & ((& & matrix) . &)) . &) matrix)
        (& (raise "Unexpected body ~x0 of @(tsee defun-sk) function ~x1."
                  body fun))))))

(define defun-sk-check ((fun (function-namep fun w))
                        (w plist-worldp))
  :returns (record? maybe-defun-sk-info-p)
  :prepwork ((program))
  :short
  "Check if the function @('fun') is a @(tsee defun-sk) function."
  :long
  "<p>
  If successful, return its @(tsee defun-sk)-specific constituents;
  if unsuccessful, return @('nil').
  </p>
  <p>
  The @('constraint-lst') property of the @(tsee defun-sk) function must be
  a single symbol that is the name of the associated witness function.
  Applying @('get-event') to the witness function must yield
  an @('encapsulate') of the form
  </p>
  @({
  (encapsulate
   (witness-signature)
   (local (in-theory '(implies)))
   (local (defchoose witness ...))
   (defthm witness-strengthening ...) ; optionally present
   (defun fun ...) ; or defun-nx
   (in-theory (disable (fun)))
   (defthm rewrite ...))
   (extend-pe-table ...)
  })
  <p>
  where @('witness-signature') is the signature of the witness function,
  @('witness') is the witness function,
  @('witness-strengthening') is the strengthening theorem
  (present iff @(':strengthen') is @('t')),
  @('fun') is the @(tsee defun-sk) function,
  and @('rewrite') is the associated rewrite rule.
  </p>"
  (b* ((args (formals fun w))
       (witness (getpropc fun 'constraint-lst nil w))
       ((unless (function-namep witness w)) nil)
       (event (get-event witness w))
       ((unless (and (or (tuplep 8 event)
                         (tuplep 9 event))
                     (eq (nth 0 event) 'encapsulate)
                     (equal (nth 2 event) '(local (in-theory '(implies))))
                     (equal (nth (- (len event) 3) event)
                            `(in-theory (disable (,fun))))))
        nil)
       (signatures (nth 1 event))
       (witness-def (nth 3 event))
       (function-def (nth (- (len event) 4) event))
       (rewrite (nth (- (len event) 2) event))
       ((unless (tuplep 1 signatures)) nil)
       (signature (car signatures))
       ((mv ok bound-vars classicalp)
        (defun-sk-check-signature signature witness args))
       ((unless ok) nil)
       ((mv ok witness-body strengthen)
        (defun-sk-check-witness-def witness-def witness bound-vars args))
       ((unless ok) nil)
       ((unless (implies strengthen
                         (defun-sk-check-strengthen-defthm
                          (nth 4 event)
                          witness
                          bound-vars
                          args
                          witness-body)))
        nil)
       ((mv ok untrans-matrix quantifier non-executable)
        (defun-sk-check-function-def
         function-def fun args witness witness-body bound-vars))
       ((unless ok) nil)
       ((mv ok rewrite-name rewrite-kind)
        (defun-sk-check-rewrite-rule
         rewrite fun args quantifier untrans-matrix witness))
       ((unless ok) nil)
       (matrix (defun-sk-retrieve-matrix fun bound-vars non-executable w)))
    (defun-sk-info quantifier
                   bound-vars
                   matrix
                   untrans-matrix
                   witness
                   rewrite-name
                   rewrite-kind
                   strengthen
                   non-executable
                   classicalp)))
