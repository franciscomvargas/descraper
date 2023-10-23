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
:: -- SERVICE AUTO START

:: USER PATH
:: %~dp0 = C:\users\[user]\Desota\Desota_Models\DeScraper\executables\Windows
for %%a in ("%~dp0..\..\..\..\..") do set "user_path=%%~fa"

:: - Model Path
set model_path=%user_path%\Desota\Desota_Models\DeScraper

:: - NSSM VARS
set nssm_path=%user_path%\Desota\Portables\nssm

:: Service VARS - retrieved from https://nssm.cc/usage
set model_display_name=Desota/DeScraper
set service_name=descraper_service
set exe_path=%model_path%\executables\Windows
set model_exe=%exe_path%\descraper.service.bat
set model_exe_args=
set model_desc=WebScraper assisted by AI Models
set model_dependencies=
set model_log=%model_path%\service.log
set model_env=



:: -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

:: - Program Installers
set nssm_installer=https://nssm.cc/ci/nssm-2.24-101-g897c7ad.zip

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


:: NSSM - the Non-Sucking Service Manager 
IF EXIST %nssm_path% goto endofnssm
ECHO %info_h2%Installing NSSM...%ansi_end% 
call mkdir %nssm_path% >NUL 2>NUL
call cd %nssm_path% >NUL 2>NUL
call powershell -command "Invoke-WebRequest -Uri %nssm_installer% -OutFile %nssm_path%.zip" &&  tar -xzvf %nssm_path%.zip -C %nssm_path% --strip-components 1 && del %nssm_path%.zip
:endofnssm

ECHO %info_h2%Creating Service..%ansi_end% 
ECHO    service name: %service_name%

:: NSSM - exe path 
IF %PROCESSOR_ARCHITECTURE%==AMD64 set nssm_exe=%nssm_path%\win64\nssm.exe
IF %PROCESSOR_ARCHITECTURE%==x86 set nssm_exe=%nssm_path%\win32\nssm.exe

:: > NSSM Dont Overwrite!
call %nssm_exe% remove %service_name%  confirm >NUL 2>NUL
:: > Service Install
call %nssm_exe% install %service_name% %model_exe% %exe_path% 
::>NUL 2>NUL
:: God spot to check service not installed!

:: > Application tab
:: call %nssm_exe% set %service_name% Application %model_exe%
call %nssm_exe% set %service_name% AppDirectory %exe_path% >NUL 2>NUL
call %nssm_exe% set %service_name% AppParameters server >NUL 2>NUL

:: Details tab
call %nssm_exe% set %service_name% DisplayName %model_display_name%
call %nssm_exe% set %service_name% Description "%model_desc%"

:: START retrieved from https://gist.github.com/mh-cbon/bd0c860d42db33508d817e12fb540cdb
:: AUTO
call %nssm_exe% set %service_name% Start SERVICE_AUTO_START
:: MANUAL
::call %nssm_exe% set %service_name% Start SERVICE_DEMAND_START

:: Log on tab
call %nssm_exe% set %service_name% ObjectName LocalSystem
call %nssm_exe% set %service_name% Type SERVICE_WIN32_OWN_PROCESS

:: Dependencies
call %nssm_exe% set %service_name% DependOnService %model_dependencies%


:: > Process tab
call %nssm_exe% set %service_name% AppPriority NORMAL_PRIORITY_CLASS
call %nssm_exe% set %service_name% AppNoConsole 0
call %nssm_exe% set %service_name% AppAffinity All

:: > Shutdown tab
call %nssm_exe% set %service_name% AppStopMethodSkip 0
call %nssm_exe% set %service_name% AppStopMethodConsole 1500
call %nssm_exe% set %service_name% AppStopMethodWindow 1500
call %nssm_exe% set %service_name% AppStopMethodThreads 1500

:: > Exit actions tab
call %nssm_exe% set %service_name% AppThrottle 1500
call %nssm_exe% set %service_name% AppExit Default Restart
call %nssm_exe% set %service_name% AppRestartDelay 0

:: > I/O tab
call %nssm_exe% set %service_name% AppStdout %model_log%
call %nssm_exe% set %service_name% AppStderr %model_log%

:: > File rotation tab
call %nssm_exe% set %service_name% AppStdoutCreationDisposition 4
call %nssm_exe% set %service_name% AppStderrCreationDisposition 4
call %nssm_exe% set %service_name% AppRotateFiles 1
call %nssm_exe% set %service_name% AppRotateOnline 0
call %nssm_exe% set %service_name% AppRotateSeconds 86400
call %nssm_exe% set %service_name% AppRotateBytes 1048576

:: > Environment tab
call %nssm_exe% set %service_name% AppEnvironmentExtra %model_env%



ECHO %sucess%Service Created!%ansi_end% 
ECHO %info_h2%    service name: %model_display_name%%ansi_end% 
exit