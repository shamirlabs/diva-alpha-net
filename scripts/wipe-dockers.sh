#!/bin/bash

docker stop diva validator vector node-exporter prometheus operator-ui jaeger reloader
docker rm diva validator vector node-exporter prometheus operator-ui jaeger reloader
docker rmi $(docker images -a -q) #TODO: Ideally this only targets the diva created images in the future
docker system prune -f
