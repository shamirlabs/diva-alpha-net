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

    dialog --title "$TITLE" --yesno ".env exists in the parent directory\n\nDo you want to overwrite it?" 0 0
    exitcode=$?;
    if [ $exitcode -eq 1 ]; 
    then
        rm -rf ../.env
        cp ../.env.example ../.env 
    fi
else
    cp ../.env.example ../.env 
fi

# MENU="Type the name of the SSH key that you want to use:"
# WARN=""

# while true
# do
# 	ssh_key_name=$(dialog --clear \
#                 --title  "$TITLE" \
#                 --inputbox "$MENU \n$WARN" \
#                 $HEIGHT $WIDTH 2>&1 >/dev/tty)

#     exitcode=$?;
#     if [ $exitcode -eq 1 ]; 
#     then
#         exit 1
#     fi
#     if ! [ -z "$ssh_key_name" ]
#     then
#         break
#     fi
# clear
# done




# MENU="Type the password of the root user:"
# WARN=""

# while true
# do
# 	password=$(dialog --clear \
#                 --title  "$TITLE" \
#                 --passwordbox "$MENU \n$WARN" \
#                 $HEIGHT $WIDTH 2>&1 >/dev/tty)

#     exitcode=$?;
#     if [ $exitcode -eq 1 ]; 
#     then
#         exit 1
#     elif ! check_ssh_password $ip $password ;
#     then
#         WARN="Incorrect password. Try again"
#     else
#         break
#     fi
# clear
# done


# MENU="Type the name that you want to give to the server"
# WARN=""

# while true
# do
# 	hostname=$(dialog --clear \
#                 --title  "$TITLE" \
#                 --inputbox "$MENU \n$WARN" \
#                 $HEIGHT $WIDTH 2>&1 >/dev/tty)

#     exitcode=$?;
#     if [ $exitcode -eq 1 ]; 
#     then
#         exit 1
#     fi
#     if ! [ -z "$hostname" ]
#     then
#         break
#     fi
# clear
# done

# dialog --title $TITLE --yesno "Do you want to create a new SSH key?" 0 0
# exitcode=$?;
# if [ $exitcode -eq 1 ]; 
# then
#     create_new_ssh=false
# else
#     create_new_ssh=true
# fi

# MENU="Type the name of the SSH key that you want to use:"
# WARN=""

# while true
# do
# 	ssh_key_name=$(dialog --clear \
#                 --title  "$TITLE" \
#                 --inputbox "$MENU \n$WARN" \
#                 $HEIGHT $WIDTH 2>&1 >/dev/tty)

#     exitcode=$?;
#     if [ $exitcode -eq 1 ]; 
#     then
#         exit 1
#     fi
#     if ! [ -z "$ssh_key_name" ]
#     then
#         break
#     fi
# clear
# done

# dialog --title $TITLE --yesno "The server $ip is going to be initialized.\nDo you want to continue?" 0 0
# exitcode=$?;
# if [ $exitcode -eq 1 ]; 
# then
#     exit 1
# fi

# clear

# if [ $create_new_ssh = true ];
# then
#     if [ -f "$HOME/.ssh/$ssh_key_name" ]; 
#     then
#         echo "$HOME/.ssh/$ssh_key_name exists"
#         dialog --title $TITLE --yesno "$HOME/.ssh/$ssh_key_name exists.\nDo you want to continue reusing this key?" 0 0
#         exitcode=$?;
#         if [ $exitcode -eq 1 ]; 
#         then
#             exit 1
#         fi
#         echo "Using previous SSH key $ssh_key_name."
#     else 
#         echo "Generating new SSH key $ssh_key_name."
#         new-ssh user $ssh_key_name
#     fi
# else
#     echo "Using previous SSH key $ssh_key_name."
# fi

# ../scripts/setup/init-server.sh -k $ssh_key_name -s $ip -r $password -h $hostname
