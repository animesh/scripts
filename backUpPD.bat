@echo off
:: This script is used to rclone PROMEC data from a server to nird-lmd, download https://downloads.rclone.org/v1.70.3/rclone-v1.70.3-windows-amd64.zip and unzip
set RCLONE_CONFIG=nird-lmd.conf
set RCLONE_REMOTE=nird-lmd:promec
set SOURCE_DIR=D:\Data
set EXCLUDE_DIRS=BrukerDBBackup .driveupload BrukerDBData .tmp.driveupload .gd
set LOG_FILE=\\it-promecfarm01.win.ntnu.no\promec\promec\logs\logTTP.txt
set RCLONE_OPTIONS=--exclude "%EXCLUDE_DIRS%" --copy-links --transfers 8 --checkers 8 --log-file "%LOG_FILE%" --log-level INFO --stats 1m
set RCLONE_FLAGS=--progress --fast-list --delete-excluded --dry-run
cd Z:\Download\rclone-v1.70.3-windows-amd64\rclone-v1.70.3-windows-amd64
:: power-shell in admin mode
Set-Service -Name ssh-agent -StartupType Manual
Start-Service -Name ssh-agent
Get-Service ssh-agent
:: Running  ssh-agent          OpenSSH Authentication Agent
:: cmd.exe in user mode
type %USERPROFILE%\.ssh\id_rsa.pub | ssh ash022@login.nird.sigma2.no "cat >> .ssh/authorized_keys"
rclone config
:: [nird]
:: type = sftp
:: host = login.nird.sigma2.no
:: user = ash022
:: port = 12
ssh-add 
:: %USERPROFILE%\.ssh\id_rsa Identity added: C:\Users\animeshs/.ssh/id_rsa (win-ntnu-no\animeshs@DMED7596)
rclone lsd nird:promec
rclone copy -Pv L:\promec\Animesh\Aida\MMRFBiolinks\plotKM\ nird:PD/Animesh/Aida/MMRFBiolinks/plotKM/
