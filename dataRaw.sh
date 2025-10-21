#!/bin/bash
sftp -P 12  ash022@login.nird.sigma2.no << EOF
ls TIMSTOF/Raw/*/*
bye
EOF
sftp -P 12  ash022@login.nird.sigma2.no << EOF
ls Qexactive/Raw
bye
EOF

