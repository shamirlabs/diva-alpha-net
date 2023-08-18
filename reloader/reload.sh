#!/bin/bash

# Docker environment variables

# VALIDATOR_RKM_API="127.0.0.1:7500"
# DIVA_W3S_API="127.0.0.1:9000"
# SYNC_PERIOD=600

# Local variables
VALIDATOR_RKM_API_TOKEN_PATH="/jwt/auth-token"
W3S_KEYS_FILE="/w3skeys.json"
VALIDATOR_RKM_API_TOKEN=$(cat $VALIDATOR_RKM_API_TOKEN_PATH | sed -n '2 p')

while [ true ]; do
    echo "----------------------------------"
    echo "Reloading..."
    echo ""

    # If w3s keys file exists, delete it
    if [ -f $W3S_KEYS_FILE ]; then
        rm -f $W3S_KEYS_FILE
    fi
    curl -s $DIVA_W3S_API/api/v1/eth2/publicKeys | jq . > $W3S_KEYS_FILE

    PUB_KEYS_LENGTH=0
    FILE_LENGTH=$(wc -m < $W3S_KEYS_FILE)
    if [ $FILE_LENGTH -ne 0 ]; then
        PUB_KEYS_LENGTH=$(cat $W3S_KEYS_FILE | jq length)
    else
        echo "Empty response"
    fi

    if [ $PUB_KEYS_LENGTH -ne 0 ]; then
        echo "Syncing $PUB_KEYS_LENGTH public keys..."
        echo "Got:"
        cat $W3S_KEYS_FILE | jq .
        echo ""
        echo "Sending to $VALIDATOR_RKM_API..."

        # curl -s "http://127.0.0.1:7500/eth/v1/remotekeys" -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.J1_zJUJ2jKFWjRPbGwhXUgWcWlUfJs9zzTHEzXjcL1k' | jq .

        pub_key_index=0
        while [ "$pub_key_index" -lt $PUB_KEYS_LENGTH ]; do
            w3s_pub_key=$(cat $W3S_KEYS_FILE | jq -r ".[$pub_key_index]")

            curl -s POST "$VALIDATOR_RKM_API/eth/v1/remotekeys" \
            -H "accept: application/json" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $VALIDATOR_RKM_API_TOKEN" \
            -d "{\"remote_keys\":[{\"pubkey\":\"$w3s_pub_key\"}]}" \
            | jq .

            pub_key_index=$((pub_key_index+1))
        done

        echo ""
        echo "Sleeping for $SYNC_PERIOD seconds..."
    else
        echo "No public keys found in $DIVA_W3S_API/api/v1/eth2/publicKeys"
        echo "Sleeping for $SYNC_PERIOD seconds..."
    fi

    echo "----------------------------------"
    echo ""
    sleep $SYNC_PERIOD
done
