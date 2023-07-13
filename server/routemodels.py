from pydantic import BaseModel
from typing import Optional

class Scrape(BaseModel):
    url: str = "https://en.wikipedia.org/wiki/The_Simpsons"
    query: list = ["When the simpsons debut?"]
    qa: bool = True  # Question Answer
    explanation: Optional[bool] = False
    html: Optional[bool] = False
    excel: Optional[bool] = False
    csv: Optional[bool] = False