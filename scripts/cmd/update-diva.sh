#!/bin/bash

exec_path=$1
cd $exec_path

git pull
docker compose up -d
