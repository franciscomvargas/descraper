@REM Service VARS
set service_name=descraper_service
@REM Service waiter - Confirm Service is ready for requests
set service_waiter=curl localhost:8880/api/handshake
set shake_respose={"status":"ready"}

@REM -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

@REM NSSM - exe path 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win32\nssm.exe

@REM Start service - retrieved from https://nssm.cc/commands
call %nssm_exe% start %service_name%

@REM Wait for Service to be fully started
:waitloop
%service_waiter% > %UserProfile%\tmpFile.txt
set /p service_res= < %UserProfile%\tmpFile.txt
del %UserProfile%\tmpFile.txt
echo IF '%service_res%' NEQ '%shake_respose%'
IF '%service_res%' NEQ '%shake_respose%' (
    timeout 1
    GOTO waitloop
)

@REM EOF
call %nssm_exe% status %service_name%
@REM exit
PAUSE