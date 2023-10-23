@ECHO OFF

:: -- Edit bellow vvvv DeSOTA DEVELOPER EXAMPLe (LocalhostAsService - Model): miniconda + pip pckgs + NSSM

:: USER PATH
:: %~dp0 = C:\users\[user]\Desota\Desota_Models\DeScraper\executables\Windows
for %%a in ("%~dp0..\..\..\..\..") do set "user_path=%%~fa"

:: Service VARS
set service_name=descraper_service

:: NSSM VARS
set nssm_path=%user_path%\Desota\Portables\nssm




:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

:: NSSM - exe path 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%nssm_path%\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%nssm_path%\win32\nssm.exe

:: Status service - retrieved from https://nssm.cc/commands
:: Bat Requires as argument the Target where status will be written
IF "%1" EQU "" GOTO noargs
%nssm_exe% status %service_name% >%1
exit
:noargs
%nssm_exe% status %service_name%