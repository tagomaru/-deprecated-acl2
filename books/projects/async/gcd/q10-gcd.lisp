;; Copyright (C) 2017, Regents of the University of Texas
;; Written by Cuong Chau
;; License: A 3-clause BSD license.  See the LICENSE file distributed with
;; ACL2.

;; Cuong Chau <ckcuong@cs.utexas.edu>
;; December 2018

(in-package "ADE")

(include-book "gcd")
(include-book "../fifo/queue10")

(local (include-book "arithmetic-3/top" :dir :system))

(local (in-theory (disable nth)))

;; ======================================================================

;;; Table of Contents:
;;;
;;; 1. DE Module Generator of Q10-GCD
;;; 2. Multi-Step State Lemma
;;; 3. Single-Step-Update Property
;;; 4. Relationship Between the Input and Output Sequences

;; ======================================================================

;; 1. DE Module Generator of Q10-GCD
;;
;; Construct a DE module generator that concatenates Q10 with GCD via a link.
;; Prove the value and state lemmas for this module generator.

(defconst *q10-gcd$go-num* (+ *queue10$go-num*
                              *gcd$go-num*))
(defconst *q10-gcd$st-len* 3)

(defun q10-gcd$data-ins-len (data-size)
  (declare (xargs :guard (natp data-size)))
  (+ 2 (* 2 (mbe :logic (nfix data-size)
                 :exec  data-size))))

(defun q10-gcd$ins-len (data-size)
  (declare (xargs :guard (natp data-size)))
  (+ (q10-gcd$data-ins-len data-size)
     *q10-gcd$go-num*))

;; DE module generator of Q10-GCD

