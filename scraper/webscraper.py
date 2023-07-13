from pathlib import Path
import os
import time
import random
import json
import pandas as pd
import httpx
import requests

#TRAFILATURA - HTML TO TEXT
#Instalation:
 # https://trafilatura.readthedocs.io/en/latest/installation.html
#Documentation
 # https://trafilatura.readthedocs.io/en/latest/usage-python.html

# load necessary components
from trafilatura import extract
#Disabling signal
# A timeout exit during extraction can be turned off if malicious data are not an issue or if you run into an error 
# like signal only works in main thread. In this case, the following code can be useful as it explicitly changes the 
# required setting:
from trafilatura.settings import use_config
def html_scrape(url):
    # Fetch Font Page html
    fetch_retry_counter = 7
    while True:
        downloaded = httpx.get(url)
        print('Fetch Status:', downloaded.status_code)
        if downloaded.status_code != 200:  # assuming the download was successful
            fetch_retry_counter -= 1
            if fetch_retry_counter == 0:
                return {'error': 'Fetch error'}
            # Alta Func!!
            time.sleep(2 + random.uniform(0, 0.5))    # Xoné moñé
            print()
            continue
        # else:
        break
    downloaded = downloaded.text
    #Disabling signal
    # A timeout exit during extraction can be turned off if malicious data are not an issue or if you run into an error 
    # like signal only works in main thread. In this case, the following code can be useful as it explicitly changes the 
    # required setting:
    newconfig = use_config()
    newconfig.set("DEFAULT", "EXTRACTION_TIMEOUT", "0")

    #Threshhold Chat GPT
    # utilize while is not emplemented sumarization
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

    # Handle Pege tables
    tables_result = pd.read_html(downloaded)

    return {
        'html': downloaded,
        'text': text_result, 
        'tables': tables_result
    }
    
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
def gen_tabel_files(dataframe, csv=False, excel=False):
    dir_path = os.path.join(Path.cwd(), "gen_files")
    start_time = time.time()
    if not os.path.exists(f"{dir_path}"):
        os.mkdir(dir_path)
    
    if excel:
        excel_file_path = os.path.join(dir_path, f"excel_tables_{start_time}.xlsx")

    if not csv:
        with pd.ExcelWriter(excel_file_path) as writer:
            for count, table in enumerate(dataframe):
                table.to_excel(writer, sheet_name=f"Table{count+1}")
        return {"excel": excel_file_path}
    else:
        csv_path = os.path.join(dir_path, f"csv_tables_{start_time}")
        if not os.path.exists(csv_path):
            os.mkdir(csv_path)

    if not excel:
        for count, table in enumerate(dataframe):
            table.to_csv(os.path.join(csv_path, f"table{count+1}.csv"), sep=",", index=None)
        return {"csv": csv_path}
    else:
        with pd.ExcelWriter(excel_file_path) as writer:
            for count, table in enumerate(dataframe):
                table.to_excel(writer, sheet_name=f"Table{count+1}")
                table.to_csv(os.path.join(csv_path, f"table{count+1}.csv"), sep=",", index=None)
        return {
            "excel": excel_file_path,
            "csv": csv_path
        }