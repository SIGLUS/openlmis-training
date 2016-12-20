#!/usr/bin/env bash

#init all containers, and get trainingdb container id
docker-compose up -d && echo "Containers are booting up!" && DB_CONTAINER_ID=$(docker ps -aqf "name=trainingdb")

#if [ "$DB_ID" ]; then
#    echo $DB_ID
#else
#    echo 'Data container has not been booted up'
#fi
chmod +x ./check_docker_container.sh
chmod +x ./setup_db.sh

./check_docker_container.sh $DB_CONTAINER_ID && echo "ready to set data!!!!!!!!!" && ./setup_db.sh

