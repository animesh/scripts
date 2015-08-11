#!/bin/sh
time blastz "$@" P=0
status=$?

# time time command usually mangles the status
# in some way.  try to recover.

if [ "$status" -gt 128 ]
then s=`expr "$status" - 128`
else s="$status"
fi

if [ $s -gt 0 ]
then
    case "`kill -l $s`" in
    *XCPU|*KILL)
    echo 1>&2 '

blastz CPU time limit exceeded.
To avoid running out of time, submit RepeatMasker output or use chaining.

'
    ;;
    esac
fi

exit $status
