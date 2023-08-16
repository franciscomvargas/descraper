@REM Delete Project Folder
IF EXIST %UserProfile%\Desota\Desota_Models\DeScraper rmdir /s %UserProfile%\Desota\Desota_Models\DeScraper
@REM Inform Uninstall Completed
IF NOT EXIST %UserProfile%\Desota\Desota_Models\DeScraper echo Algoz Uninstaled!
PAUSE