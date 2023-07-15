from pathlib import Path
import os
import time
import random
import json
import pandas as pd
import httpx
import requests
import unicodedata
import string
import shutil   # Delete not empty folder
from trafilatura import extract
from trafilatura.settings import use_config

# WebScrape html page by URL
def html_scrape(url, refresh_html=False):
    # Check if url as been allready Scraped
    if not refresh_html:
        local_html = get_html_file(url)
        if local_html != None:
            return {
                'request_status': 200,
                'html_file': local_html
            }
        
    # Fetch Font Page html
    fetch_retry_counter = 4
    # Request as Normal Computer
    headers = {
    "authority": "www.linkedin.com",
        "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "accept-language": "pt-PT,pt;q=0.9,en-US;q=0.8,en;q=0.7",
        "cache-control": "max-age=0",
        "cookie": "bcookie=^\^v=2",
        "sec-ch-ua": "^\^Not.A/Brand^^;v=^\^8^^, ^\^Chromium^^;v=^\^114^^, ^\^Google",
        "sec-ch-ua-mobile": "?0",
        "sec-ch-ua-platform": "^\^Windows^^",
        "sec-fetch-dest": "document",
        "sec-fetch-mode": "navigate",
        "sec-fetch-site": "same-origin",
        "sec-fetch-user": "?1",
        "upgrade-insecure-requests": "1",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
    }

    while True:
        scrape_res = httpx.get(
            url,
            headers=headers
        )
        print('Fetch Status:', scrape_res.status_code)
        if scrape_res.status_code != 200:  # Assert Request Sucess
            fetch_retry_counter -= 1
            if fetch_retry_counter == 0:
                return {
                    'request_status': scrape_res.status_code,
                    'html': None
                }
            # Alta Func!!
            time.sleep(2 + random.uniform(0, 0.5))    # Xoné moñé
            print()
            continue
        # else:
        break
    html = scrape_res.text

    html_path = gen_html_file(url, html)
    return {
        'request_status': scrape_res.status_code,
        'html_file': html_path
    }

#TRAFILATURA - HTML TO TEXT
#Instalation:
 # https://trafilatura.readthedocs.io/en/latest/installation.html
#Documentation
 # https://trafilatura.readthedocs.io/en/latest/usage-python.html
def run_trafilatura(html_file):
    # Get HTML string
    with open(html_file, 'r', encoding="utf-8") as fr:
        downloaded = fr.read()    

    #Disabling signal
    # A timeout exit during extraction can be turned off if malicious data are not an issue or if you run into an error 
    # like signal only works in main thread. In this case, the following code can be useful as it explicitly changes the 
    # required setting:
    newconfig = use_config()
    newconfig.set("DEFAULT", "EXTRACTION_TIMEOUT", "0")

    # Run Trafilatura
    text_result = extract(
        downloaded, 
        include_links=False, # > Configs
        # include_formatting=True,  #(only valuable if output_format is set to XML)
        include_tables=False,
        include_images=False, 
        output_format='text',
        deduplicate=True, 
        url_blacklist=set(), # Edited in core -> extract() -> bare_extraction() -> extract_metadata() -> check_authors()
        favor_precision = True, 
        favor_recall = False,
        #bare_extraction = False,
        no_fallback=True,           # > Optimizing for speed
        include_comments=False,
        config=newconfig,           # > Disabling signal
        date_extraction_params={    # > Date formating
            "extensive_search": False, 
            'outputformat': 'dd-MM-yyyy hh:mm:ss', 
            'original_date': True    
            #"max_date": "2018-07-01"
        }
    )

    return text_result
    
# Run Model NeuralQA
def neuralqa_req(context, questions, reader='distilbert'):
    url = "http://127.0.0.1:8888/api/answers"
    if reader == 'distilbert':
        model = "twmkn9/distilbert-base-uncased-squad2"
    elif reader == 'bert':
        model = "deepset/bert-base-cased-squad2"
    else:
        print("Invalid Reader!\nValid Readers: ['distilbert', 'bert']")
        return None
    result = list()
    for question in questions:
        payload = {
            "max_documents": 5,
            "context": context,
            "query": question,
            "fragment_size": 350,
            "reader": model,
            "retriever": "none",
            "tokenstride": 0,
            "relsnip": True,
            "expansionterms": []
        }
        response = requests.request("POST", url, json=payload)
        print(f"Question: {question}")
        print(f"Qtty of answers = {len(response.json()['answers'])}\n")
        result.append(response.json())
    return result

