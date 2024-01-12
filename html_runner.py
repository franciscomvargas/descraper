import os, sys
import time, re, json, shutil
import requests, subprocess
import yaml
from yaml.loader import SafeLoader

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-mr", "--model_req", 
                    help="DeSOTA Request as yaml file path",
                    type=str)
parser.add_argument("-mru", "--model_res_url",
                    help="DeSOTA API Result URL. Recognize path instead of url for desota tests", # check how is atribuited the test_mode variable in main function
                    type=str)

DEBUG = False

# DeSOTA Funcs [START]
#   > Import DeSOTA Scripts
from desota import detools
#   > Grab DeSOTA Paths
USER_SYS = detools.get_platform()
APP_PATH = os.path.dirname(os.path.realpath(__file__))
#   > USER_PATH
if USER_SYS == "win":
    path_split = str(APP_PATH).split("\\")
    desota_idx = [ps.lower() for ps in path_split].index("desota")
    USER=path_split[desota_idx-1]
    USER_PATH = "\\".join(path_split[:desota_idx])
elif USER_SYS == "lin":
    path_split = str(APP_PATH).split("/")
    desota_idx = [ps.lower() for ps in path_split].index("desota")
    USER=path_split[desota_idx-1]
    USER_PATH = "/".join(path_split[:desota_idx])
DESOTA_ROOT_PATH = os.path.join(USER_PATH, "Desota")
# DeSOTA Funcs [END]

def descraper_request(descraper_url, payload, headers) -> dict|None:
    descraper_response = requests.request("POST", descraper_url, json=payload, headers=headers)
    if descraper_response.status_code != 200:
        print(f"[ ERROR ] -> Descraper Request Failed (Info):\n\tResponse Code = {descraper_response.status_code}")
        return None

    descraper_res = descraper_response.json()
    if 'error' in descraper_res or not descraper_res:
        print(f"[ ERROR ] -> Descraper Response Error (Info):{json.dumps(descraper_res, indent=2)}")
        return None
    return descraper_res

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
    _report_start_time = time.time()
    start_time = int(_report_start_time)

    #---INPUT---# TODO (PRO ARGS)
    #---INPUT---#

    # DeSOTA Model Request
    model_request_dict = detools.get_model_req(args.model_req)

    # API Response URL
    result_id = args.model_res_url
    
    # TARGET File Path
    dir_path = os.path.dirname(os.path.realpath(__file__))
    out_filepath = os.path.join(dir_path, f"html-to-text_{start_time}.txt")
    out_urls = detools.get_url_from_str(result_id)
    if len(out_urls)==0:
        test_mode = True
        report_path = result_id
    else:
        test_mode = False
        send_task_url = out_urls[0]

    # Get html file
    req_html = detools.get_request_html(model_request_dict)
    
    if req_html:
        for reqc, (html_file, html_encoding) in enumerate(req_html):
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
            descraper_res = descraper_request(descraper_url, payload, headers)
            if html_file:
                os.remove(html_file)
            if descraper_res:
                break
            elif reqc == len(req_html)-1:
                exit(2)
    else:
        _req_url = detools.get_request_url(model_request_dict)

        if not _req_url:
            print(f"[ ERROR ] -> Descraper Request Failed: No HTML ! ULR found")
            exit(1)
        
        for reqc, _url in enumerate(_req_url):
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

            descraper_res = descraper_request(descraper_url, payload, headers)
            if descraper_res:
                break
            elif reqc == len(req_html)-1:
                exit(2)

    if not descraper_res:
        print(f"[ ERROR ] -> Descraper Output ERROR: No results can be parsed for this request")
        exit(2)
        
    print(f"[ INFO ] -> Descraper Response:\n{json.dumps(descraper_res, indent=2)}")
    
    # DeSOTA API Response Preparation
    with open(out_filepath, 'w', encoding="utf-8") as fw:
        fw.write(descraper_res["html_text"] if "html_text" in descraper_res else json.dumps(descraper_res))
    
    if test_mode:
        if not report_path.endswith(".json"):
            report_path += ".json"
        with open(report_path, "w") as rw:
            json.dump(
                {
                    "Model Result Path": out_filepath,
                    "Processing Time": time.time() - _report_start_time
                },
                rw,
                indent=2
            )
        detools.user_chown(report_path)
        detools.user_chown(out_filepath)
        print(f"Path to report:\n\t{report_path}")
    else:
        files = []
        with open(out_filepath, 'rb') as fr:
            files.append(('upload[]', fr))
            # DeSOTA API Response Post
            send_task = requests.post(url = send_task_url, files=files)
            print(f"[ INFO ] -> DeSOTA API Upload Res:\n{json.dumps(send_task.json(), indent=2)}")
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