@ECHO OFF
:: Instalation VARS
:: - Model GIT
set model_git=https://github.com/franciscomvargas/descraper.git
set model_git_branch=main
set model_name=Desota/Descraper
:: - Model Path
for %%a in ("%~dp0") do set "user_path=%%~fa"
for %%a in ("%~dp0\..") do set "path_test=%%~fa"
set model_path=%user_path%\Desota\Desota_Models\DeScraper
:: - Service Name
set model_service_name=descraper_service
:: - Model Execs
set model_uninstall=%model_path%\executables\Windows\descraper.uninstall.bat
set model_service_install=%model_path%\executables\Windows\descraper.nssm.bat
set model_start=%model_path%\executables\Windows\descraper.start.bat



:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

:: Program Installers
set python64=https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe
set python32=https://www.python.org/ftp/python/3.11.4/python-3.11.4.exe
set git64_portable=https://github.com/git-for-windows/git/releases/download/v2.41.0.windows.3/PortableGit-2.41.0.3-64-bit.7z.exe
set git32_portable=https://github.com/git-for-windows/git/releases/download/v2.41.0.windows.3/PortableGit-2.41.0.3-32-bit.7z.exe
set miniconda64=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
set miniconda32=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86.exe

:: IPUT ARGS - /reinstall="overwrite model + remove service" ; /startmodel="Start Model Service" ; /fromrunner="Ignore Non Portable Sftwr Instalation (eg: python)"
SET arg1=/reinstall
SET arg2=/startmodel
SET arg3=/fromrunner

