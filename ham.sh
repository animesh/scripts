#!/bin/bash
#
# Takes input on STDIN.  Each line specifies the name of a vertex
# (first word on the line) and the set of vertices it has edges to (remaining
# words on the line.)
#

function echoerr { echo "$@" 1>&2; }
function debug {
#    echoerr $@
    true
}

function ham
{
    read VERTEX EDGES

    REST=$(cat)
    debug V=${VERTEX} E='"'${EDGES}'"' $@ $(echo -e "${REST}" | tr '\n' ,)

    if [[ -n "${REST}" ]]; then
	for i in ${EDGES}
	do
	    if [[ "${VERTEX}" != "$i" ]]; then
		echo -e "${REST}" | \
                    sed -e "s/^$i /${VERTEX} /" | \
                    sed -e "s/ $i//" | \
                    prep $@:"${VERTEX}->$i" | \
                    sed -e "s/${VERTEX}/${VERTEX} $i/"
	    fi
	done
    else
	for i in ${EDGES}
	do
	    if [[ "${VERTEX}" = "$i" ]]; then
		echo $i
	    else
#		echoerr WTF? V=${VERTEX} E='"'${EDGES}'"'
		exit 1
	    fi
	done
    fi
}
function transpose
{
    awk \
        '{ t[$1] = t[$1]; for (i=2; i<=NF; i++) t[$i] = t[$i]" "$1; } \
         END {for (v in t) print v""t[v]; }'
}

function deg
{
    awk 'NR == 1 { print NF }'
}

function gsort
{
    awk '{print NF,$0}' | sort -k 1 -n | sed -e 's/^[0-9]* //'
}

function revwords
{
    awk '{for (i=NF; i > 1; i--) printf("%s ",$i); printf("%s\n", $1)}'
}

function prep
{
    GRAPH=$(gsort)
    TGRAPH=$(echo -e "${GRAPH}" | transpose | gsort)
    (if [[ $(echo -e "${GRAPH}" | deg) -le $(echo -e "${TGRAPH}"| deg) ]]; then
	echo -e "${GRAPH}"| ham $@
    else
	echo -e "${TGRAPH}" | ham $@ | revwords
    fi)
}


head -n 1 <(prep "")

