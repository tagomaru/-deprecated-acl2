; Milawa - A Reflective Theorem Prover
; Copyright (C) 2005-2009 Kookamara LLC
;
; Contact:
;
;   Kookamara LLC
;   11410 Windermere Meadows
;   Austin, TX 78759, USA
;   http://www.kookamara.com/
;
; License: (An MIT/X11-style license)
;
;   Permission is hereby granted, free of charge, to any person obtaining a
;   copy of this software and associated documentation files (the "Software"),
;   to deal in the Software without restriction, including without limitation
;   the rights to use, copy, modify, merge, publish, distribute, sublicense,
;   and/or sell copies of the Software, and to permit persons to whom the
;   Software is furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in
;   all copies or substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;   DEALINGS IN THE SOFTWARE.
;
; Original author: Jared Davis <jared@kookamara.com>

(in-package "MILAWA")
(include-book "tracep")
(%interactive)

(%autoadmit rw.slow-flag-trace-arities)
(%autoadmit rw.slow-trace-arities)
(%autoadmit rw.slow-trace-list-arities)

(%autoprove definition-of-rw.slow-trace-arities
            (%restrict default rw.slow-flag-trace-arities (equal x 'x))
            (%enable default rw.slow-trace-list-arities rw.slow-trace-arities))

(%autoprove definition-of-rw.slow-trace-list-arities
            (%restrict default rw.slow-flag-trace-arities (equal x 'x))
            (%enable default rw.slow-trace-list-arities rw.slow-trace-arities))

(%autoprove rw.slow-trace-list-arities-when-not-consp
            (%restrict default definition-of-rw.slow-trace-list-arities (equal x 'x)))

(%autoprove rw.slow-trace-list-arities-of-cons
            (%restrict default definition-of-rw.slow-trace-list-arities (equal x '(cons a x))))


(%autoadmit rw.flag-trace-arities)
(%autoadmit rw.trace-arities)
(%autoadmit rw.trace-list-arities)

(%autoprove definition-of-rw.trace-arities
            (%enable default rw.trace-arities rw.trace-list-arities)
            (%restrict default rw.flag-trace-arities (equal x 'x)))

(%autoprove definition-of-rw.trace-list-arities
            (%enable default rw.trace-arities rw.trace-list-arities)
            (%restrict default rw.flag-trace-arities (equal x 'x)))

(%autoprove rw.flag-trace-arities-of-term
            (%enable default rw.trace-arities))

(%autoprove rw.flag-trace-arities-of-list
            (%enable default rw.trace-list-arities))

(%autoprove rw.trace-list-arities-when-not-consp
            (%restrict default definition-of-rw.trace-list-arities (equal x 'x)))

(%autoprove rw.trace-list-arities-of-cons
            (%restrict default definition-of-rw.trace-list-arities (equal x '(cons a x))))

(%autoprove lemma-for-true-listp-of-rw.trace-arities
            (%autoinduct rw.flag-trace-arities flag x acc)
            (%restrict default definition-of-rw.trace-arities (equal x 'x)))

(%autoprove true-listp-of-rw.trace-arities
            (%use (%instance (%thm lemma-for-true-listp-of-rw.trace-arities)
                             (flag 'term))))

(%autoprove true-listp-of-rw.trace-list-arities
            (%use (%instance (%thm lemma-for-true-listp-of-rw.trace-arities)
                             (flag 'list))))

(%autoprove lemma-for-rw.trace-arities-removal
            (%autoinduct rw.flag-trace-arities flag x acc)
            (%restrict default definition-of-rw.trace-arities (equal x 'x))
            (%restrict default definition-of-rw.slow-trace-arities (equal x 'x)))

(%autoprove rw.trace-arities-removal
            (%use (%instance (%thm lemma-for-rw.trace-arities-removal)
                             (flag 'term))))

(%autoprove rw.trace-list-arities-removal
            (%use (%instance (%thm lemma-for-rw.trace-arities-removal)
                             (flag 'list))))

(%autoprove lemma-for-rw.slow-trace-arities-correct
            (%rw.trace-induction flag x)
            (%forcingp nil)
            (%restrict default definition-of-rw.slow-trace-arities (equal x 'x))
            (%restrict default definition-of-rw.trace-atblp (equal x 'x)))

(%autoprove rw.slow-trace-arities-correct
            (%use (%instance (%thm lemma-for-rw.slow-trace-arities-correct)
                             (flag 'term))))

(%autoprove rw.slow-trace-list-arities-correct
            (%use (%instance (%thm lemma-for-rw.slow-trace-arities-correct)
                             (flag 'list))))

(%autoadmit rw.fast-trace-atblp)

(%autoprove rw.fast-trace-atblp-removal
            (%enable default rw.fast-trace-atblp))


(%autoadmit rw.fast-trace-list-atblp)

(%autoprove rw.fast-trace-list-atblp-removal
            (%enable default rw.fast-trace-list-atblp))




(%autoadmit rw.slow-flag-eqtrace-arities)
(%autoadmit rw.slow-eqtrace-arities)
(%autoadmit rw.slow-eqtrace-list-arities)

(%autoprove definition-of-rw.slow-eqtrace-arities
            (%restrict default rw.slow-flag-eqtrace-arities (equal x 'x))
            (%enable default rw.slow-eqtrace-list-arities rw.slow-eqtrace-arities))

(%autoprove definition-of-rw.slow-eqtrace-list-arities
            (%restrict default rw.slow-flag-eqtrace-arities (equal x 'x))
            (%enable default rw.slow-eqtrace-list-arities rw.slow-eqtrace-arities))

(%autoprove rw.slow-eqtrace-list-arities-when-not-consp
            (%restrict default definition-of-rw.slow-eqtrace-list-arities (equal x 'x)))

(%autoprove rw.slow-eqtrace-list-arities-of-cons
            (%restrict default definition-of-rw.slow-eqtrace-list-arities (equal x '(cons a x))))


(%autoadmit rw.flag-eqtrace-arities)
(%autoadmit rw.eqtrace-arities)
(%autoadmit rw.eqtrace-list-arities)

(%autoprove definition-of-rw.eqtrace-arities
            (%restrict default rw.flag-eqtrace-arities (equal x 'x))
            (%enable default rw.eqtrace-arities rw.eqtrace-list-arities))

(%autoprove definition-of-rw.eqtrace-list-arities
            (%restrict default rw.flag-eqtrace-arities (equal x 'x))
            (%enable default rw.eqtrace-arities rw.eqtrace-list-arities))

(%autoprove rw.flag-eqtrace-arities-of-trace
            (%enable default rw.eqtrace-arities))

(%autoprove rw.flag-eqtrace-arities-of-list
            (%enable default rw.eqtrace-list-arities))

(%autoprove rw.eqtrace-list-arities-when-not-consp
            (%restrict default definition-of-rw.eqtrace-list-arities (equal x 'x)))

(%autoprove rw.eqtrace-list-arities-of-cons
            (%restrict default definition-of-rw.eqtrace-list-arities (equal x '(cons a x))))

(%autoprove lemma-for-true-listp-of-rw.eqtrace-arities
            (%autoinduct rw.flag-eqtrace-arities flag x acc)
            (%restrict default definition-of-rw.eqtrace-arities (equal x 'x)))

(%autoprove true-listp-of-rw.eqtrace-arities
            (%use (%instance (%thm lemma-for-true-listp-of-rw.eqtrace-arities)
                             (flag 'trace))))

(%autoprove true-listp-of-rw.eqtrace-list-arities
            (%use (%instance (%thm lemma-for-true-listp-of-rw.eqtrace-arities)
                             (flag 'list))))

(%autoprove lemma-for-rw.eqtrace-arities-removal
            (%autoinduct rw.flag-eqtrace-arities flag x acc)
            (%restrict default definition-of-rw.eqtrace-arities (equal x 'x))
            (%restrict default definition-of-rw.slow-eqtrace-arities (equal x 'x)))

(%autoprove rw.eqtrace-arities-removal
            (%use (%instance (%thm lemma-for-rw.eqtrace-arities-removal)
                             (flag 'trace))))

(%autoprove rw.eqtrace-list-arities-removal
            (%use (%instance (%thm lemma-for-rw.eqtrace-arities-removal)
                             (flag 'list))))

(%autoprove lemma-for-rw.slow-eqtrace-arities-correct
            (%autoinduct rw.flag-eqtrace-atblp flag x atbl)
            (%forcingp nil)
            (%restrict default definition-of-rw.eqtrace-atblp (equal x 'x))
            (%restrict default definition-of-rw.slow-eqtrace-arities (equal x 'x)))

(%autoprove rw.slow-eqtrace-arities-correct
            (%use (%instance (%thm lemma-for-rw.slow-eqtrace-arities-correct)
                             (flag 'trace))))

(%autoprove rw.slow-eqtrace-list-arities-correct
            (%use (%instance (%thm lemma-for-rw.slow-eqtrace-arities-correct)
                             (flag 'list))))




(%autoadmit rw.slow-faster-flag-trace-arities)
(%autoadmit rw.slow-faster-trace-arities)
(%autoadmit rw.slow-faster-trace-list-arities)

(%autoprove definition-of-rw.slow-faster-trace-arities
            (%restrict default rw.slow-faster-flag-trace-arities (equal x 'x))
            (%enable default rw.slow-faster-trace-arities rw.slow-faster-trace-list-arities))

(%autoprove definition-of-rw.slow-faster-trace-list-arities
            (%restrict default rw.slow-faster-flag-trace-arities (equal x 'x))
            (%enable default rw.slow-faster-trace-arities rw.slow-faster-trace-list-arities))

(%autoprove rw.slow-faster-flag-trace-arities-of-term
            (%enable default rw.slow-faster-trace-arities))

(%autoprove rw.slow-faster-flag-trace-arities-of-list
            (%enable default rw.slow-faster-trace-list-arities))

(%autoprove rw.slow-faster-trace-list-arities-when-not-consp
            (%restrict default definition-of-rw.slow-faster-trace-list-arities (equal x 'x)))

(%autoprove rw.slow-faster-trace-list-arities-of-cons
            (%restrict default definition-of-rw.slow-faster-trace-list-arities (equal x '(cons a x))))

(%autoprove lemma-for-rw.slow-faster-trace-arities-correct
            (%autoinduct rw.slow-faster-flag-trace-arities flag x hypbox)
            (%forcingp nil)
            (%restrict default definition-of-rw.slow-faster-trace-arities (equal x 'x))
            (%restrict default definition-of-rw.trace-atblp (equal x 'x)))

(%autoprove rw.slow-faster-trace-arities-correct
            (%use (%instance (%thm lemma-for-rw.slow-faster-trace-arities-correct)
                             (flag 'term))))

(%autoprove rw.slow-faster-trace-list-arities-correct
            (%use (%instance (%thm lemma-for-rw.slow-faster-trace-arities-correct)
                             (flag 'list))))


(%autoadmit rw.faster-flag-trace-arities)
(%autoadmit rw.faster-trace-arities)
(%autoadmit rw.faster-trace-list-arities)

(%autoprove definition-of-rw.faster-trace-arities
            (%restrict default rw.faster-flag-trace-arities (equal x 'x))
            (%enable default rw.faster-trace-arities rw.faster-trace-list-arities))

(%autoprove definition-of-rw.faster-trace-list-arities
            (%restrict default rw.faster-flag-trace-arities (equal x 'x))
            (%enable default rw.faster-trace-arities rw.faster-trace-list-arities))

(%autoprove rw.faster-flag-trace-arities-of-term
            (%enable default rw.faster-trace-arities))

(%autoprove rw.faster-flag-trace-arities-of-list
            (%enable default rw.faster-trace-list-arities))

(%autoprove rw.faster-trace-list-arities-when-not-consp
            (%restrict default definition-of-rw.faster-trace-list-arities (equal x 'x)))

(%autoprove rw.faster-trace-list-arities-of-cons
            (%restrict default definition-of-rw.faster-trace-list-arities (equal x '(cons a x))))

(%autoprove lemma-for-true-listp-of-rw.faster-trace-arities
            (%autoinduct rw.faster-flag-trace-arities flag x ext-hypbox acc)
            (%restrict default definition-of-rw.faster-trace-arities (equal x 'x))
            (%restrict default definition-of-rw.slow-faster-trace-arities (equal x 'x)))

(%autoprove true-listp-of-rw.faster-trace-arities
            (%use (%instance (%thm lemma-for-true-listp-of-rw.faster-trace-arities)
                             (flag 'term))))

(%autoprove true-listp-of-rw.faster-trace-list-arities
            (%use (%instance (%thm lemma-for-true-listp-of-rw.faster-trace-arities)
                             (flag 'list))))

(%autoprove lemma-for-rw.faster-trace-arities-removal
            (%autoinduct rw.faster-flag-trace-arities flag x ext-hypbox acc)
            (%restrict default definition-of-rw.faster-trace-arities (equal x 'x))
            (%restrict default definition-of-rw.slow-faster-trace-arities (equal x 'x)))

(%autoprove rw.faster-trace-arities-removal
            (%use (%instance (%thm lemma-for-rw.faster-trace-arities-removal)
                             (flag 'term))))

(%autoprove rw.faster-trace-list-arities-removal
            (%use (%instance (%thm lemma-for-rw.faster-trace-arities-removal)
                             (flag 'list))))


(%ensure-exactly-these-rules-are-missing "../../rewrite/traces/trace-arities")