# Generate Tables from html as CSV | Excel
def gen_tabel_files(url, html_file, refresh_html=False, csv=False, excel=False):
    url_to_filename = clean_filename(url)

    # Create Directories if Required
    dir_path = os.path.join(Path.cwd(), "gen_files", "tables")
    if not os.path.exists(f"{dir_path}"):
        os.makedirs(dir_path)

    # Gen Pandas DataFrame
    dataframe = pd.read_html(html_file)
    
    # Gen Excel/CSV Files
    if excel:
        excel_file_path = os.path.join(dir_path, f"excel_tables_{url_to_filename}.xlsx")
    
    if not csv: # Only Requested EXCEL
        if not os.path.exists(excel_file_path) or refresh_html:
            with pd.ExcelWriter(excel_file_path) as writer:
                for count, table in enumerate(dataframe):
                    table.to_excel(writer, sheet_name=f"Table{count+1}")
        return {"excel": excel_file_path}
    else:
        # Create Directory for CSV tables
        csv_path = os.path.join(dir_path, f"csv_tables_{url_to_filename}")
        if os.path.exists(csv_path) and refresh_html:
            shutil.rmtree(csv_path)
        if not os.path.exists(csv_path):
            os.mkdir(csv_path)

    if not excel: # Only Requested CSV
        if len(os.listdir(csv_path)) == 0:
            for count, table in enumerate(dataframe):
                table.to_csv(os.path.join(csv_path, f"table{count+1}.csv"), sep=",", index=None)
        return {"csv": csv_path}
    
    else:         # Requested CSV and EXCEL
        gen_excel = False
        gen_csv = False
        if not os.path.exists(excel_file_path) or refresh_html:
            gen_excel = True
        if os.listdir(csv_path) == 0:
            gen_csv = True

        if gen_excel and gen_csv:
            with pd.ExcelWriter(excel_file_path) as writer:
                for count, table in enumerate(dataframe):
                    table.to_excel(writer, sheet_name=f"Table{count+1}")
                    table.to_csv(os.path.join(csv_path, f"table{count+1}.csv"), sep=",", index=None)
        elif gen_excel:
            with pd.ExcelWriter(excel_file_path) as writer:
                for count, table in enumerate(dataframe):
                    table.to_excel(writer, sheet_name=f"Table{count+1}")
        elif gen_csv:
            for count, table in enumerate(dataframe):
                table.to_csv(os.path.join(csv_path, f"table{count+1}.csv"), sep=",", index=None)

        return {
            "excel": excel_file_path,
            "csv": csv_path
        }

# Check Scraped URLS
def get_html_file(url):
    # encoded_url = urllib.parse.quote(url)
    url_to_filename = clean_filename(url)
    file_path = os.path.join(Path.cwd(), "gen_files", "html", f"{url_to_filename}.html")
    if os.path.exists(file_path):
        return file_path
    else:
        return None
    
# Generate HTML file
def gen_html_file(url, html):
    dir_path = os.path.join(Path.cwd(), "gen_files", "html")
    if not os.path.exists(f"{dir_path}"):
        os.makedirs(dir_path)
        
    url_to_filename = clean_filename(url)
    file_path = os.path.join(dir_path, f"{url_to_filename}.html")
    
    with open(file_path, "w", encoding="utf-8") as fw:
        fw.write(html)

    return file_path

# Convert URL to Filename
def clean_filename(filename, replace=' '):
    """ Credits to @wassname
    Url: https://gist.github.com/wassname/1393c4a57cfcbf03641dbc31886123b8
    """
    whitelist = "-_.() %s%s" % (string.ascii_letters, string.digits)    # valid_filename_chars
    char_limit = 255
    # replace spaces
    for r in replace:
        filename = filename.replace(r,'_')
    
    # keep only valid ascii chars
    cleaned_filename = unicodedata.normalize('NFKD', filename).encode('ASCII', 'ignore').decode()
    
    # keep only whitelisted chars
    cleaned_filename = ''.join(c for c in cleaned_filename if c in whitelist)
    if len(cleaned_filename)>char_limit:
        print(f"Warning, filename truncated because it was over {char_limit}. Filenames may no longer be unique")
    return cleaned_filename[:char_limit]    