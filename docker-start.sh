#!/bin/bash

docker-compose up --detach --force-recreate

sleep 10
docker exec -it nomad-client service docker start
