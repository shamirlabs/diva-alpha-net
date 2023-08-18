#!/bin/bash

exec_path=$1
cd $exec_path

docker compose down
