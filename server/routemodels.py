from pydantic import BaseModel
from typing import Optional

class Scrape(BaseModel):
    url: Optional[str] = "https://en.wikipedia.org/wiki/The_Simpsons"
    html: Optional[str] = ""
    html_encoding: Optional[str] = "utf-8"
    query: Optional[list] = []
    html_text: Optional[bool] = False # Return Trafilatura result
    qa_port: Optional[int] = 8888  # NeuralQA Service port
    expansionterms: Optional[list] = []
    overwrite_files: Optional[bool] = False
    excel: Optional[bool] = False
    csv: Optional[bool] = False

class Expansion(BaseModel):
    query: list = ["what is a fourth amendment right violation?"]