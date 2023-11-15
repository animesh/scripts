#cp ./testVersion.py $HOME/testVersion.py
#singularity exec https://depot.galaxyproject.org/singularity/python:3.9--1 "python" "./testVersion.py"
#3.9.5 | packaged by conda-forge | (default, Jun 19 2021, 00:32:32)
#[GCC 9.3.0]
#!/usr/bin/env python3
import sys
print (sys.version)

