@ECHO OFF
:: Uninstalation VARS
set service_name=descraper_service
set model_name=DeScraper
set uninstaller_header=%model_name% Uninstaller - Sad to say goodbye ):

:: - User Path
:: %~dp0 = C:\users\[user]\Desota\Desota_Models\DeScraper\executables\Windows
for %%a in ("%~dp0\..\..\..\..\..\..") do set "test_path=%%~fa"
for %%a in ("%UserProfile%\..") do set "test1_path=%%~fa"
for %%a in ("%~dp0..\..\..\..\..") do set "root_path=%%~fa"

:: - Current Path
:: %~dp0 = C:\Users\[username]Desota\Desota_Models\DeUrlCruncher\executables\windows
set SCRIPTPATH=%~dpnx0
for %%F in ("%SCRIPTPATH%") do set BASENAME=%%~nxF

:: - Model Path
set model_path_base=Desota\Desota_Models\%model_name%
set model_service_base=%model_path_base%\executables\Windows
set model_stop_base=%model_service_base%\descraper.stop.bat

:: - NSSM Path
set nssm_path_base=Desota\Portables\nssm

:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

:: IPUT ARGS - /Q=Quietly
SET arg1=/Q
:: Start Runner Service?
IF "%1" EQU "" GOTO noarg1
IF %1 EQU %arg1% (
    SET arg1_bool=1
    GOTO yeasarg1
)
:noarg1
SET arg1_bool=0
:yeasarg1

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

:: TEST PATH
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
set root_path=%UserProfile%
:TEST_PASSED
:: - Model Path
set model_path=%root_path%\%model_path_base%
set model_stop=%root_path%\%model_stop_base%
:: - NSSM Path
set nssm_path=%root_path%\%nssm_path_base%

:: Copy File from future  deleted folder
IF "%SCRIPTPATH%" NEQ "%root_path%\%BASENAME%" (
    del %root_path%\%BASENAME% >NUL 2>NUL
    copy %SCRIPTPATH% %root_path%\%BASENAME%
    IF %arg1_bool% EQU 1 (
        start %root_path%\%BASENAME% /Q
    ) ELSE (
        start %root_path%\%BASENAME%
    )
    exit
)

:: NSSM - exe VAR 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%nssm_path%\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%nssm_path%\win32\nssm.exe

IF "%1" EQU "" GOTO noargs
IF %1 EQU /Q (
    :: Delete Model Service - retrieved from https://nssm.cc/commands
    ECHO %info_h1%Stoping DeSOTA Services%ansi_end%
    start /B /WAIT %model_stop%
    call %nssm_exe% remove %service_name% confirm >NUL 2>NUL
    :: Delete Project Folder
	ECHO %info_h1%Deleting Project Folder%ansi_end%
    IF EXIST %model_path% rmdir /S /Q %model_path% >NUL 2>NUL
    GOTO EOF_UN
)

:noargs
:: Delete Model Service - retrieved from https://nssm.cc/commands
ECHO %info_h1%Stoping DeSOTA Services%ansi_end%
start /B /WAIT %model_stop%
call %nssm_exe% remove %service_name%
:: Delete Project Folder
IF EXIST %model_path% (
	ECHO %info_h1%Deleting Project Folder%ansi_end%
    rmdir /S %model_path%
    GOTO EOF_UN
)

:EOF_UN
:: Inform Uninstall Completed
IF EXIST %model_path% (
    ECHO %fail%%model_name% Uninstall Fail%ansi_end%
    PAUSE
) ELSE (
    ECHO %sucess%%model_name% Uninstalation Completed!%ansi_end%
    timeout 1 >NUL 2>NUL
)
IF %arg1_bool% EQU 1 (
    del %root_path%\%BASENAME% >NUL 2>NUL && exit
)
del %root_path%\%BASENAME% >NUL 2>NUL && PAUSE && exit