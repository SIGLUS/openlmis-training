#!/usr/bin/env bash

#init all containers, and get trainingdb container id
docker-compose rm --all && docker-compose pull && docker-compose build --no-cache && docker-compose up -d --force-recreate
echo "Containers are booting up!"
sleep 7
DB_ID=$(docker ps -aqf "name=trainingdb")

chmod +x ./check_docker_container.sh
chmod +x ./setup_db.sh

#check status of trainingdb container, and set up seed data if it is running
./check_docker_container.sh $DB_ID && echo "setting data" && ./setup_db.sh
