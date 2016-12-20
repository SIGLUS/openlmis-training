#!/usr/bin/env bash

#get container id
DB_ID=$(docker ps -aqf "name=trainingdb")

echo $DB_ID
echo "copy dump to db"

# copy data to trainingdb container, and set data
docker cp dumpForTraining.sql $DB_ID:/dumpForTraining.sql

echo "dump has benn copied"

echo "========================="
echo $DB_ID
echo "========================="

docker exec -t $DB_ID [ -f ./dumpForTraining.sql ] && psql -d open_lmis -U openlmis -a -f ./dumpForTraining.sql