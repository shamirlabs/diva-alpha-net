#!/bin/bash

exec_path=$1
cd $exec_path

docker stop diva
docker start diva
