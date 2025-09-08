::src https://stackoverflow.com/questions/38779801/move-wsl-bash-on-windows-root-filesystem-to-another-hard-drive
@echo off
set distroName=%1
::C:\Windows\System32>wsl --list --verbose
::Windows Subsystem for Linux has no installed distributions.
::
::Use 'wsl.exe --list --online' to list available distributions
::and 'wsl.exe --install <Distro>' to install.
::
::Distributions can also be installed by visiting the Microsoft Store:
::https://aka.ms/wslstore
::Error code: Wsl/WSL_E_DEFAULT_DISTRO_NOT_FOUND
::
::C:\Windows\System32>wsl.exe --list --online
::The following is a list of valid distributions that can be installed.
::Install using 'wsl.exe --install <Distro>'.
::
::NAME                            FRIENDLY NAME
::Ubuntu                          Ubuntu
::Debian                          Debian GNU/Linux
::kali-linux                      Kali Linux Rolling
::Ubuntu-20.04                    Ubuntu 20.04 LTS
::Ubuntu-22.04                    Ubuntu 22.04 LTS
::Ubuntu-24.04                    Ubuntu 24.04 LTS
::OracleLinux_7_9                 Oracle Linux 7.9
::OracleLinux_8_10                Oracle Linux 8.10
::OracleLinux_9_5                 Oracle Linux 9.5
::openSUSE-Leap-15.6              openSUSE Leap 15.6
::SUSE-Linux-Enterprise-15-SP6    SUSE Linux Enterprise 15 SP6
::openSUSE-Tumbleweed             openSUSE Tumbleweed
::
wsl.exe --install %distroName%
::Installing: Kali Linux Rolling
::Kali Linux Rolling has been installed.
::Launching Kali Linux Rolling...
::Installing, this may take a few minutes...
::Please create a default UNIX user account. The username does not need to match your Windows username.
::For more information visit: https://aka.ms/wslusers
::Enter new UNIX username: ash022
::New password:
::Retype new password:
::passwd: password updated successfully
::usermod: no changes
::Installation successful!
::┏━(Message from Kali developers)
::┃
::┃ This is a minimal installation of Kali Linux, you likely
::┃ want to install supplementary tools. Learn how:
::┃ ⇒ https://www.kali.org/docs/troubleshooting/common-minimum-setup/
::┃
::┗━(Run: “touch ~/.hushlogin” to hide this message)
::┌──(ash022㉿DMED7596)-[~]
::└─$ exit
::logout
::The operation completed successfully.
::
::C:\Windows\System32>wsl --export kail-linux F:\WSL\Kali.tar
::There is no distribution with the supplied name.
::Error code: Wsl/Service/WSL_E_DISTRO_NOT_FOUND
::
::C:\Windows\System32>wsl --list --verbose
::  NAME          STATE           VERSION
::* kali-linux    Running         2
::
::C:\Windows\System32>wsl --export kali-linux F:\WSL\Kali.tar
::Export in progress, this may take a few minutes.
::The operation completed successfully.
::
::C:\Windows\System32>wsl --unregister kali-linux
::Unregistering.
::The operation completed successfully.
::
::C:\Windows\System32>wsl --import kali F:\WSL\Kali F:\WSL\Kali.tar
::Import in progress, this may take a few minutes.
::The operation completed successfully.
::
::C:\Windows\System32>wsl -d kali
::┏━(Message from Kali developers)
::┃
::┃ This is a minimal installation of Kali Linux, you likely
::┃ want to install supplementary tools. Learn how:
::┃ ⇒ https://www.kali.org/docs/troubleshooting/common-minimum-setup/
::┃
::┗━(Run: “touch ~/.hushlogin” to hide this message)
::┌──(root㉿DMED7596)-[/mnt/c/Windows/System32]
::└─# exit
::logout
