#!/bin/sh
# distill ps to pdf using the current favorite method.

# be slient if $1 doesn't exist
test -f "$1" &&
  # exec distill -quiet -noprefs "$@"
  exec ps2pdf -dSAFER "$@"

exit 0
