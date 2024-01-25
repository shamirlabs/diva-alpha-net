#!/bin/bash

exec_path=$1
cd $exec_path

git reset --hard origin/main
git pull
source .env.example

sed -i.bak -e "s/^DIVA_VERSION *=.*/DIVA_VERSION=${DIVA_VERSION}/" .env
sed -i.bak -e "s/^RELOADER_VERSION *=.*/RELOADER_VERSION=${RELOADER_VERSION}/" .env
sed -i.bak -e "s/^OPERATOR_UI_VERSION *=.*/OPERATOR_UI_VERSION=${OPERATOR_UI_VERSION}/" .env
sed -i.bak -e "s/^JAEGER_VERSION *=.*/JAEGER_VERSION=${JAEGER_VERSION}/" .env
sed -i.bak -e "s/^VECTOR_VERSION *=.*/VECTOR_VERSION=${VECTOR_VERSION}/" .env

docker compose down
docker compose pull
docker compose up -d
