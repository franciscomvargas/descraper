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
for %%a in ("%~dp0..\..\..\..\..") do set "user_path=%%~fa"

:: Service VARS
set service_name=descraper_service

:: Service waiter - Confirm Service is ready for requests
set service_waiter=curl localhost:8880/api/handshake
set shake_respose={"status":"ready"}

:: NSSM VARS
set nssm_path=%user_path%\Desota\Portables\nssm



:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

:: /automatic :: Request from DeSOTA. 
set automatic=/automatic

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
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%nssm_path%\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%nssm_path%\win32\nssm.exe

:: Start service - retrieved from https://nssm.cc/commands
ECHO %info_h2%Starting Service...%ansi_end% 
ECHO     service name: %service_name%

call %nssm_exe% start %service_name% >NUL

:: Wait for Service to be fully started
IF "%service_waiter%" EQU "" GOTO enofassetstart

:: retrieved from https://stackoverflow.com/a/77363838/21896301
for /F "tokens=1 delims=# " %%a in ('"prompt #$H# & echo on & for %%b in (1) do rem"') do set "BSPACE=%%a"
<nul set /p =%info_h2%Waiting for Service HandShake -
set /a x=1
:waitloop

IF %x% EQU 1 SET state=\
IF %x% EQU 2 SET state=-
IF %x% EQU 3 SET state=/
IF %x% EQU 4 SET state=-
IF %x% EQU 4 (
  SET x=1
) ELSE (
  SET /a x+=1
)
<nul set /p =%BSPACE%
<nul set /p =%state%

%service_waiter% > %user_path%\tmpFile.txt 2>NUL
set /p service_res= < %user_path%\tmpFile.txt
del %user_path%\tmpFile.txt >NUL 2>NUL
IF '%service_res%' NEQ '%shake_respose%' (
  GOTO waitloop
)
<nul set /p =%BSPACE%
<nul set /p =- done
<nul set /p =%ansi_end%

:enofassetstart
echo:
call %nssm_exe% status %service_name%
exit