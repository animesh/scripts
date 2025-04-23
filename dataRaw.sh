#!/bin/bash
sftp -P 12  ash022@login0.nird-lmd.sigma2.no << EOF
cd TIMSTOF/
put -R promec/promec/TIMSTOF/Raw
bye
EOF
sftp -P 12  ash022@login0.nird-lmd.sigma2.no << EOF
cd Qexactive/
put -R promec/promec/Qexactive/Raw
bye
EOF

