from fastapi import APIRouter
from .routemodels import Scrape, Expansion
from scraper.webscraper import *
from question_answer.qa import *
import time
from http.client import responses
import json

# class Scrape(BaseModel):
#     url: Optional[str] = "https://en.wikipedia.org/wiki/The_Simpsons"
#     html: Optional[str] = ""
#     html_encoding: Optional[str] = "utf-8"
#     query: Optional[list] = []
#     html_text: Optional[bool] = False # Return Trafilatura result
#     qa_port: Optional[int] = 8888  # NeuralQA Service port
#     expansionterms: Optional[list] = []
#     overwrite_files: Optional[bool] = False
#     excel: Optional[bool] = False
#     csv: Optional[bool] = False

# class Expansion(BaseModel):
#     query: list = ["what is a fourth amendment right violation?"]

class Handler:
    def __init__(self):
        router = APIRouter()
        self.router = router

        @router.get("/handshake")
        async def get_handshake():
            return{"status":"ready"}
        
        @router.post("/expand")
        async def get_expansion(params: Expansion):
            """Return  an expansion for a given query

            Returns:
                [dictionary]: [expansion]
            """
            start_time = time.time()
            expanded_queries = neuralqa_expand(params.query)
            result_json = {}
            expansion_json = []
            for count, expanded_query in enumerate(expanded_queries):
                result_json[count] = {
                    "terms": expanded_query["terms"],
                    "expansions": expanded_query["expansions"],
                    "took": expanded_query["took"],
                }
            result_json["took"] = time.time() - start_time
            return result_json
        
        @router.post("/url")
        async def get_url_scraper(params: Scrape):
            response = {}
            start_time = time.time()
            print_params = {
                'url': params.url,
                'html': params.html,
                'query': params.query,
                'html_text': params.html_text,
                'qa_port': params.qa_port,
                'expansionterms': params.expansionterms,
                'overwrite_files': params.overwrite_files,
                'excel': params.excel,
                'csv': params.csv
            }
            print(f"Incoming request Payload:\n{json.dumps(print_params, indent=2)}")
            if params.url == "":
                return{
                    "error": "DeScraper Input Params failure: Required `url`",
                    "took": time.time() - start_time
                }
            # Get HTML Page
            scraper_res = url_scrape(params.url, overwrite_files=params.overwrite_files)
            if scraper_res['request_status'] != 200:
                return{
                    "error": scraper_res['error'],
                    "status_code": scraper_res['request_status'],
                    "status_meaning": responses[scraper_res['request_status']],
                    "took": time.time() - start_time
                }
            
            response["html"] = scraper_res['html_file'] # The html file path is allways returned
            
            if params.html_text:            # RUN Trafilatura HTML2TXT
                response["html_text"] = run_trafilatura(scraper_res['html_file'])

            if isinstance(params.query, list) and len(params.query) > 0:                   # RUN NeuraQA
                response["qa"] = neuralqa_req(
                    response["html_text"] if params.html_text else run_trafilatura(scraper_res['html_file']),   # Context of QA is result of Trafilatura (HTML2TxT)
                    params.query,
                    expansionterms = params.expansionterms,
                    neuralqa_port = params.qa_port,
                    reader='distilbert'
                )


                
            if params.csv or params.excel:  # Generate Tables files
                gen_tables_res = gen_tabel_files(params.url, scraper_res['html_file'], overwrite_files=params.overwrite_files, csv=params.csv, excel=params.excel)
                for k, v in gen_tables_res.items():
                    response[k] = v
                
            response["took"] = time.time() - start_time
            return response
        
        @router.post("/html")
        async def get_html_scraper(params: Scrape):
            response = {}
            start_time = time.time()
            print_params = {
                'url': params.url,
                'html': params.html,
                'html_encoding': params.html_encoding,
                'query': params.query,
                'html_text': params.html_text,
                'qa_port': params.qa_port,
                'expansionterms': params.expansionterms,
                'overwrite_files': params.overwrite_files,
                'excel': params.excel,
                'csv': params.csv
            }
            print(f"Incoming request Payload:\n{json.dumps(print_params, indent=2)}")
            if params.html == "":
                return{
                    "error": "DeScraper Input Params failure: Required `html`",
                    "took": time.time() - start_time
                }
            
            response["html"] = params.html # The html file path is allways returned
            
            if params.html_text:            # RUN Trafilatura HTML2TXT
                response["html_text"] = run_trafilatura(params.html, html_encoding=params.html_encoding)

            if isinstance(params.query, list) and len(params.query) > 0:                   # RUN NeuraQA
                response["qa"] = neuralqa_req(
                    response["html_text"] if params.html_text else run_trafilatura(params.html),   # Context of QA is result of Trafilatura (HTML2TxT)
                    params.query,
                    expansionterms = params.expansionterms,
                    neuralqa_port = params.qa_port,
                    reader='distilbert'
                )


                
            if params.csv or params.excel:  # Generate Tables files
                gen_tables_res = gen_tabel_files(params.url, params.html, overwrite_files=params.overwrite_files, csv=params.csv, excel=params.excel)
                for k, v in gen_tables_res.items():
                    response[k] = v
                
            response["took"] = time.time() - start_time

            return response