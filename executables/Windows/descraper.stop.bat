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
for %%a in ("%~dp0..\..") do set "model_path=%%~fa"

:: Service VARS
set service_name=descraper_service

:: NSSM VARS
set nssm_path=%user_path%\Desota\Portables\nssm
set model_status_path=%model_path%\descraper_status.txt



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
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%nssm_path%\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%nssm_path%\win32\nssm.exe

:: Stop service - retrieved from https://nssm.cc/commands
ECHO %info_h2%Stopping Service...%ansi_end% 
ECHO     service name: %service_name%

call %nssm_exe% stop %service_name%

:wait4stop
%nssm_exe% status %service_name% >%model_status_path%
set /p model_status=<%model_status_path%
ECHO %model_status%
IF %model_status% NEQ SERVICE_STOPPED (
	goto :wait4stop
) ELSE (
	del %model_status_path%
)

exit