#!/bin/bash

cd $(dirname -- "$0")

exec_path=$(pwd)

if ! command -v dialog &> /dev/null
then
    echo "dialog could not be found. Installing dialog"
    if [[ $OSTYPE == 'darwin'* ]]; then
        brew install dialog
    else
        sudo apt install dialog -y
    fi
fi


HEIGHT=16
WIDTH=40
CHOICE_HEIGHT=8
BACKTITLE="Script Options"
TITLE="Diva Alpha testnet"
MENU="Select one of the following options:"

OPTIONS=(1 "Install Diva"
         2 "Update Diva"
         3 "Start all containers"
         4 "Stop all containers"
         5 "Restart Diva container"
         6 "Install docker"
         7 "Wipe all docker containers and images"
         8 "Edit environment variables")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            ./scripts/install-diva.sh $exec_path
            ;;
        2)
            ./scripts/cmd/update-diva.sh $exec_path
            ;;
        3)
            ./scripts/cmd/start-all.sh $exec_path
            ;;
        4)
            ./scripts/cmd/stop-all.sh $exec_path
            ;;
        5)
            ./scripts/cmd/restart-diva.sh $exec_path
            ;;
        6)
            ./scripts/install-docker.sh
            ;;
        7)
            ./scripts/wipe-dockers.sh
            ;;
        8)
            echo "Not implemented"
            ;;
esac
