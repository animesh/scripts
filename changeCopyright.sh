#!/bin/bash

# changeCopyright old new

oldDate="$1"
newDate="$2"

find ../*/include -name *.h -exec sed -i s/$oldDate/$newDate/ {} \;
find ../*/src -name *.c -exec sed -i s/$oldDate/$newDate/ {} \;
find ../*/src -name *.cc -exec sed -i s/$oldDate/$newDate/ {} \;
find ../*/src -name *.cpp -exec sed -i s/$oldDate/$newDate/ {} \;
