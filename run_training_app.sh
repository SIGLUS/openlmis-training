#!/usr/bin/env bash

#init all containers, and get trainingdb container id
docker-compose up -d && echo "Containers are booting up!" && DB_ID=$(docker ps -aqf "name=trainingdb")

chmod +x ./check_docker_container.sh
chmod +x ./setup_db.sh

#check status of trainingdb container, and set up seed data if it is running
./check_docker_container.sh $DB_ID && echo "setting data" && ./setup_db.sh
