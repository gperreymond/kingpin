#!/bin/bash

docker-compose down

docker volume prune
docker system prune
docker image prune
