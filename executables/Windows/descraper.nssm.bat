@REM - Model Path
set model_path=%UserProfile%\DeSOTA\Desota_Models\DeScraper
@REM Service VARS
@REM retrieved from https://nssm.cc/usage
set model_name=Desota/Descraper
set service_name=descraper_service
set model_exe=%model_path%\executables\Windows\descraper.service.bat
set exe_path=%model_path%\executables\Windows
set model_exe_args=
set model_desc=
set model_dependencies=
set model_log=%model_path%\service.log
set model_env=



@REM -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

@REM NSSM - the Non-Sucking Service Manager 
IF EXIST %UserProfile%\Desota\Portables\nssm goto endofnssm 
call mkdir %UserProfile%\Desota\Portables\nssm
call cd %UserProfile%\Desota\Portables\nssm
call powershell -command "Invoke-WebRequest -Uri https://nssm.cc/ci/nssm-2.24-101-g897c7ad.zip -OutFile ~\Desota\Portables\nssm.zip" &&  tar -xzvf %UserProfile%\Desota\Portables\nssm.zip -C %UserProfile%\Desota\Portables\nssm --strip-components 1 && del %UserProfile%\Desota\Portables\nssm.zip
:endofnssm

@REM NSSM - exe path 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%UserProfile%\Desota\Portables\nssm\win32\nssm.exe

@REM Service Install
call %nssm_exe% install %service_name% %model_exe% %exe_path%
@REM Application tab
@REM call %nssm_exe% set %service_name% Application %model_exe%
call %nssm_exe% set %service_name% AppDirectory %exe_path%
call %nssm_exe% set %service_name% AppParameters server
@REM Details tab
call %nssm_exe% set %service_name% DisplayName %model_name%
call %nssm_exe% set %service_name% Description %model_desc%
call %nssm_exe% set %service_name% Start SERVICE_AUTO_START
@REM Log on tab
call %nssm_exe% set %service_name% ObjectName LocalSystem
call %nssm_exe% set %service_name% Type SERVICE_WIN32_OWN_PROCESS
@REM Dependencies
call %nssm_exe% set %service_name% DependOnService %model_dependencies%

@REM Process tab
call %nssm_exe% set %service_name% AppPriority NORMAL_PRIORITY_CLASS
call %nssm_exe% set %service_name% AppNoConsole 0
call %nssm_exe% set %service_name% AppAffinity All
@REM Shutdown tab
call %nssm_exe% set %service_name% AppStopMethodSkip 0
call %nssm_exe% set %service_name% AppStopMethodConsole 1500
call %nssm_exe% set %service_name% AppStopMethodWindow 1500
call %nssm_exe% set %service_name% AppStopMethodThreads 1500
@REM Exit actions tab
call %nssm_exe% set %service_name% AppThrottle 1500
call %nssm_exe% set %service_name% AppExit Default Restart
call %nssm_exe% set %service_name% AppRestartDelay 0
@REM I/O tab
call %nssm_exe% set %service_name% AppStdout %model_log%
call %nssm_exe% set %service_name% AppStderr %model_log%
@REM File rotation tab
call %nssm_exe% set %service_name% AppStdoutCreationDisposition 4
call %nssm_exe% set %service_name% AppStderrCreationDisposition 4
call %nssm_exe% set %service_name% AppRotateFiles 1
call %nssm_exe% set %service_name% AppRotateOnline 0
call %nssm_exe% set %service_name% AppRotateSeconds 86400
call %nssm_exe% set %service_name% AppRotateBytes 1048576
@REM Environment tab
call %nssm_exe% set %service_name% AppEnvironmentExtra %model_env%

@REM EOF
@REM Stop service - Prevent start on install - retrieved from https://nssm.cc/commands
call %nssm_exe% stop %service_name%
exit