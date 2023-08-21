@REM Uninstalation VARS
@REM - Model Path
set model_path=%UserProfile%\Desota\Desota_Models\DeScraper
set service_name=descraper_service
set nssm_path=%UserProfile%\Desota\Portables\nssm



@REM -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

@REM IPUT ARGS - /Q=Quietly
SET arg1=/Q

@REM NSSM - exe VAR 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%nssm_path%\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%nssm_path%\win32\nssm.exe

IF "%1" EQU "" GOTO noargs
IF %1 EQU /Q (
    @REM Delete Model Service - retrieved from https://nssm.cc/commands
    call %nssm_exe% stop %service_name%
    call %nssm_exe% remove %service_name% confirm
    @REM Delete Project Folder
    IF EXIST %model_path% rmdir /S /Q %model_path%
    GOTO EOF
)
:noargs
@REM Delete Model Service - retrieved from https://nssm.cc/commands
call %nssm_exe% stop %service_name%
call %nssm_exe% remove %service_name%
@REM Delete Project Folder
IF EXIST %model_path% rmdir /S %model_path%


:EOF
@REM Inform Uninstall Completed
call %nssm_exe% status %service_name%
IF NOT EXIST %model_path% echo Algoz Uninstaled!
exit