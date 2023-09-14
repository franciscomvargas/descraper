import os
import time
import requests
import re

CURRENT_PATH = os.path.dirname(os.path.realpath(__file__))
API_UP =  "http://129.152.27.36/assistant/api_uploads"


# URL MODEL
def get_url_from_str(string):
    # retrieved from https://www.geeksforgeeks.org/python-check-url-string/
    # findall() has been used
    # with valid conditions for urls in string
    regex = r"(?i)\b((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'\".,<>?«»“”‘’]))"
    url = re.findall(regex, string)
    return [x[0] for x in url]

def get_request_url(model_request_dict):
    _req_url = None
    if 'url' in model_request_dict["input_args"]:
        _req_url = get_url_from_str(model_request_dict["input_args"]['url'])
    
    if not _req_url and 'text_prompt' in model_request_dict["input_args"]:
        _req_url = get_url_from_str(model_request_dict["input_args"]['text_prompt'])

    if not _req_url and 'file' in model_request_dict["input_args"]:
        if isinstance(model_request_dict["input_args"]["file"], str):
            _req_url = get_url_from_str(model_request_dict["input_args"]['file'])
        elif isinstance(model_request_dict["input_args"]["file"], list):
            for file in model_request_dict["input_args"]["file"]:
                _req_url = get_url_from_str(file)
                if _req_url:
                    break
    return _req_url


# HTML MOODEL
def get_html_from_str(string):
    # retrieved from https://stackoverflow.com/a/3642850 & https://stackoverflow.com/a/32680048
    pattern = re.compile(r'<html((.|[\n\r])*)\/html>')
    _res = pattern.search(string)
    if not _res:
        return None, None
    
    _html_content = f"<html{_res.group(1)}/html>"
    _tmp_html_path = os.path.join(CURRENT_PATH, f"tmp_html{int(time.time())}.html")
    with open(_tmp_html_path, "w") as fw:
        fw.write(_html_content)
    return _tmp_html_path, 'utf-8'

def get_html_from_url(file_url):
    
    base_filename = os.path.basename(file_url)
    file_path = os.path.join(CURRENT_PATH, base_filename)
    with  requests.get(file_url, stream=True) as req_file:
        if req_file.status_code != 200:
            return None, None
        
        if req_file.encoding is None:
            req_file.encoding = 'utf-8'

        with open(file_path, 'w') as fw:
            fw.write("")
        with open(file_path, 'a', encoding=req_file.encoding) as fa:
            for line in req_file.iter_lines(decode_unicode=True):
                if line:
                    fa.write(f"{line}\n")
                    # shutil.copyfileobj(req_file.raw, fwb)
    
    return file_path, req_file.encoding

def get_request_html(model_request_dict, from_url=False):
    html_file = None
    html_encoding = None
    if from_url and 'url' in model_request_dict["input_args"]:
        if model_request_dict["input_args"]["url"].endswith(".html"):
            html_file, html_encoding = get_html_from_url(f'{API_UP}/{model_request_dict["input_args"]["url"]}')
        else:
            html_file, html_encoding = get_html_from_str(model_request_dict["input_args"]["url"])

    if not html_file and 'html' in model_request_dict["input_args"]:
        if model_request_dict["input_args"]["html"].endswith(".html"):
            html_file, html_encoding = get_html_from_url(f'{API_UP}/{model_request_dict["input_args"]["html"]}')
        else:
            html_file, html_encoding = get_html_from_str(model_request_dict["input_args"]["html"])

    if not html_file and 'file' in model_request_dict["input_args"] and "file_name" in model_request_dict["input_args"]["file"] and model_request_dict["input_args"]["file"]["file_name"].endswith(".html") and "file_url" in model_request_dict["input_args"]["file"]:
            html_file, html_encoding = get_html_from_url(model_request_dict["input_args"]["file"]["file_url"])
            
    if not html_file and 'text_prompt' in model_request_dict["input_args"]:
        html_file, html_encoding = get_html_from_str(model_request_dict["input_args"]['text_prompt'])
        
    return html_file, html_encoding
