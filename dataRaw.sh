#!/bin/bash
$HOME/gopath/gopath/bin/drive pull -ignore-conflict -ignore-name-clashes -no-prompt -verbose $HOME/Data/HF/ 1>> $HOME/dataRaw.1.log 2>> $HOME/dataRaw.2.log >> $HOME/dataRaw.log
$HOME/gopath/gopath/bin/drive pull -ignore-conflict -ignore-name-clashes -no-prompt -verbose $HOME/Data/QE  1>> $HOME/dataRaw.1.log 2>> $HOME/dataRaw.2.log >> $HOME/dataRaw.log
$HOME/gopath/gopath/bin/drive pull -ignore-conflict -ignore-name-clashes -no-prompt -verbose $HOME/Data/Elite  1>> $HOME/dataRaw.1.log 2>> $HOME/dataRaw.2.log >> $HOME/dataRaw.log
find $HOME/Data/ -iname "*.raw" | wc 1>> $HOME/dataRaw.1.log 2>> $HOME/dataRaw.2.log >> $HOME/dataRaw.log

