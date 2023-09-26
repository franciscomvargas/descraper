import os
import time
import requests
import yaml
from yaml.loader import SafeLoader
import json

from runner_utils.utils import *

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-mr", "--model_req", 
                    help="DeSOTA Request as yaml file path",
                    type=str)
parser.add_argument("-mru", "--model_res_url",
                    help="DeSOTA API Rsponse URL for model results",
                    type=str)

# DeSOTA Funcs
def get_model_req(req_path):
    '''
    {
        "task_type": None,      # TASK VARS
        "task_model": None,
        "task_dep": None,
        "task_args": None,
        "task_id": None,
        "filename": None,       # FILE VARS
        "file_url": None,
        "text_prompt": None     # TXT VAR
    }
    '''
    if not os.path.isfile(req_path):
        exit(1)
    with open(req_path) as f:
        return yaml.load(f, Loader=SafeLoader)

def main(args):
    '''
    return codes:
    0 = SUCESS
    1 = INPUT ERROR
    2 = OUTPUT ERROR
    3 = API RESPONSE ERROR
    9 = REINSTALL MODEL (critical fail)
    '''
    # Time when grabed
    start_time = int(time.time())

    # DeSOTA Model Request
    model_request_dict = get_model_req(args.model_req)
    
    # API Response URL
    send_task_url = args.model_res_url
    
    # TMP File Path
    dir_path = os.path.dirname(os.path.realpath(__file__))
    out_filepath = os.path.join(dir_path, f"url-to-text{start_time}.txt")
    
    # Get url from request
    _req_urls = get_request_url(model_request_dict)
                
    # Input Error - ret 1
    descraper_res = None
    if _req_urls:
        for _req_url in _req_urls:
            # Descraper Request Preparation
            payload = {
                "url": _req_url,
                "html_text": True,
                "overwrite_files": False
            }
            headers = {
                "Accept": "application/json, text/javascript, */*; q=0.01",
                "Connection": "keep-alive",
                "Content-Type": "application/json; charset=UTF-8"
            }

            # Descraper Request
            print(f"[ INFO ] -> Descraper Request Payload:\n{json.dumps(payload, indent=2)}")
            descraper_url = "http://127.0.0.1:8880/api/url"

            descraper_response = requests.request("POST", descraper_url, json=payload, headers=headers)
    
            if descraper_response.status_code != 200:
                continue

            descraper_json_res = descraper_response.json()
            if 'error' in descraper_json_res:
                continue

            if "html_text" in descraper_json_res and descraper_json_res["html_text"]:
                descraper_res = descraper_json_res["html_text"] 
                break

    else:
        html_file, html_encoding = get_request_html(model_request_dict, from_url=True)
        if not html_file:
            print(f"[ ERROR ] -> Descraper Request Failed: No HTML | ULR found")
            exit(1)

        # Descraper Request Preparation
        payload = {
            "html": html_file,
            "html_encoding": html_encoding,
            "html_text": True,
            "overwrite_files": False
        }
        headers = {
            "Accept": "application/json, text/javascript, */*; q=0.01",
            "Connection": "keep-alive",
            "Content-Type": "application/json; charset=UTF-8"
        }
        # Descraper Request
        print(f"[ INFO ] -> Descraper Request Payload:\n{json.dumps(payload, indent=2)}")
        descraper_url = "http://127.0.0.1:8880/api/html"

        descraper_response = requests.request("POST", descraper_url, json=payload, headers=headers)

        if descraper_response.status_code != 200:
            print(f"[ ERROR ] -> Descraper Request Code: {descraper_response.status_code}")
            exit(1)
        
        descraper_json_res = descraper_response.json()
        if 'error' in descraper_json_res:
            print(f"[ ERROR ] -> Descraper Output ERROR: {json.dumps(descraper_json_res, indent=2)}")
            exit(2)

        if "html_text" in descraper_json_res and descraper_json_res["html_text"]:
            descraper_res = descraper_json_res["html_text"]
    
    if not descraper_res:
        print(f"[ ERROR ] -> Descraper Output ERROR: No results can be parsed for this request")
        exit(2)


    print(f"[ INFO ] -> Descraper Response:{json.dumps(descraper_res, indent=2)}")
    
    # DeSOTA API Response Preparation
    with open(out_filepath, 'w', encoding="utf-8") as fw:
        fw.write(descraper_res)
    files = []
    with open(out_filepath, 'rb') as fr:
        files.append(('upload[]', fr))
        # DeSOTA API Response Post
        send_task = requests.post(url = send_task_url, files=files)
        print(f"[ INFO ] -> DeSOTA API Upload:{json.dumps(send_task.json(), indent=2)}")
    # Delete temporary file
    os.remove(out_filepath)

    if send_task.status_code != 200:
        print(f"[ ERROR ] -> Descraper Post Failed (Info):\nfiles: {files}\nResponse Code: {send_task.status_code}")
        exit(3)
    
    print("TASK OK!")
    exit(0)


if __name__ == "__main__":
    args = parser.parse_args()
    if not args.model_req or not args.model_res_url:
        raise EnvironmentError()
    main(args)