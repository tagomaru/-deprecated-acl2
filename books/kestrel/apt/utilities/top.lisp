; APT (Automated Program Transformations) Library
;
; Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "APT")

(include-book "print-specifiers")
(include-book "untranslate-specifiers")
(include-book "transformation-table")
(include-book "pattern-matching")
(include-book "pattern-matching-ext")
(include-book "xdoc-constructors")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defxdoc utilities
  :parents (implementation)
  :short "Utilities shared by the implementations of the APT tools.")
