# Windows Instalation
## Create Project Folder 
Model Folder:
> %UserProfile%\Desota_Models\DeScraper

Go to CMD (command prompt)
> WIN + "R" 
> Write "cmd" 

Copy-Paste the following comands 
```
mkdir %UserProfile%\Desota_Models\DeScraper
cd %UserProfile%\Desota_Models\DeScraper
```

## Test if conda is instaled

Copy-Paste the following comands 
```
conda --help
```
if response is:
> 'conda' is not recognized as an internal or external command,operable program or batch 

then is required conda instalation !

### Conda Instalation
Copy-Paste the following comand
```
powershell -command "Invoke-WebRequest -Uri https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe -OutFile ~\miniconda.exe && start /B /WAIT %UserProfile%\miniconda.exe /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S /D=%UserProfile%\miniconda3 && del %UserProfile%\miniconda.exe 
```


## Install Neuralqa model
Copy-Paste the following comands 
```
%UserProfile%\miniconda3\condabin\activate 
conda deactivate 
conda create --prefix ./env python=3.11 -y
conda activate ./env 
conda install -y pip
git clone https://github.com/franciscomvargas/descraper.git
echo "yes" | pip install -r requirements.txt
echo DONE (:

```

## Run Model
Copy-Paste the following comands 
```
python cli.py ui
```