:: .BAT ANSI Colored CLI
set header=
set info=
set sucess=
set fail=
set ansi_end=
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" == "10.0" GOTO set_ansi_colors
if "%version%" == "11.0" GOTO set_ansi_colors
GOTO end_ansi_colors
:set_ansi_colors
for /F %%a in ('echo prompt $E ^| cmd') do (
  set "ESC=%%a"
)
set header=%ESC%[4;95m
set info_h1=%ESC%[93m
set info_h2=%ESC%[33m
set sucess=%ESC%[7;32m
set fail=%ESC%[7;31m
set ansi_end=%ESC%[0m
:end_ansi_colors

ECHO %header%Welcome to %model_name% Installer!%ansi_end%

:: Check Instasller Location - required to be in user path
IF %path_test% EQU C:\Users GOTO installrootpath_ok
IF %path_test% EQU C:\users GOTO installrootpath_ok
IF %path_test% EQU c:\Users GOTO installrootpath_ok
IF %path_test% EQU c:\users GOTO installrootpath_ok

ECHO %fail%Please move current installer to User PATH (e.g. `C:\Users\[username]`) before instalation! %ansi_end%
ECHO %info_h2%The Installer will Close%ansi_end%
PAUSE
exit
:installrootpath_ok

:: Re-instalation Check
ECHO %info_h1%Step 1/7 - Check Re-Instalation%ansi_end%
IF NOT EXIST %model_path% (
    ECHO %sucess%New install%ansi_end%
    GOTO noreinstallrequired
)
ECHO %info_h2%Re-Instalation required - Start Uninstall...%ansi_end%
IF "%1" EQU "" GOTO noreinstallargs
IF %1 EQU %arg1% (
    GOTO reinstall
)
IF "%2" EQU "" GOTO noreinstallargs
IF %2 EQU %arg1% (
    GOTO reinstall
)
IF "%3" EQU "" GOTO noreinstallargs
IF %3 EQU %arg1% (
    GOTO reinstall
)
:noreinstallargs
call %model_uninstall%
GOTO endofreinstall
:reinstall
call %model_uninstall% /Q
:endofreinstall
IF EXIST %model_path% (
    GOTO EOF_IN
) ELSE (
    ECHO %sucess%DeRunner Uninstall Sucess%ansi_end%
)
:noreinstallrequired

:: Create Project Folder
ECHO %info_h1%Step 2/7 - Create Project Folder%ansi_end%
mkdir %model_path% >NUL 2>NUL
call cd %model_path% >NUL 2>NUL


:: Install Python if Required
IF "%1" EQU "" GOTO checkinstallpython
IF %1 EQU %arg3% (
    GOTO skipinstallpython
)
IF "%2" EQU "" GOTO checkinstallpython
IF %2 EQU %arg3% (
    GOTO skipinstallpython
)
IF "%3" EQU "" GOTO checkinstallpython
IF %3 EQU %arg3% (
    GOTO skipinstallpython
)
:checkinstallpython
ECHO %info_h1%Step 3/7 - Install Python if required%ansi_end%
python --version >NUL 2>NUL
IF errorlevel 1 (
    python3 --version >NUL 2>NUL
    IF errorlevel 1 (
        IF NOT EXIST %user_path%\Desota\Portables\python3 (
            GOTO installpython
        )
    )
)
goto skipinstallpython
:installpython
call mkdir %user_path%\Desota\Portables
IF %PROCESSOR_ARCHITECTURE%==AMD64 powershell -command "Invoke-WebRequest -Uri %python64% -OutFile ~\python3_installer.exe" && start /B /WAIT %user_path%\python3_installer.exe /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 TargetDir=%user_path%\Desota\Portables\python3 && del %user_path%\python3_installer.exe && goto skipinstallpython
IF %PROCESSOR_ARCHITECTURE%==x86 powershell -command "Invoke-WebRequest -Uri %python32% -OutFile ~\python3_installer.exe" && start /B /WAIT %user_path%\python3_installer.exe /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 TargetDir=%user_path%\Desota\Portables\python3 && del %user_path%\python3_installer.exe && goto skipinstallpython
:skipinstallpython

:: GIT MODEL CLONE
ECHO %info_h1%Step 4/7 - Get Project from GitHub%ansi_end%
git --version >NUL 2>NUL
IF NOT errorlevel 1 (
    ::  Clone Descraper Repository
    ECHO %info_h2%Cloning Project Repository...%ansi_end%
    call git clone --branch %model_git_branch% %model_git% . >NUL 2>NUL
) ELSE (
    :: PORTABLE GIT MODEL CLONE
    :: Install Portable Git
    call mkdir %user_path%\Desota\Portables
    IF EXIST %user_path%\Desota\Portables\PortableGit GOTO clonerep
    :: Install Portable Git
    ECHO %info_h2%Downloading Portable Git...%ansi_end%
    IF %PROCESSOR_ARCHITECTURE%==AMD64 powershell -command "Invoke-WebRequest -Uri %git64_portable% -OutFile ~\Desota\Portables\git_installer.exe" && start /B /WAIT %user_path%\Desota\Portables\git_installer.exe -o"%user_path%\Desota\Portables\PortableGit" -y && del %user_path%\Desota\Portables\git_installer.exe && goto clonerep
    IF %PROCESSOR_ARCHITECTURE%==x86 powershell -command "Invoke-WebRequest -Uri %git32_portable% -OutFile ~\Desota\Portables\git_installer.exe" && start /B /WAIT %user_path%\Desota\Portables\git_installer.exe -o"%user_path%\Desota\Portables\PortableGit" && del %user_path%\Desota\Portables\git_installer.exe && goto clonerep
    :clonerep
    ECHO %info_h2%Cloning Project Repository...%ansi_end%
    call %user_path%\Desota\Portables\PortableGit\bin\git.exe clone --branch %model_git_branch% %model_git% . >NUL 2>NUL
)


:: Install Conda if Required
ECHO %info_h1%Step 5/7 - Create Virtual Environment for Project%ansi_end%
call mkdir %user_path%\Desota\Portables >NUL 2>NUL
IF NOT EXIST %user_path%\Desota\Portables\miniconda3\condabin\conda.bat goto installminiconda
goto skipinstallminiconda
:installminiconda
IF %PROCESSOR_ARCHITECTURE%==AMD64 powershell -command "Invoke-WebRequest -Uri %miniconda64% -OutFile %user_path%\miniconda_installer.exe" && start /B /WAIT %user_path%\miniconda_installer.exe /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S /D=%user_path%\Desota\Portables\miniconda3 && del %user_path%\miniconda_installer.exe && goto skipinstallminiconda
IF %PROCESSOR_ARCHITECTURE%==x86 powershell -command "Invoke-WebRequest -Uri %miniconda32% -OutFile %user_path%\miniconda_installer.exe" && start /B /WAIT %user_path%\miniconda_installer.exe /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S /D=%user_path%\Desota\Portables\miniconda3 && del %user_path%\miniconda_installer.exe && && goto skipinstallminiconda
:skipinstallminiconda


:: Create/Activate Conda Virtual Environment
ECHO %info_h2%Creating MiniConda Environment...%ansi_end% 
call %user_path%\Desota\Portables\miniconda3\condabin\conda create --prefix ./env python=3.11 -y >NUL 2>NUL
call %user_path%\Desota\Portables\miniconda3\condabin\conda activate ./env >NUL 2>NUL
call %user_path%\Desota\Portables\miniconda3\condabin\conda install pip -y > NUL 2>NUL

:: Install required Libraries
ECHO %info_h1%Step 6/7 - Install Project Packages%ansi_end%
call pip install -r requirements.txt >NUL 2>NUL

:: MINICONDA ENV DEACTIVATE
call %user_path%\Desota\Portables\miniconda3\condabin\conda deactivate >NUL 2>NUL


:: Install Service - NSSM  - the Non-Sucking Service Manager
ECHO %info_h1%Step 7/7 - Create Project Service with NSSM%ansi_end%
start /B /WAIT %model_service_install%



:: Start Runner Service?
IF "%1" EQU "" GOTO EOF_IN
IF %1 EQU %arg2% (
    GOTO startmodel
)
IF "%2" EQU "" GOTO EOF_IN
IF %2 EQU %arg2% (
    GOTO startmodel
)
IF "%3" EQU "" GOTO EOF_IN
IF %3 EQU %arg2% (
    GOTO startmodel
)
GOTO EOF_IN

:startmodel
start /B /WAIT %model_start%
ECHO %sucess%Instalation Completed & Service Started!%ansi_end%
ECHO %info_h2%model name  : %model_name%%ansi_end% 
ECHO %info_h2%service name: %model_service_name%%ansi_end% 
exit

:EOF_IN
ECHO %sucess%%model_name% Instalation Completed!%ansi_end%
ECHO %info_h2%model name  : %model_name%%ansi_end% 
ECHO %info_h2%service name: %model_service_name%%ansi_end% 
exit