from fastapi import APIRouter
from .routemodels import Scrape
from scraper.webscraper import *
import time

# class Scrape(BaseModel):
#     url: str = None
#     query: str = None
#     html_text: bool = False   # Return Trafilatura result
#     qa: bool = True  # Question Answer
#     explanation: Optional[bool] = False
#     refresh_html: Optional[bool] = False
#     excel: Optional[bool] = False
#     csv: Optional[bool] = False

class Handler:
    def __init__(self):
        router = APIRouter()
        self.router = router

        @router.post("/scraper")
        async def get_scraper(params: Scrape):
            response = {}
            start_time = time.time()

            # Get HTML Page
            scraper_res = html_scrape(params.url, refresh_html=params.refresh_html)
            if scraper_res['request_status'] != 200:
                return{
                    "error": "DeScraper failed to fetch url",
                    "status_code": scraper_res['request_status']
                }
            
            response["html"] = scraper_res['html_file'] # The html file path is allways returned
            
            if params.html_text:            # RUN Trafilatura Result
                response["html_text"] = run_trafilatura(scraper_res['html_file'])

            if params.qa:                   # RUN NeuraQA
                response["qa"] = neuralqa_req(
                    response["html_text"] if params.html_text else run_trafilatura(scraper_res['html_file']), 
                    params.query, 
                    reader='distilbert'
                )
                
            if params.csv or params.excel:  # Generate Tables files
                gen_tables_res = gen_tabel_files(scraper_res['html_file'], time=start_time, csv=params.csv, excel=params.excel)
                for k, v in gen_tables_res.items():
                    response[k] = v
                
            response["took"] = time.time() - start_time
            return response