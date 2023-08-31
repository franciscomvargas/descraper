@ECHO OFF
:: Service VARS
set service_name=descraper_service
:: Service waiter - Confirm Service is ready for requests
set service_waiter=curl localhost:8880/api/handshake
set shake_respose={"status":"ready"}



:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

:: - .bat ANSI Colored CLI
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

:: NSSM - exe path 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win32\nssm.exe

:: Start service - retrieved from https://nssm.cc/commands
ECHO %info_h2%Starting Service...%ansi_end% 
ECHO     service name: %service_name%

call %nssm_exe% start %service_name% >NUL

:: Wait for Service to be fully started
ECHO %info_h2%Waiting for Service handshake...%ansi_end% 
:waitloop
%service_waiter% > %UserProfile%\tmpFile.txt
set /p service_res= < %UserProfile%\tmpFile.txt
del %UserProfile%\tmpFile.txt > NUL 2>NUL
IF '%service_res%' NEQ '%shake_respose%' (
    timeout 1 > NUL 2>NUL
    GOTO waitloop
)

:: EOF
call %nssm_exe% status %service_name%
exit