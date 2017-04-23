#!/bin/sh
mask=${1:?}
case "`head -1 $mask`" in
'%:repeats'*) rpts-lint $mask ;;
*)            repeats_tag $mask ;;
esac
