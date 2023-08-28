@ECHO OFF
:: Uninstalation VARS
:: - Model Path
set model_path=%UserProfile%\Desota\Desota_Models\DeScraper
set service_name=descraper_service
set nssm_path=%UserProfile%\Desota\Portables\nssm
set model_name=Desota/Descraper


:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

:: IPUT ARGS - /Q=Quietly
SET arg1=/Q

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

:: NSSM - exe VAR 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%nssm_path%\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%nssm_path%\win32\nssm.exe

IF "%1" EQU "" GOTO noargs
IF %1 EQU /Q (
    :: Delete Model Service - retrieved from https://nssm.cc/commands
    call %nssm_exe% remove %service_name% confirm >NUL 2>NUL
    :: Delete Project Folder
    IF EXIST %model_path% rmdir /S /Q %model_path% >NUL 2>NUL
    GOTO EOF_UN
)

:noargs
:: Delete Model Service - retrieved from https://nssm.cc/commands
call %nssm_exe% remove %service_name%
:: Delete Project Folder
IF EXIST %model_path% (
    rmdir /S %model_path%
    GOTO EOF_UN
)

:EOF_UN
:: Inform Uninstall Completed
IF EXIST %model_path% (
    ECHO %fail%%model_name% Uninstall Fail%ansi_end%
    PAUSE
)
exit