:mainloop

@REM Get Model path
for %%a in ("%~dp0..\..") do set "model_path=%%~fa"

@REM Run Descraper Service
call cd %model_path%
call %model_path%\env\python %model_path%\cli.py ui --host 127.0.0.1 --port 8880

GOTO mainloop