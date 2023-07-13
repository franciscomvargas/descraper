from fastapi import FastAPI
from .routehandlers import Handler

app = FastAPI()
api = FastAPI(root_path="/api")

app.mount("/api", api)

handlers = Handler()
api.include_router(handlers.router)