#init all containers, and get trainingdb container id
docker-compose down --volumes  && docker-compose pull && docker-compose up -d --force-recreate

APP_ID=$(docker ps -aqf "name=openlmis")
DB_ID=$(docker ps -aqf "name=trainingdb")

#copy dump and migrate script to db container

docker cp dumpForTraining.sql $DB_ID:/dumpForTraining.sql
docker cp migrate.sh $DB_ID:/migrate.sh

docker inspect --format="{{ .State.Running }}" $DB_ID

docker exec -it $DB_ID bash /migrate.sh