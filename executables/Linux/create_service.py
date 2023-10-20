import os
CURR_PATH = os.path.dirname(os.path.realpath(__file__))

TARGET_RUN_FILE = os.path.join(CURR_PATH, "descraper.service.bash")
TARGET_SERV_FILE = os.path.join(CURR_PATH, "descraper.service")
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-uh", "--user_home", 
    help="Specify User PATH to handle with admin requests",
    type=str)
args = parser.parse_args()
USER_PATH=None
if args.user_home:
    if os.path.isdir(args.user_home):
        USER_PATH = args.user_home
if not USER_PATH:
    USER_PATH = os.path.expanduser('~')

# SERVICE RUNNER
TEMPLATE_SERVICE_RUNNER='''#!/bin/bash
# GET USER PATH
while true
do
    %USER_HOME%/Desota/Desota_Models/DeScraper/env/bin/python3 %USER_HOME%/Desota/Desota_Models/DeScraper/cli.py ui --host 127.0.0.1 --port 8880
done
# Inform Crawl Finish
echo Service as Terminated !'''

with open(TARGET_RUN_FILE, "w") as fw:
    fw.write(TEMPLATE_SERVICE_RUNNER.replace("%USER_HOME%", USER_PATH))

# SERVICE FILE
TEMPLATE_SERVICE='''[Unit]
Description=Desota/DeScraper - WebScraper assisted by AI Models 
After=network.target
StartLimitIntervalSec=0
StartLimitBurst=5
StartLimitAction=reboot.

[Service]
Type=simple
Restart=always
RestartSec=2
ExecStart=/bin/bash %USER_HOME%/Desota/Desota_Models/DeScraper/executables/Linux/descraper.service.bash

[Install]
WantedBy=multi-user.target'''

with open(TARGET_SERV_FILE, "w") as fw:
    fw.write(TEMPLATE_SERVICE.replace("%USER_HOME%", USER_PATH))
    
    
USER=USER_PATH.split("/")[-1]
os.system(f"chown -R {USER} {TARGET_RUN_FILE}")
os.system(f"chown -R {USER} {TARGET_SERV_FILE}")
exit(0)

