@ECHO OFF

:: GET ADMIN > BEGIN
net session >NUL 2>NUL
IF %errorLevel% NEQ 0 (
	goto UACPrompt
) ELSE (
	goto gotAdmin
)
:UACPrompt
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
set params= %*
ECHO UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
cscript "%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B
:gotAdmin
:: GET ADMIN > END



:: -- Edit bellow vvvv DeSOTA DEVELOPER EXAMPLe (LocalhostAsService - Model): miniconda + pip pckgs + NSSM

:: USER PATH
:: %~dp0 = C:\users\[user]\Desota\Desota_Models\DeScraper\executables\Windows
for %%a in ("%~dp0\..\..\..\..\..") do set "user_path=%%~fa"
for %%a in ("%~dp0\..\..\..") do set "model_path=%%~fa"
for %%a in ("%~dp0\..\..\..\..\..\..") do set "test_path=%%~fa"
for %%a in ("%UserProfile%\..") do set "test1_path=%%~fa"

:: Model VARS
set model_name=DeScraper
set model_path_basepath=Desota\Desota_Models\%model_name%
set uninstaller_header=%model_name% Uninstaller - Sad to say goodbye ):
set model_execs_basepath=%model_path_basepath%\executables\Windows
set req_uninstall_path=%model_execs_basepath%\descraper.uninstall.bat


:: - Miniconda (virtual environment) Vars
set conda_basepath=Desota\Portables\miniconda3\condabin\conda.bat
set model_env_basepath=%model_path_basepath%\env

:: - NSSM VARS
set service_name=descraper_service
set model_stop_basepath=%model_execs_basepath%\descraper.stop.bat
set nssm_path_basepath=Desota\Portables\nssm




:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

:: IPUT ARGS - /Q=Quietly
SET arg1=/Q
SET arg2=/TMP
:: Start Runner Service?
IF "%1" EQU "" GOTO noarg1
IF %1 EQU %arg1% (
    SET arg1_bool=1
    GOTO yeasarg1
)
IF "%2" EQU "" GOTO noarg1
IF %2 EQU %arg1% (
    SET arg1_bool=1
    GOTO yeasarg1
)
:noarg1
SET arg1_bool=0
:yeasarg1
IF "%1" EQU "" GOTO noarg2
IF %1 EQU %arg2% (
    SET arg2_bool=1
    GOTO yeasarg2
)
IF "%2" EQU "" GOTO noarg2
IF %2 EQU %arg2% (
    SET arg2_bool=1
    GOTO yeasarg2
)
:noarg2
SET arg2_bool=0
:yeasarg2

:: - .bat ANSI Colored CLI
set header=
set info=
set sucess=
set fail=
set ansi_end=
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" == "10.0" GOTO set_ansi_colors_un
if "%version%" == "11.0" GOTO set_ansi_colors_un
GOTO end_ansi_colors_un
:set_ansi_colors_un
for /F %%a in ('echo prompt $E ^| cmd') do (
  set "ESC=%%a"
)
set header=%ESC%[4;95m
set info_h1=%ESC%[93m
set info_h2=%ESC%[33m
set sucess=%ESC%[7;32m
set fail=%ESC%[7;31m
set ansi_end=%ESC%[0m
:end_ansi_colors_un

ECHO %header%%uninstaller_header%%ansi_end%
ECHO    model name  : %model_name%
ECHO    service name: %service_name%
IF "%test_path%" EQU "C:\Users" GOTO TEST_PASSED
IF "%test_path%" EQU "C:\users" GOTO TEST_PASSED
IF "%test_path%" EQU "c:\Users" GOTO TEST_PASSED
IF "%test_path%" EQU "c:\users" GOTO TEST_PASSED
IF "%test1_path%" EQU "C:\Users" GOTO TEST1_PASSED
IF "%test1_path%" EQU "C:\users" GOTO TEST1_PASSED
IF "%test1_path%" EQU "c:\Users" GOTO TEST1_PASSED
IF "%test1_path%" EQU "c:\users" GOTO TEST1_PASSED
ECHO %fail%Error: Can't Resolve Request!%ansi_end%
ECHO %fail%DEV TIP: Run Command Without Admin Rights!%ansi_end%
PAUSE
exit
:TEST1_PASSED
set user_path=%UserProfile%
:TEST_PASSED
:: Model VARS
set model_path=%user_path%\%model_path_basepath%
set req_uninstall_path=%user_path%\%req_uninstall_path%
:: - Miniconda (virtual environment) Vars
set conda_path=%user_path%\%conda_basepath%
set model_env=%user_path%\%model_env_basepath%
:: - NSSM Path
set nssm_path=%user_path%\%nssm_path_basepath%
set model_stop=%user_path%\%model_stop_basepath%


:: Copy File from future  deleted folder
:: - Current Path
:: %~dp0 = C:\Users\[username]Desota\Desota_Models\DeScraper\executables\windows
for %%F in ("%req_uninstall_path%") do set BASENAME=%%~nxF
IF %arg2_bool% EQU 0 (
    del %user_path%\%BASENAME% >NUL 2>NUL
    copy %req_uninstall_path% %user_path%\%BASENAME%
    IF %arg1_bool% EQU 1 (
        start %user_path%\%BASENAME% /Q /TMP
    ) ELSE (
        start %user_path%\%BASENAME% /TMP
    )
    exit
)


:: NSSM - exe VAR 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%nssm_path%\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%nssm_path%\win32\nssm.exe



IF %arg1_bool% EQU 0 GOTO noisy_uninstall

:: QUIET UNISTALL

:: Delete Model Service - retrieved from https://nssm.cc/commands
ECHO %info_h1%Stoping DeSOTA Services%ansi_end%
start /B /WAIT %model_stop%
call %nssm_exe% remove %service_name% confirm >NUL 2>NUL
:: Delete pip pckgs
ECHO %info_h1%Deleting pip packages%ansi_end%
ECHO The packages from the following environment will be REMOVED:
ECHO     Package Plan: %model_env%
call %conda_path% remove --prefix %model_env% --all --force -y>NUL 2>NUL
:: Delete Project Folder
ECHO %info_h1%Deleting Project Folder%ansi_end%
IF EXIST %model_path% rmdir /S /Q %model_path% >NUL 2>NUL
GOTO EOF_UN


:: USER UNINSTALL
:noisy_uninstall

:: Delete Model Service - retrieved from https://nssm.cc/commands
ECHO %info_h1%Stoping DeSOTA Services%ansi_end%
start /B /WAIT %model_stop%
call %nssm_exe% remove %service_name%
:: Delete pip pckgs
ECHO %info_h1%Deleting pip packages%ansi_end%
call %conda_path% remove --prefix %model_env% --all --force 
:: Delete Project Folder
ECHO %info_h1%Deleting Project Folder%ansi_end%
IF EXIST %model_path% rmdir /S %model_path%


:: Inform Uninstall Completed
:EOF_UN
IF EXIST %model_path% (
    ECHO %fail%%model_name% Uninstall Fail%ansi_end%
    PAUSE
) ELSE (
    ECHO %sucess%%model_name% Uninstalation Completed!%ansi_end%
    timeout 1 >NUL 2>NUL
)
IF %arg1_bool% EQU 1 (
    del %user_path%\%BASENAME% >NUL 2>NUL && exit
)
del %user_path%\%BASENAME% >NUL 2>NUL && PAUSE && exit