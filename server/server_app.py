import uvicorn


def launch_server(host="127.0.0.1", port=8880, workers=1, reload=False):
    uvicorn.run("server.serve:app", host=host, port=port, workers=workers,
                log_level="info", reload=reload)


if __name__ == "__main__":
    launch_server()