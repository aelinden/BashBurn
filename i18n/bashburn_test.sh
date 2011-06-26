#!/bin/bash
#
# This is a test file to test translation
# Editor: Markus Kollmar

# source in wrapper for "real" gettext:
. ./gettext.sh

# Instead of "echo" we use the wrapper "echo_translated":
echo_translated "Hello all"

exit 0
