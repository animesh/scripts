Starting job 5413366 on c3-20 at Thu Mar 31 13:48:33 CEST 2022

we are running from this directory: /cluster/projects/nn9036k/scripts
 the name of the job is: MQ40
Th job ID is 5413366
The job was run on these nodes: c3-20
Number of nodes: 1
We are using 40 cores
We are using 40 cores per node
Total of 4 cores
The following modules were not unloaded:
  (Use "module --force purge" to unload all):

  1) StdEnv
Mono JIT compiler version 6.8.0.105 (tarball Fri Oct  9 11:00:40 CEST 2020)
Copyright (C) 2002-2014 Novell, Inc, Xamarin Inc and Contributors. www.mono-project.com
	TLS:           __thread
	SIGSEGV:       altstack
	Notifications: epoll
	Architecture:  amd64
	Disabled:      none
	Misc:          softdebug 
	Interpreter:   yes
	LLVM:          supported, not enabled.
	Suspend:       hybrid
	GC:            sgen (concurrent by default)
3.1.300
Configuring 
Assemble run info 
Finish run info 
Testing fasta files 
Testing raw files 
Feature detection TIMS 
Starting job 5416595 on c1-47 at Fri Apr 1 11:18:54 CEST 2022

we are running from this directory: /cluster/projects/nn9036k/scripts
 the name of the job is: MQ40
Th job ID is 5416595
The job was run on these nodes: c1-47
Number of nodes: 1
We are using 40 cores
We are using 40 cores per node
Total of 4 cores
The following modules were not unloaded:
  (Use "module --force purge" to unload all):

  1) StdEnv
Mono JIT compiler version 6.8.0.105 (tarball Fri Oct  9 11:00:40 CEST 2020)
Copyright (C) 2002-2014 Novell, Inc, Xamarin Inc and Contributors. www.mono-project.com
	TLS:           __thread
	SIGSEGV:       altstack
	Notifications: epoll
	Architecture:  amd64
	Disabled:      none
	Misc:          softdebug 
	Interpreter:   yes
	LLVM:          supported, not enabled.
	Suspend:       hybrid
	GC:            sgen (concurrent by default)
3.1.300
Matching slices 
Feature detection TIMS cluster 
Feature detection TIMS create peaks prep 
Feature detection TIMS create peaks 
De-isotoping TIMS 
MS/MS preparation TIMS first search split 
MS/MS preparation TIMS first search combine 
Calculating peak properties (TIMS) 
Combining tims apl files for first search 
Preparing searches 
MS/MS first search 
Read search results for recalibration 
Mass recalibration 
Calculating masses 
MS/MS preparation TIMS main search 
Combining tims apl files for main search 
MS/MS main search 
Preparing combined folder  
Correcting errors 
Reading search engine results 
Preparing reverse hits 
Finish search engine results 
Filter identifications (MS/MS) 
Calculating PEP 
slurmstepd: error: *** JOB 5416595 ON c1-47 CANCELLED AT 2022-04-06T11:19:04 DUE TO TIME LIMIT ***

Task and CPU usage stats:
       JobID    JobName  AllocCPUS   NTasks     MinCPU MinCPUTask     AveCPU    Elapsed ExitCode 
------------ ---------- ---------- -------- ---------- ---------- ---------- ---------- -------- 
5416595            MQ40         40                                           5-00:00:11      0:0 
5416595.bat+      batch         40        1 21-09:34:+          0 21-09:34:+ 5-00:00:15     0:15 
5416595.ext+     extern         40        1   00:00:00          0   00:00:00 5-00:00:11      0:0 

Memory usage stats:
       JobID     MaxRSS MaxRSSTask     AveRSS MaxPages   MaxPagesTask   AvePages 
------------ ---------- ---------- ---------- -------- -------------- ---------- 
5416595                                                                          
5416595.bat+ 137396884K          0 137396884K        0              0          0 
5416595.ext+          0          0          0        0              0          0 

Disk usage stats:
       JobID  MaxDiskRead MaxDiskReadTask    AveDiskRead MaxDiskWrite MaxDiskWriteTask   AveDiskWrite 
------------ ------------ --------------- -------------- ------------ ---------------- -------------- 
5416595                                                                                               
5416595.bat+       13.10M               0         13.10M        0.04M                0          0.04M 
5416595.ext+        0.63M               0          1.26M        0.03M                0          0.06M 

Job 5416595 completed at Wed Apr 6 11:19:09 CEST 2022
