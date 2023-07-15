import os
from fastapi import FastAPI
from .routehandlers import Handler
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

app = FastAPI()
api = FastAPI(root_path="/api")

root_file_path = os.path.dirname(os.path.abspath(__file__))
static_folder_root = os.path.join(root_file_path, "ui/build")

@app.get('/comingsoon')
async def index():
    return FileResponse(os.path.join(root_file_path, "ui/build/comingsoon.html"))

app.mount("/api", api)

app.mount(
    "/", 
    StaticFiles(
        directory=static_folder_root, 
        html=True
    ),
    name="ui"
)

handlers = Handler()
api.include_router(handlers.router)