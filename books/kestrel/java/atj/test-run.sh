#!/bin/bash

################################################################################

# Java Library -- ATJ -- Tests -- Execution
#
# Copyright (C) 2018 Kestrel Institute (http://www.kestrel.edu)
#
# License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
#
# Author: Alessandro Coglio (coglio@kestrel.edu)

################################################################################

# This file runs the tests for the Java code generated by ATJ,
# collecting and printing time measurements.
# Commands similar to the ones below can be used to run different test inputs;
# see the Test*.java files (i.e. the test harnesses) for details on the inputs.

# The -Xss1G option to the JVM sets the stack size to 1GB.
# This is generally needed to avoid a stack overflow,
# because AIJ's recursive evaluation uses much more stack space
# than typical Java programs.

################################################################################

# stop on error:
set -e

# test the factorial function:
java -cp ../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G \
     TestFact 1 1000 5000 10000 50000 100000

# test the Fibonacci function:
java -cp ../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G \
     TestFib 1 10 20 30

# test the ABNF parser:
java -cp ../aij/java/out/artifacts/AIJ_jar/AIJ.jar:. -Xss1G \
     TestABNF 1 abnf.txt json.txt uri.txt http.txt imf.txt smtp.txt imap.txt
