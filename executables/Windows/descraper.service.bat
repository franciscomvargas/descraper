@ECHO OFF
:: Get Model path
:: %~dp0 = C:\users\[user]\Desota\Desota_Models\DeScraper\executables\Windows
for %%a in ("%~dp0..\..") do set "model_path=%%~fa"
:: Move to Model Path
call cd %model_path%
:: Delete Service Log on-start
break>%model_path%\service.log
:: Make sure every package required is installed
call %model_path%\env\python -m pip install -r %model_path%\requirements.txt
:mainloop
:: Start Model Server
call %model_path%\env\python %model_path%\cli.py ui --host 127.0.0.1 --port 8880
GOTO mainloop