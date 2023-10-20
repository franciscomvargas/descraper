@ECHO OFF
:: Service VARS
set service_name=descraper_service
:: - User Path
:: %~dp0 = C:\users\[user]\Desota\Desota_Models\DeScraper\executables\Windows
for %%a in ("%~dp0..\..\..\..\..") do set "root_path=%%~fa"

:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

:: NSSM - exe path 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%root_path%\Desota\Portables\nssm\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%root_path%\Desota\Portables\nssm\win32\nssm.exe

:: Status service - retrieved from https://nssm.cc/commands
:: Bat Requires as argument the Target where status will be written
IF "%1" EQU "" GOTO noargs
%nssm_exe% status %service_name% >%1
exit
:noargs
%nssm_exe% status %service_name%