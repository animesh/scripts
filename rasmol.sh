#!/bin/sh
# rasmol.sh
# RasMol Molecular Graphics
# Roger Sayle, August 1995
# Version 2.6

#
# Example Environment Variables
#

RASMOLPATH=/usr/local/lib/rasmol
export RASMOLPATH

RASMOLPDBPATH=/databases/pdb
export RASMOLPDBPATH

#
# Example of multi-platform support
#

case `uname -s` in
IRIX)
    IRIXVERSION=`uname -r | cut -f1 -d.`
    if [ $IRIXVERSION = 4 ]; then
        $RASMOLPATH/rasmol.sg4 $*
    else
        $RASMOLPATH/rasmol.sg5 $*
    fi
    ;;

SunOS)
    SUNOSVERSION=`uname -r | cut -f1 -d.`
    if [ $SUNOSVERSION = 4 ]; then
        $RASMOLPATH/rasmol.su4 $*
    else
        $RASMOLPATH/rasmol.su5 $*
    fi
    ;;

ULTRIX)
    $RASMOLPATH/rasmol.dec $*
    ;;

OSF1)
    MACHINE=`uname -m`
    if [ $MACHINE = "alpha" ]; then
        $RASMOLPATH/rasmol.axp $*
    else
        echo "Unsupported architecture" 2>&1
        exit 1
    fi
    ;;

*)
    MACHINE=`uname -m`
    if [ $MACHINE = "mips" ]; then
        $RASMOLPATH/rasmol.esv $*
    else
        echo "Unsupported architecture" 2>&1
        exit 1
    fi
    ;;
esac

