<details open>
    <summary><h1>About DeScraper</h1></summary>

![UI Show Off](readme-imgs/Descraper_UI_ShowOff.PNG)

## Description
This project purpose is to webscrape the web by feeding an webpage URL and conver the source-page (HTML) into text with [Trafilatura](https://github.com/adbar/trafilatura/) and retrieve answers from the page with [NeuralQA](https://github.com/victordibia/neuralqa/) (Large Datasets Question Answer).

Additionally was implemented the conversion of html tables into Excel and/or CSV format with [pandas.read_html](https://pandas.pydata.org/docs/reference/api/pandas.read_html.html).

## How it works
### First Steps:
  - Install:
    - [DeScraper](#instalation);
    - [NeuralQA](https://github.com/franciscomvargas/neuralqa#instalation).

  - Start Services:
    - [DeScraper](#service-operations);
    - [NeuralQA](https://github.com/franciscomvargas/neuralqa#service-operations).
  
### Make your first request:

<details open>
  <summary>By POST Request</summary>

You can use any programing language to make this request, I will use Python to ilustrate how you can do it:

[Payload Explanation](#documentation)
```python
import requests

descraper_url = "http://127.0.0.1:8880/api/scraper"

payload = {
    "url": "https://en.wikipedia.org/wiki/The_Simpsons",
    "html_text": True,
    "query": ["When the simpsons debut?"],
    "qa_port": 8888,
    "expansionterms": [],
    "excel": True,
    "csv": True,
    "overwrite_files": False
}

response = requests.request("POST", descraper_url, json=payload)

print(response.json())
```

</details>

<details open>
  <summary>By User Interface</summary>

 - Click [here](http://127.0.0.1:8880/) to search for Descraper!
 - Fill with [payload](#documentation) parameters:

</details>

### Documentation

![UI Payload Explanation](readme-imgs/UI_payload_explanation.png)

<details open>
  <summary><h4>Payload Explanation</h4></summary>

|Parameter|Type|Optional|Description|
|---|---|---|---|
|url|string|&cross;|The link of the website to webscrape|
|query|array of strings|&check;|When running NeuralQA is required to specify what data you want to retrieve|
|html_text|bolean|&check;|Run Trafilatura - get text from webpage|
|qa_port|integer|&check;|NeuralQA is a TCP/Ip service runing in paralel, here is possible to specify it's Port. Default is 8888|
|expansionterms|array of strings for each query|&check;|NeuralQA have the ability to expand queries in order to improve the results. This by adding expansion terms (keywords) in the NeuralQA request. To get the expansion terms you need to make a perliminar POST request to "http://127.0.0.1:8880/api/expand" with the simple payload {query: [array of queries]}. Get a full grasp of this funtionality with the [NeuralQA Query Expansion](#neuralqa-query-expansion)|
|excel|bolean|&check;|Generate Excel File with webpage tables|
|csv|bolean|&check;|Generate CSV Files with webpage tables|
|overwrite_files|bolean|&check;|DeScraper stores locally the scraped HTML pages and the Generated Tables, therefore, everytime you re-request the same URL you can overwrite the files switching ON this parameter (for example if the webpage has been updated)|
</details>

<details open>
  <summary><h4>NeuralQA Query Expansion</h4></summary>

 - Explanation:
   - First, a set of rules are used to determine which token in the query to expand. These rules are chosen to improve recall (surface relevant queries) without altering the semantics of the original query. Example rules include only expanding ADJECTIVES, ADVERBS and NOUNS ; other parts of speech are not expandable. Once expansion candidates are selected, they are then iteratively masked and a masked language model is used to predict tokens that best complete the sentence given the surrounding tokens.

 - Try it out:
   1. When Query is filled with a array of strings press the "Expand Queries" button;

   2. Select the candidates that best fit your queries:

   ![UI Expand Queries](readme-imgs/Descraper_UI_ExpandQuery.PNG)
   
   3. Finally when you press "Initiate DeScraper" the selected candidates will be added to the post request as `expansionterms`:

   ![Request With Expansion Terms](readme-imgs/Descraper_UI_PayloadW_expansionterms.PNG)
</details>
</details>







<details open>
    <summary><h1>Instalation</h1></summary>

## Use DeSOTA official [Manager & Tools](https://github.com/DeSOTAai/DeManagerTools#readme)

1. [Download Installer for your Platform](https://github.com/DeSOTAai/DeManagerTools#dedicated-installer)
  
2. **Open** [`Models Instalation`](https://github.com/DeSOTAai/DeManagerTools/#install--upgrade-desota-models-and-tools) tab

3. **Select** the Available Tool `franciscomvargas/descraper`

4. **Press** `Start Instalation`

<details>
    <summary><h2>Manual Windows Instalation</h2></summary>

* Go to CMD (command prompt):
  * <kbd>⊞ Win</kbd> + <kbd>R</kbd>
  * Enter: `cmd` 
  * <kbd>↵ Enter</kbd>

### Download:

1. Create Model Folder:
```cmd
rmdir /S /Q %UserProfile%\Desota\Desota_Models\DeScraper
mkdir %UserProfile%\Desota\Desota_Models\DeScraper

```

2. Download Last Release:
```cmd
powershell -command "Invoke-WebRequest -Uri https://github.com/franciscomvargas/descraper/archive/refs/tags/v0.0.0.zip -OutFile %UserProfile%\DeScraper_release.zip" 

```

3. Uncompress Release:
```cmd
tar -xzvf %UserProfile%\DeScraper_release.zip -C %UserProfile%\Desota\Desota_Models\DeScraper --strip-components 1 

```

4. Delete Compressed Release:
```cmd
del %UserProfile%\DeScraper_release.zip

```

### Setup:

5. Setup:
```cmd
%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.setup.bat

```

*  Optional Arguments:
    <table>
        <thead>
            <tr>
                <th>arg</th>
                <th>Description</th>
                <th>Example</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>/debug</td>
                <td>Log everything (useful for debug)</td>
                <td><code>%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.setup.bat /debug</code></td>
            </tr>
            <tr>
                <td>/manualstart</td>
                <td>Don't start at end of setup</td>
                <td><code>%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.setup.bat /manualstart</code></td>
            </tr>
        </tbody>
    </table>
    
</details>



<details>
    <summary><h2>Manual Linux Instalation</h2></summary>

* Go to Terminal:
    * <kbd> Ctrl </kbd> + <kbd> Alt </kbd> + <kbd>T</kbd>

### Download:

1. Create Model Folder:
```cmd
rm -rf ~/Desota/Desota_Models/DeScraper
mkdir -p ~/Desota/Desota_Models/DeScraper

```

2. Download Last Release:
```cmd
wget https://github.com/franciscomvargas/descraper/archive/refs/tags/v0.0.0.zip -O ~/DeScraper_release.zip

```

3. Uncompress Release:
```cmd
sudo apt install libarchive-tools -y && bsdtar -xzvf ~/DeScraper_release.zip -C ~/Desota/Desota_Models/DeScraper --strip-components=1

```

4. Delete Compressed Release:
```cmd
rm -rf ~/DeScraper_release.zip

```

### Setup:

5. Setup:
```cmd
sudo bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.setup.bash

```

*  Optional Arguments:
    <table>
        <thead>
            <tr>
                <th>arg</th>
                <th>Description</th>
                <th>Example</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>-d</td>
                <td>Setup with debug Echo ON</td>
                <td><code>sudo bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.setup.bash -d</code></td>
            </tr>
            <tr>
                <td>-m</td>
                <td>Don't start service at end of setup</td>
                <td><code>sudo bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.setup.bash -m</code></td>
            </tr>
        </tbody>
    </table>
    
    
</details>
</details>







<details open>
    <summary><h1>Service Operations</h1></summary>

<details>
    <summary><h2>Windows</h2></summary>

* Go to CMD as Administrator (command prompt):
  * <kbd>⊞ Win</kbd> + <kbd>R</kbd>
  * Enter: `cmd` 
  * <kbd>Ctrl</kbd> + <kbd>⇧ Shift</kbd> + <kbd>↵ Enter</kbd>

### Start Service
    ```cmd
    %UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.start.bat

    ```
### Stop Service
    ```cmd
    %UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.stop.bat

    ```

### Status Service
    ```cmd
    %UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.status.bat

    ```
</details>



<details>
    <summary><h2>Linux</h2></summary>

* Go to Terminal:
    * <kbd> Ctrl </kbd> + <kbd> Alt </kbd> + <kbd>T</kbd>

### Start Service
    ```cmd
    sudo bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.start.bash
    ```
    
### Stop Service
    ```cmd
    sudo bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.stop.bash

    ```

### Status Service
    ```cmd
    bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.status.bash

    ```
</details>
</details>




<details open>
    <summary><h1>Uninstalation</h1></summary>

## Use DeSOTA official [Manager & Tools](https://github.com/DeSOTAai/DeManagerTools#readme)

1. **Open** [`Models Dashboard`](https://github.com/DeSOTAai/DeManagerTools/#models--tools-dashboard) tab

2. **Select** the model `franciscomvargas/descraper`

3. **Press** `Uninstall`

<details>
    <summary><h2>Manual Windows Uninstalation</h2></summary>

* Go to CMD as Administrator (command prompt):
  * <kbd>⊞ Win</kbd> + <kbd>R</kbd>
  * Enter: `cmd` 
  * <kbd>Ctrl</kbd> + <kbd>⇧ Shift</kbd> + <kbd>↵ Enter</kbd>

```cmd
%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.uninstall.bat

```

* Optional `Arguments`

    |arg|Description|Example
    |---|---|---|
    |/Q|Uninstall without requiring user interaction|`%UserProfile%\Desota\Desota_Models\DeScraper\executables\Windows\descraper.uninstall.bat /Q`
      
</details>



<details>
    <summary><h2>Manual Linux Uninstalation</h2></summary>

* Go to Terminal:
    * <kbd> Ctrl </kbd> + <kbd> Alt </kbd> + <kbd>T</kbd>

```cmd
sudo bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.uninstall.bash

```

* Optional `Arguments`

    |arg|Description|Example
    |---|---|---|
    |-q|Uninstall without requiring user interaction|`sudo bash ~/Desota/Desota_Models/DeScraper/executables/Linux/descraper.uninstall.bash -q`
      
</details>
</details>





<details open>
    <summary><h1>Credits / <a href="https://github.com/franciscomvargas/descraper/blob/main/LICENSE">License</a></h1></summary>
    
## [Trafilatura](https://github.com/adbar/trafilatura/blob/master/LICENSE)
```sh
@inproceedings{
  barbaresi-2021-trafilatura,
  title = {{Trafilatura: A Web Scraping Library and Command-Line Tool for Text Discovery and Extraction}},
  author = "Barbaresi, Adrien",
  booktitle = "Proceedings of the Joint Conference of the 59th Annual Meeting of the Association for Computational Linguistics and the 11th International Joint Conference on Natural Language Processing: System Demonstrations",
  pages = "122--131",
  publisher = "Association for Computational Linguistics",
  url = "https://aclanthology.org/2021.acl-demo.15",
  year = 2021,
}
```


## [NeuralQA](https://github.com/victordibia/neuralqa/blob/master/LICENSE)
```sh
@article{
  dibia2020neuralqa,
  title={NeuralQA: A Usable Library for Question Answering (Contextual Query Expansion + BERT) on Large Datasets},
  author={Victor Dibia},
  year={2020},
  journal={Proceedings of the 2020 Conference on Empirical Methods in Natural Language Processing and the 9th International Joint Conference on Natural Language Processing (EMNLP-IJCNLP): System Demonstrations}
}
```
</details>

