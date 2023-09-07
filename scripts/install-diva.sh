#!/bin/bash
cd $(dirname -- "$0")

exec_path=$1

HEIGHT=14
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

cd $exec_path
git pull --quiet

if [[ -f ".env" ]]; then
    # .env already exists
    dialog --title "$TITLE" --yesno ".env exists in the parent directory\n\nDo you want to keep it as .env.old?" 0 0
    exitcode=$?;
    if [ $exitcode -ne 1 ];
    then
        cp .env .env.old
        rm -rf .env
        cp .env.example .env
    fi
else
    cp .env.example .env
fi

dialog --title "$TITLE" --yesno "Do you want to run your own Ethereum clients in this machine?" 0 0
exitcode=$?;

if [ $exitcode -eq 1 ];
then

    MENU="Type the IP and PORT of your execution client RPC\n"
    WARN="Example: ws://HOST_IP:8546 for geth"

    while true
    do
        execution_client_url=$(dialog --clear \
                    --title  "$TITLE" \
                    --inputbox "$MENU \n$WARN" \
                    $HEIGHT $WIDTH 2>&1 >/dev/tty)

        exitcode=$?;
        if [ $exitcode -eq 1 ];
        then
            exit 1
        fi
        if ! [ -z "${execution_client_url}" ]
        then
            ## TODO: Check also the wss connection with wscat or similar
            # wscat -c "${exec_client_url}"
            # Ideally it should be tested from inside of a (wscat?) docker container so we ensure it connects to endpoints like ws://geth:8546

            sed -i.bak -e "s/^EXECUTION_CLIENT_URL *=.*/EXECUTION_CLIENT_URL=${execution_client_url}/" .env
            break
        else
            WARN="WebSocket connection error for \"${execution_client_url}\""
        fi
    clear
    done


    MENU="Type the IP and PORT of your consensus client REST API\n"
    WARN="Example: http://HOST_IP:3500 for prysm"

    while true
    do
        consensus_client_url=$(dialog --clear \
                    --title  "$TITLE" \
                    --inputbox "$MENU \n$WARN" \
                    $HEIGHT $WIDTH 2>&1 >/dev/tty)

        exitcode=$?;
        if [ $exitcode -eq 1 ];
        then
            exit 1
        fi

        status_code=$(curl --write-out '%{http_code}' --silent --output /dev/null $consensus_client_url/eth/v1/node/health)
        if [[ "$status_code" -eq 200 ]] ; then
            sed -i.bak -e "s/^CONSENSUS_CLIENT_URL *=.*/CONSENSUS_CLIENT_URL=${consensus_client_url}/" .env
            break
        else
            WARN="HTTP connection error for \"${consensus_client_url}\""
        fi
    clear
    done

    MENU="Type the IP and PORT of your beacon client RPC (without HTTP)\n"
    WARN="Example: HOST_IP:4000 for prysm"

    while true
    do
        beacon_client_url=$(dialog --clear \
                    --title  "$TITLE" \
                    --inputbox "$MENU \n$WARN" \
                    $HEIGHT $WIDTH 2>&1 >/dev/tty)

        exitcode=$?;
        if [ $exitcode -eq 1 ];
        then
            exit 1
        fi

        if ! [ -z "${beacon_client_url}" ]
        then
            sed -i.bak -e "s/^BEACON_RPC_PROVIDER *=.*/BEACON_RPC_PROVIDER=${beacon_client_url}/" .env
            break
        else
            WARN="Invalid Beacon RPC \"${beacon_client_url}\""
        fi
    clear
    done
else
    dialog --title "$TITLE" --yesno "Do you want to run a Grafana to monitor your node?" 0 0
    exitcode=$?;
    if [ $exitcode -ne 1 ];
    then
        sed -i.bak -e "s/^COMPOSE_PROFILES *=.*/COMPOSE_PROFILES=clients,metrics,telemetry/" .env
    else
        sed -i.bak -e "s/^COMPOSE_PROFILES *=.*/COMPOSE_PROFILES=clients,telemetry/" .env
    fi

    sed -i.bak -e "s/^EXECUTION_CLIENT_URL *=.*/EXECUTION_CLIENT_URL=ws:\/\/geth:8546/" .env
    sed -i.bak -e "s/^CONSENSUS_CLIENT_URL *=.*/CONSENSUS_CLIENT_URL=http:\/\/beacon:3500/" .env
    sed -i.bak -e "s/^BEACON_RPC_PROVIDER *=.*/BEACON_RPC_PROVIDER=beacon:4000/" .env
fi

MENU="Type the API key/password that you want to use to connect to your Diva node\n"
WARN='Example: UseSecureP4ssw0rd$!'

while true
do
    diva_api_key=$(dialog --clear \
                --title  "$TITLE" \
                --inputbox "$MENU \n$WARN" \
                $HEIGHT $WIDTH 2>&1 >/dev/tty)

    exitcode=$?;
    if [ $exitcode -eq 1 ];
    then
        exit 1
    fi

    if ! [ -z "${diva_api_key}" ]
    then
        sed -i.bak -e "s/^DIVA_API_KEY *=.*/DIVA_API_KEY=${diva_api_key}/" .env
        break
    else
        WARN="Invalid API key \"${diva_api_key}\""
    fi
clear
done

MENU="Type the username that you want to use in the Diva testnet\n"
WARN="Example: username-address"

while true
do
    username=$(dialog --clear \
                --title  "$TITLE" \
                --inputbox "$MENU \n$WARN" \
                $HEIGHT $WIDTH 2>&1 >/dev/tty)

    exitcode=$?;
    if [ $exitcode -eq 1 ];
    then
        exit 1
    fi

    if ! [ -z "${username}" ]
    then
        sed -i.bak -e "s/^TESTNET_USERNAME *=.*/TESTNET_USERNAME=${username}/" .env
        break
    else
        WARN="\"${username}\" is not a valid username"
    fi
clear
done

# Let's assume the vault_password should be generated randomly
vault_pw=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)
sed -i.bak -e "s/^DIVA_VAULT_PASSWORD *=.*/DIVA_VAULT_PASSWORD=${vault_pw}/" .env

export $(grep -v '^#' ./.env | sed 's/ *#.*//g' | xargs)
envsubst < "./prometheus/prometheus/prometheus_template.yaml" > "./prometheus/prometheus/prometheus.yaml"

./scripts/cmd/start-all.sh $exec_path
