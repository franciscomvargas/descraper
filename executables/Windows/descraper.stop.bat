@REM Service VARS
set service_name=descraper_service



@REM -- Edit bellow if you're felling lucky ;) --

@REM NSSM - exe path 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win32\nssm.exe

@REM Stop service
call %nssm_exe% stop %service_name%

@REM EOF
call %nssm_exe% status %service_name%
call timeout 5
call exit