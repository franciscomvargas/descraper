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
    out_filepath = os.path.join(dir_path, f"html-to-text_{start_time}.txt")
    
    # Get html file
    html_file, html_encoding = get_request_html(model_request_dict)
    
    if html_file:
        # if _req_url:
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

    else:
        _req_url = get_request_url(model_request_dict)

        if not _req_url:
            print(f"[ ERROR ] -> Descraper Request Failed: No HTML ! ULR found")
            exit(1)

        # Descraper Request Preparation
        payload = {
            "url": _req_url[0],
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

    descraper_res = descraper_response.json()

    os.remove(html_file)

    if descraper_response.status_code != 200:
        print(f"[ ERROR ] -> Descraper Request Failed (Info):\n\tResponse Code = {descraper_response.status_code}")
        exit(2)
    
    if 'error' in descraper_res:
        print(f"[ ERROR ] -> Descraper Response Error (Info):{json.dumps(descraper_res, indent=2)}")
        exit(2)
    
    print(f"[ INFO ] -> Descraper Response:\n{json.dumps(descraper_res, indent=2)}")
    
    # DeSOTA API Response Preparation
    with open(out_filepath, 'w', encoding="utf-8") as fw:
        fw.write(descraper_res["html_text"] if "html_text" in descraper_res else json.dumps(descraper_res))
    files = []
    with open(out_filepath, 'rb') as fr:
        files.append(('upload[]', fr))
        # DeSOTA API Response Post
        send_task = requests.post(url = send_task_url, files=files)
        print(f"[ INFO ] -> DeSOTA API Upload:\n{json.dumps(send_task.json(), indent=2)}")
    # Delete temporary file
    os.remove(out_filepath)

    if send_task.status_code != 200:
        print(f"[ ERROR ] -> Descraper Post Failed (Info):\nfiles: {files}\nResponse Code: {send_task.status_code}")
        exit(3)
    
    print("TASK OK!")
    exit(0)


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)