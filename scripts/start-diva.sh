#!/bin/bash
cd $(dirname -- "$0")

HEIGHT=10
WIDTH=40
TITLE="Install Diva"

if [[ ! -x "$(command -v docker)" ]]; then
    # Docker is not installed
    dialog --title "$TITLE" --yesno "This will close your session. You will have to login and execute the script again.\n\nAre you sure?" 0 0
    exitcode=$?;
    if [ $exitcode -ne 1 ]; 
    then
        ./install-docker.sh
        logout
    else
        exit 1
    fi
    clear
fi

git pull --quiet

if [[ -f "../.env" ]]; then
    TITLE="Install Diva"
    MENU=".env exists in the parent directory"

    dialog --title "$TITLE" --yesno "Do you want to overwrite it?" 0 0
    exitcode=$?;
    if [ $exitcode -eq 1 ]; 
    then
        rm -rf ../.env
        cp ../.env.example ../.env 
    fi
else
    echo ".env file does not exist in the parent directory."
    cp ../.env.example ../.env 
fi
