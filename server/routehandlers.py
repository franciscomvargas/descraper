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
#     html: Optional[bool] = False
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

            scraper_res = html_scrape(params.url)
            if params.html:
                response["html"] = scraper_res['html']
                
            if params.html_text:    # Return Trafilatura result
                response["html_text"] = scraper_res['text']

            if params.qa:
                response["qa"] = neuralqa_req(scraper_res['text'], params.query, reader='distilbert')

            if params.csv or params.excel:
                gen_tables_res = gen_tabel_files(scraper_res['tables'], csv=params.csv, excel=params.excel)
                for k, v in gen_tables_res.items():
                    response[k] = v
                
            response["took"] = time.time() - start_time
            return response