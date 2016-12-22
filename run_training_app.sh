#!/usr/bin/env bash

#init all containers, and get trainingdb container id
docker-compose down --volumes  && docker-compose pull && docker-compose up -d --force-recreate
echo "Containers are booting up, please wait a few seconds"
sleep 10
APP_ID=$(docker ps -aqf "name=openlmis")
DB_ID=$(docker ps -aqf "name=postgres")

chmod +x ./check_docker_container.sh

#copy dump and migrate script to db container
./check_docker_container.sh $DB_ID && echo "setting data" && docker cp dumpForTraining.sql $DB_ID:/dumpForTraining.sql
sleep 10
./check_docker_container.sh $DB_ID && docker cp migrate.sh $DB_ID:/migrate.sh

docker exec -it $DB_ID bash /migrate.sh