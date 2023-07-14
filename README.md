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


## Install Descraper
Copy-Paste the following comands 
```
git clone https://github.com/franciscomvargas/descraper.git .
%UserProfile%\miniconda3\condabin\activate 
conda deactivate 
conda create --prefix ./env python=3.11 -y
conda activate ./env 
conda install -y pip
echo "yes" | pip install -r requirements.txt
echo DONE (:

```

## Run Model
### Start API server
> Re-Open the command prompt (CMD)

Copy-Paste the following comands
```
cd %UserProfile%\Desota_Models\DeScraper
%UserProfile%\miniconda3\condabin\activate 
conda deactivate 
conda activate ./env 
python cli.py ui

```
### Open Server in Browser
Search in the browser
```
http://127.0.0.1:8880/
```
### Consideration
This model require to run in paralel with neuralqa! 
> Take a look at [my neuralqa instalation repo](https://github.com/franciscomvargas/neuralqa)


# Credits / Lincense - Trafilatura
## Citation
```
@inproceedings{barbaresi-2021-trafilatura,
  title = {{Trafilatura: A Web Scraping Library and Command-Line Tool for Text Discovery and Extraction}},
  author = "Barbaresi, Adrien",
  booktitle = "Proceedings of the Joint Conference of the 59th Annual Meeting of the Association for Computational Linguistics and the 11th International Joint Conference on Natural Language Processing: System Demonstrations",
  pages = "122--131",
  publisher = "Association for Computational Linguistics",
  url = "https://aclanthology.org/2021.acl-demo.15",
  year = 2021,
}
```
## Licence
[GPL-3.0 license](https://github.com/adbar/trafilatura/blob/master/LICENSE)

