#!/usr/bin/env bash

#get container id
DB_ID=$(docker ps -aqf "name=trainingdb")

docker cp dumpForTraining.sql $DB_ID:/dumpForTraining.sql
docker exec -it $DB_ID psql -d open_lmis -U openlmis -a -f ./dumpForTraining.sql