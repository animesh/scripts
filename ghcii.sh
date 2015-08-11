#!/bin/sh
exec "$0"/../ghc --interactive ${1+"$@"}
