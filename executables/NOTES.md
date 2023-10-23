# WINDOWS

## Project comands

### SETUP CMD:
```
%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.setup.bat /startmodel
```


### START CMD:
```
%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.start.bat
```


### STOP CMD:
```
%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.stop.bat
```


### STATUS CMD:
```
%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.status.bat
```


### Uninstall CMD:
```
%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.uninstall.bat /Q
```


### INSTALL SERVICE CMD:
```
%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.nssm.bat
```



## Service commands

### Start Service:
```
%UserProfile%\Desota\Portables\nssm\win64\nssm.exe start descraper_service
```


### Stop Service

```
%UserProfile%\Desota\Portables\nssm\win64\nssm.exe stop descraper_service
```


### Status Service:
```
%UserProfile%\Desota\Portables\nssm\win64\nssm.exe status descraper_service
```


### Remove Service:
```
%UserProfile%\Desota\Portables\nssm\win64\nssm.exe remove descraper_service
```





# LINUX

## Project executables

### REQUIRED APT INSTALLS
apt install openssl

### SETUP:
```
/bin/bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.setup.bash -s
```


### UNINSTALL:
```
/bin/bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.uninstall.bash
```
