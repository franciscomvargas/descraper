@ECHO OFF
:: Service VARS
set service_name=descraper_service



:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I
:: Bat Requires as argument the Target where status will be written
IF "%1" EQU "" (
    GOTO exit_bat
)

:: NSSM - exe path 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win32\nssm.exe

:: Status service - retrieved from https://nssm.cc/commands
%nssm_exe% status %service_name% >%1

:exit_bat
exit