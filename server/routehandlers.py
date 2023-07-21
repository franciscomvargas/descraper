from fastapi import APIRouter
from .routemodels import Scrape, Expansion
from scraper.webscraper import *
from question_answer.qa import *
import time
from http.client import responses

# class Scrape(BaseModel):
#     url: str = "https://en.wikipedia.org/wiki/The_Simpsons"
#     query: Optional[list] = ["When the simpsons debut?"]
#     html_text: Optional[bool] = False # Return Trafilatura result
#     qa_port: Optional[int] = 8888  # NeuralQA Service port
#     expansionterms: Optional[list] = []
#     overwrite_files: Optional[bool] = False
#     excel: Optional[bool] = False
#     csv: Optional[bool] = False

class Handler:
    def __init__(self):
        router = APIRouter()
        self.router = router

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
        
        @router.post("/scraper")
        async def get_scraper(params: Scrape):
            response = {}
            start_time = time.time()
            if params.url == "":
                return{
                    "error": "DeScraper Input Params failure: Required `url`",
                    "took": time.time() - start_time
                }
            # Get HTML Page
            scraper_res = html_scrape(params.url, overwrite_files=params.overwrite_files)
            if scraper_res['request_status'] != 200:
                return{
                    "error": scraper_res['error'],
                    "status_code": scraper_res['request_status'],
                    "status_meaning": responses[scraper_res['request_status']],
                    "took": time.time() - start_time
                }
            
            response["html"] = scraper_res['html_file'] # The html file path is allways returned
            
            if params.html_text:            # RUN Trafilatura Result
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