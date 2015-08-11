#!/bin/sh
seq1=${1:?}
seq2=${2:?}
chain=${3:?}
strand=${4:?}
sensitivity=${5:?}

C=`f.int $chain` || exit 1
S=`f.int $strand` || exit 1
Y=`f.int $sensitivity` || exit 1

# T=`mktemp out.tmp.XXXXXX` || exit 1
T=out.tmp.$$.lav   # XXX - security

K3=3000
K2=2000
W=8
H=2200
m=`expr 80 \* 1024 \* 1024 `

# heuristic: if the sequence is not masked, then allow less time
# (alternatively, check for seq1mask file directly)
set -- `seq_len -m $seq1`
case $3 in
0) [ -f noquota ] || ulimit -t `expr 5 \* 60` # XXX - config
   H=0
   ;;
*) ;;
esac

case $Y in
0) ;;
*) K3=2000; K2=1600; W=5; H=0;
   [ -f noquota ] || ulimit -t `expr 5 \* 60`
   ;;  # XXX - config
esac

case $C in
3) timed_blastz "$seq1" "$seq2" Y=3400 H=$H W=$W B=$S K=$K3      m=$m >$T && single_cov $T;;
2) timed_blastz "$seq1" "$seq2" Y=3400 H=$H W=$W B=$S K=$K2 C=$C m=$m >$T && single_cov $T;;
1) echo "$0: chain=1 should not happen" 1>&2; exit 1;;
*) timed_blastz "$seq1" "$seq2" Y=3400 H=$H W=$W B=$S K=$K3 C=$C m=$m ;;
esac

