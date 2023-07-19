from pydantic import BaseModel
from typing import Optional

class Scrape(BaseModel):
    url: str = "https://en.wikipedia.org/wiki/The_Simpsons"
    query: Optional[list] = ["When the simpsons debut?"]
    html_text: Optional[bool] = False # Return Trafilatura result
    qa_port: Optional[int] = 8888  # NeuralQA Service port
    explanation: Optional[bool] = False
    overwrite_files: Optional[bool] = False
    excel: Optional[bool] = False
    csv: Optional[bool] = False