(module-generator
 q10-gcd* (data-size)
 (si 'q10-gcd data-size)
 (list* 'full-in 'empty-out- (append (sis 'data-in 0 (* 2 data-size))
                                     (sis 'go 0 *q10-gcd$go-num*)))
 (list* 'in-act 'out-act
        (sis 'data-out 0 data-size))
 '(l q10 gcd)
 (list
  ;; LINK
  ;; L
  (list 'l
        (list* 'l-status (sis 'd-out 0 (* 2 data-size)))
        (si 'link (* 2 data-size))
        (list* 'q10-out-act 'gcd-in-act
               (sis 'q10-data-out 0 (* 2 data-size))))

  ;; JOINTS
  ;; Q10
  (list 'q10
        (list* 'in-act 'q10-out-act
               (sis 'q10-data-out 0 (* 2 data-size)))
        (si 'queue10 (* 2 data-size))
        (list* 'full-in 'l-status
               (append (sis 'data-in 0 (* 2 data-size))
                       (sis 'go 0 *queue10$go-num*))))

  ;; GCD
  (list 'gcd
        (list* 'gcd-in-act 'out-act
               (sis 'data-out 0 data-size))
        (si 'gcd data-size)
        (list* 'l-status 'empty-out-
               (append (sis 'd-out 0 (* 2 data-size))
                       (sis 'go
                            *queue10$go-num*
                            *gcd$go-num*)))))

 (declare (xargs :guard (natp data-size))))

(make-event
 `(progn
    ,@(state-accessors-gen 'q10-gcd '(l q10 gcd) 0)))

;; DE netlist generator.  A generated netlist will contain an instance of
;; Q10-GCD.

(defund q10-gcd$netlist (data-size)
  (declare (xargs :guard (and (natp data-size)
                              (<= 2 data-size))))
  (cons (q10-gcd* data-size)
        (union$ (queue10$netlist (* 2 data-size))
                (gcd$netlist data-size)
                :test 'equal)))

;; Recognizer for Q10-GCD

(defund q10-gcd& (netlist data-size)
  (declare (xargs :guard (and (alistp netlist)
                              (natp data-size)
                              (<= 2 data-size))))
  (b* ((subnetlist (delete-to-eq (si 'q10-gcd data-size) netlist)))
    (and (equal (assoc (si 'q10-gcd data-size) netlist)
                (q10-gcd* data-size))
         (link& subnetlist (* 2 data-size))
         (queue10& subnetlist (* 2 data-size))
         (gcd& subnetlist data-size))))

;; Sanity check

(local
 (defthmd check-q10-gcd$netlist-64
   (and (net-syntax-okp (q10-gcd$netlist 64))
        (net-arity-okp (q10-gcd$netlist 64))
        (q10-gcd& (q10-gcd$netlist 64) 64))))

;; Constraints on the state of Q10-GCD

(defund q10-gcd$st-format (st data-size)
  (b* ((l   (get-field *q10-gcd$l* st))
       (q10  (get-field *q10-gcd$q10* st))
       (gcd (get-field *q10-gcd$gcd* st)))
    (and (link$st-format l (* 2 data-size))
         (queue10$st-format q10 (* 2 data-size))
         (gcd$st-format gcd data-size))))

(defthm q10-gcd$st-format=>constraint
  (implies (q10-gcd$st-format st data-size)
           (and (natp data-size)
                (<= 3 data-size)))
  :hints (("Goal"
           :in-theory (enable q10-gcd$st-format)))
  :rule-classes :forward-chaining)

(defund q10-gcd$valid-st (st data-size)
  (b* ((l   (get-field *q10-gcd$l* st))
       (q10  (get-field *q10-gcd$q10* st))
       (gcd (get-field *q10-gcd$gcd* st)))
    (and (link$valid-st l (* 2 data-size))
         (queue10$valid-st q10 (* 2 data-size))
         (gcd$valid-st gcd data-size))))

(defthmd q10-gcd$valid-st=>constraint
  (implies (q10-gcd$valid-st st data-size)
           (and (natp data-size)
                (<= 3 data-size)))
  :hints (("Goal"
           :in-theory (enable gcd$valid-st=>constraint
                              q10-gcd$valid-st)))
  :rule-classes :forward-chaining)

(defthmd q10-gcd$valid-st=>st-format
  (implies (q10-gcd$valid-st st data-size)
           (q10-gcd$st-format st data-size))
  :hints (("Goal" :in-theory (e/d (queue10$valid-st=>st-format
                                   gcd$valid-st=>st-format
                                   q10-gcd$st-format
                                   q10-gcd$valid-st)
                                  (link$st-format)))))

;; Extract the input and output signals for Q10-GCD

(progn
  ;; Extract the input data

  (defun q10-gcd$data-in (inputs data-size)
    (declare (xargs :guard (and (true-listp inputs)
                                (natp data-size))))
    (take (* 2 (mbe :logic (nfix data-size)
                    :exec  data-size))
          (nthcdr 2 inputs)))

  (defthm len-q10-gcd$data-in
    (equal (len (q10-gcd$data-in inputs data-size))
           (* 2 (nfix data-size))))

  (in-theory (disable q10-gcd$data-in))

  ;; Extract the inputs for the Q10 joint

  (defund q10-gcd$q10-inputs (inputs st data-size)
    (b* ((full-in (nth 0 inputs))
         (data-in (q10-gcd$data-in inputs data-size))
         (go-signals (nthcdr (q10-gcd$data-ins-len data-size) inputs))

         (q10-go-signals (take *queue10$go-num* go-signals))

         (l (get-field *q10-gcd$l* st))
         (l.s (get-field *link$s* l)))

      (list* full-in (f-buf (car l.s))
             (append data-in q10-go-signals))))

  ;; Extract the inputs for the GCD joint

  (defund q10-gcd$gcd-inputs (inputs st data-size)
    (b* ((empty-out- (nth 1 inputs))
         (go-signals (nthcdr (q10-gcd$data-ins-len data-size) inputs))

         (gcd-go-signals (take *gcd$go-num*
                               (nthcdr *queue10$go-num* go-signals)))

         (l (get-field *q10-gcd$l* st))
         (l.s (get-field *link$s* l))
         (l.d (get-field *link$d* l)))

      (list* (f-buf (car l.s)) empty-out-
             (append (v-threefix (strip-cars l.d))
                     gcd-go-signals))))

  ;; Extract the "in-act" signal

  (defund q10-gcd$in-act (inputs st data-size)
    (queue10$in-act (q10-gcd$q10-inputs inputs st data-size)
                    (get-field *q10-gcd$q10* st)
                    (* 2 data-size)))

  (defthm q10-gcd$in-act-inactive
    (implies (not (nth 0 inputs))
             (not (q10-gcd$in-act inputs st data-size)))
    :hints (("Goal" :in-theory (enable q10-gcd$q10-inputs
                                       q10-gcd$in-act))))

  ;; Extract the "out-act" signal

  (defund q10-gcd$out-act (inputs st data-size)
    (gcd$out-act (q10-gcd$gcd-inputs inputs st data-size)
                 (get-field *q10-gcd$gcd* st)
                 data-size))

  (defthm q10-gcd$out-act-inactive
    (implies (equal (nth 1 inputs) t)
             (not (q10-gcd$out-act inputs st data-size)))
    :hints (("Goal" :in-theory (enable q10-gcd$gcd-inputs
                                       q10-gcd$out-act))))

  ;; Extract the output data

  (defund q10-gcd$data-out (inputs st data-size)
    (gcd$data-out (q10-gcd$gcd-inputs inputs st data-size)
                  (get-field *q10-gcd$gcd* st)
                  data-size))

  (defthm len-q10-gcd$data-out-1
    (implies (q10-gcd$st-format st data-size)
             (equal (len (q10-gcd$data-out inputs st data-size))
                    data-size))
    :hints (("Goal" :in-theory (enable q10-gcd$st-format
                                       q10-gcd$data-out))))

  (defthm len-q10-gcd$data-out-2
    (implies (q10-gcd$valid-st st data-size)
             (equal (len (q10-gcd$data-out inputs st data-size))
                    data-size))
    :hints (("Goal" :in-theory (enable q10-gcd$valid-st
                                       q10-gcd$data-out))))

  (defthm bvp-q10-gcd$data-out
    (implies (and (q10-gcd$valid-st st data-size)
                  (q10-gcd$out-act inputs st data-size))
             (bvp (q10-gcd$data-out inputs st data-size)))
    :hints (("Goal" :in-theory (enable q10-gcd$valid-st
                                       q10-gcd$out-act
                                       q10-gcd$data-out))))

  (defun q10-gcd$outputs (inputs st data-size)
    (list* (q10-gcd$in-act inputs st data-size)
           (q10-gcd$out-act inputs st data-size)
           (q10-gcd$data-out inputs st data-size)))
  )

;; The value lemma for Q10-GCD

(defthm q10-gcd$value
  (b* ((inputs (list* full-in empty-out- (append data-in go-signals))))
    (implies (and (q10-gcd& netlist data-size)
                  (true-listp data-in)
                  (equal (len data-in) (* 2 data-size))
                  (true-listp go-signals)
                  (equal (len go-signals) *q10-gcd$go-num*)
                  (q10-gcd$st-format st data-size))
             (equal (se (si 'q10-gcd data-size) inputs st netlist)
                    (q10-gcd$outputs inputs st data-size))))
  :hints (("Goal"
           :do-not-induct t
           :expand (:free (inputs data-size)
                          (se (si 'q10-gcd data-size) inputs st netlist))
           :in-theory (e/d (de-rules
                            q10-gcd&
                            q10-gcd*$destructure
                            q10-gcd$data-in
                            q10-gcd$st-format
                            q10-gcd$in-act
                            q10-gcd$out-act
                            q10-gcd$data-out
                            q10-gcd$q10-inputs
                            q10-gcd$gcd-inputs)
                           (de-module-disabled-rules)))))

;; This function specifies the next state of Q10-GCD.

(defun q10-gcd$step (inputs st data-size)
  (b* ((l   (get-field *q10-gcd$l* st))
       (q10  (get-field *q10-gcd$q10* st))
       (gcd (get-field *q10-gcd$gcd* st))

       (q10-inputs (q10-gcd$q10-inputs inputs st data-size))
       (gcd-inputs (q10-gcd$gcd-inputs inputs st data-size))

       (d-in (queue10$data-out q10))

       (q10-out-act (queue10$out-act q10-inputs q10 (* 2 data-size)))
       (gcd-in-act (gcd$in-act gcd-inputs gcd data-size))

       (l-inputs (list* q10-out-act gcd-in-act d-in)))
    (list
     ;; L
     (link$step l-inputs l (* 2 data-size))
     ;; Joint Q10
     (queue10$step q10-inputs q10 (* 2 data-size))
     ;; Joint GCD
     (gcd$step gcd-inputs gcd data-size))))

(defthm len-of-q10-gcd$step
  (equal (len (q10-gcd$step inputs st data-size))
         *q10-gcd$st-len*))

;; The state lemma for Q10-GCD

(defthm q10-gcd$state
  (b* ((inputs (list* full-in empty-out- (append data-in go-signals))))
    (implies (and (q10-gcd& netlist data-size)
                  (true-listp data-in)
                  (equal (len data-in) (* 2 data-size))
                  (true-listp go-signals)
                  (equal (len go-signals) *q10-gcd$go-num*)
                  (q10-gcd$st-format st data-size))
             (equal (de (si 'q10-gcd data-size) inputs st netlist)
                    (q10-gcd$step inputs st data-size))))
  :hints (("Goal"
           :do-not-induct t
           :expand (:free (inputs data-size)
                          (de (si 'q10-gcd data-size) inputs st netlist))
           :in-theory (e/d (de-rules
                            q10-gcd&
                            q10-gcd*$destructure
                            q10-gcd$st-format
                            q10-gcd$data-in
                            q10-gcd$data-out
                            q10-gcd$q10-inputs
                            q10-gcd$gcd-inputs)
                           (de-module-disabled-rules)))))

(in-theory (disable q10-gcd$step))

;; ======================================================================

;; 2. Multi-Step State Lemma

;; Conditions on the inputs

(defund q10-gcd$input-format (inputs data-size)
  (declare (xargs :guard (and (true-listp inputs)
                              (natp data-size))))
  (b* ((full-in    (nth 0 inputs))
       (empty-out- (nth 1 inputs))
       (data-in    (q10-gcd$data-in inputs data-size))
       (go-signals (nthcdr (q10-gcd$data-ins-len data-size) inputs)))
    (and
     (booleanp full-in)
     (booleanp empty-out-)
     (or (not full-in) (bvp data-in))
     (true-listp go-signals)
     (= (len go-signals) *q10-gcd$go-num*)
     (equal inputs
            (list* full-in empty-out- (append data-in go-signals))))))

(local
 (defthm q10-gcd$input-format=>q10$input-format
   (implies (and (q10-gcd$input-format inputs data-size)
                 (q10-gcd$valid-st st data-size))
            (queue10$input-format
             (q10-gcd$q10-inputs inputs st data-size)
             (* 2 data-size)))
   :hints (("Goal"
            :in-theory (e/d (q10-gcd$input-format
                             gcd$valid-st=>constraint
                             queue10$input-format
                             queue10$data-in
                             q10-gcd$valid-st
                             q10-gcd$q10-inputs)
                            ())))))

(local
 (defthm q10-gcd$input-format=>gcd$input-format
   (implies (and (q10-gcd$input-format inputs data-size)
                 (q10-gcd$valid-st st data-size))
            (gcd$input-format
             (q10-gcd$gcd-inputs inputs st data-size)
             data-size))
   :hints (("Goal"
            :in-theory (e/d (q10-gcd$input-format
                             gcd$valid-st=>constraint
                             gcd$input-format
                             gcd$data-in
                             q10-gcd$valid-st
                             q10-gcd$st-format
                             q10-gcd$gcd-inputs)
                            ())))))

(defthm booleanp-q10-gcd$in-act
  (implies (and (q10-gcd$input-format inputs data-size)
                (q10-gcd$valid-st st data-size))
           (booleanp (q10-gcd$in-act inputs st data-size)))
  :hints (("Goal"
           :in-theory (enable q10-gcd$valid-st
                              q10-gcd$in-act)))
  :rule-classes (:rewrite :type-prescription))

(defthm booleanp-q10-gcd$out-act
  (implies (and (q10-gcd$input-format inputs data-size)
                (q10-gcd$valid-st st data-size))
           (booleanp (q10-gcd$out-act inputs st data-size)))
  :hints (("Goal"
           :in-theory (enable q10-gcd$valid-st
                              q10-gcd$out-act)))
  :rule-classes (:rewrite :type-prescription))

(simulate-lemma q10-gcd)

;; ======================================================================

;; 3. Single-Step-Update Property

;; The extraction function for Q10-GCD that extracts the future output sequence
;; from the current state.

(defund q10-gcd$extract (st)
  (b* ((l   (get-field *q10-gcd$l* st))
       (q10  (get-field *q10-gcd$q10* st))
       (gcd (get-field *q10-gcd$gcd* st)))
    (append
     (gcd$op-map
      (append (queue10$extract q10)
              (extract-valid-data (list l))))
     (gcd$extract gcd))))

(defthm q10-gcd$extract-not-empty
  (implies (and (q10-gcd$out-act inputs st data-size)
                (q10-gcd$valid-st st data-size))
           (< 0 (len (q10-gcd$extract st))))
  :hints (("Goal"
           :in-theory (e/d (q10-gcd$valid-st
                            q10-gcd$extract
                            q10-gcd$out-act)
                           ())))
  :rule-classes :linear)

;; Specify and prove a state invariant

(progn
  (defund q10-gcd$inv (st)
    (b* ((gcd (get-field *q10-gcd$gcd* st)))
      (gcd$inv gcd)))

  (defthm q10-gcd$inv-preserved
    (implies (and (q10-gcd$input-format inputs data-size)
                  (q10-gcd$valid-st st data-size)
                  (q10-gcd$inv st))
             (q10-gcd$inv (q10-gcd$step inputs st data-size)))
    :hints (("Goal"
             :in-theory (e/d (get-field
                              q10-gcd$valid-st
                              q10-gcd$inv
                              q10-gcd$step)
                             ()))))
  )

;; The extracted next-state function for Q10-GCD.  Note that this function
;; avoids exploring the internal computation of Q10-GCD.

(defund q10-gcd$extracted-step (inputs st data-size)
  (b* ((data (gcd$op (q10-gcd$data-in inputs data-size)))
       (extracted-st (q10-gcd$extract st))
       (n (1- (len extracted-st))))
    (cond
     ((equal (q10-gcd$out-act inputs st data-size) t)
      (cond
       ((equal (q10-gcd$in-act inputs st data-size) t)
        (cons data (take n extracted-st)))
       (t (take n extracted-st))))
     (t (cond
         ((equal (q10-gcd$in-act inputs st data-size) t)
          (cons data extracted-st))
         (t extracted-st))))))

;; The single-step-update property

(progn
  (local
   (defthm q10-gcd$q10-out-act-inactive
     (implies (equal (nth *link$s*
                          (nth *q10-gcd$l* st))
                     '(t))
              (not (queue10$out-act (q10-gcd$q10-inputs inputs st data-size)
                                    (nth *q10-gcd$q10* st)
                                    (* 2 data-size))))
     :hints (("Goal"
              :in-theory (e/d (get-field
                               q10-gcd$q10-inputs)
                              ())))))

  (local
   (defthm q10-gcd$gcd-in-act-inactive
     (implies (equal (nth *link$s*
                          (nth *q10-gcd$l* st))
                     '(nil))
              (not (gcd$in-act (q10-gcd$gcd-inputs inputs st data-size)
                               (nth *q10-gcd$gcd* st)
                               data-size)))
     :hints (("Goal"
              :in-theory (e/d (get-field
                               q10-gcd$gcd-inputs)
                              ())))))

  (local
   (defthm q10-gcd-aux-1
     (b* ((q10-inputs (q10-gcd$q10-inputs inputs st data-size)))
       (implies (natp data-size)
                (equal (queue10$data-in q10-inputs (* 2 data-size))
                       (take (* 2 data-size)
                             (nthcdr 2 inputs)))))
     :hints (("Goal" :in-theory (enable q10-gcd$q10-inputs
                                        q10-gcd$data-in
                                        queue10$data-in)))))

  (local
   (defthm q10-gcd-aux-2
     (b* ((gcd-inputs (q10-gcd$gcd-inputs inputs st data-size))
          (l (nth *q10-gcd$l* st))
          (l.d (nth *link$d* l)))
       (implies (and (natp data-size)
                     (equal (len l.d) (* 2 data-size))
                     (bvp (strip-cars l.d)))
                (equal (gcd$data-in gcd-inputs data-size)
                       (strip-cars l.d))))
     :hints (("Goal" :in-theory (enable get-field
                                        q10-gcd$gcd-inputs
                                        gcd$data-in)))))

  (local
   (defthm gcd$op-map-of-append-instance
     (equal (gcd$op-map (append x (list (strip-cars d))))
            (append (gcd$op-map x)
                    (gcd$op-map (list (strip-cars d)))))))

  (defthm q10-gcd$extracted-step-correct
    (b* ((next-st (q10-gcd$step inputs st data-size)))
      (implies (and (q10-gcd$input-format inputs data-size)
                    (q10-gcd$valid-st st data-size)
                    (q10-gcd$inv st))
               (equal (q10-gcd$extract next-st)
                      (q10-gcd$extracted-step inputs st data-size))))
    :hints (("Goal"
             :use (q10-gcd$input-format=>q10$input-format
                   q10-gcd$input-format=>gcd$input-format)
             :in-theory (e/d (get-field
                              f-sr
                              gcd$valid-st=>constraint
                              queue10$extracted-step
                              gcd$extracted-step
                              q10-gcd$extracted-step
                              q10-gcd$valid-st
                              q10-gcd$inv
                              q10-gcd$step
                              q10-gcd$data-in
                              q10-gcd$in-act
                              q10-gcd$out-act
                              q10-gcd$data-out
                              q10-gcd$extract)
                             (q10-gcd$input-format=>q10$input-format
                              q10-gcd$input-format=>gcd$input-format
                              gcd$op-map-of-append
                              nfix)))))
  )

;; ======================================================================

;; 4. Relationship Between the Input and Output Sequences

;; Prove that q10-gcd$valid-st is an invariant.

(defthm q10-gcd$valid-st-preserved
  (implies (and (q10-gcd$input-format inputs data-size)
                (q10-gcd$valid-st st data-size))
           (q10-gcd$valid-st (q10-gcd$step inputs st data-size)
                            data-size))
  :hints (("Goal"
           :use (q10-gcd$input-format=>q10$input-format
                 q10-gcd$input-format=>gcd$input-format)
           :in-theory (e/d (get-field
                            f-sr
                            q10-gcd$valid-st
                            q10-gcd$step)
                           (q10-gcd$input-format=>q10$input-format
                            q10-gcd$input-format=>gcd$input-format)))))

(defthm q10-gcd$extract-lemma
  (implies (and (q10-gcd$valid-st st data-size)
                (q10-gcd$out-act inputs st data-size))
           (equal (list (q10-gcd$data-out inputs st data-size))
                  (nthcdr (1- (len (q10-gcd$extract st)))
                          (q10-gcd$extract st))))
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d (q10-gcd$valid-st
                            q10-gcd$extract
                            q10-gcd$out-act
                            q10-gcd$data-out)
                           ()))))

;; Extract the accepted input sequence

(seq-gen q10-gcd in in-act 0
         (q10-gcd$data-in inputs data-size))

;; Extract the valid output sequence

(seq-gen q10-gcd out out-act 1
         (q10-gcd$data-out inputs st data-size)
         :netlist-data (nthcdr 2 outputs))

;; The multi-step input-output relationship

(in-out-stream-lemma q10-gcd :op gcd$op :inv t)

