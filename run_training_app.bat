
docker-compose down --volumes && docker-compose pull && docker-compose up -d --force-recreate

docker ps -aqf "name=trainingdb" > temp.txt
set /p DB_ID=<temp.txt

docker cp dumpForTraining.sql %DB_ID%:/dumpForTraining.sql
docker cp migrate.sh %DB_ID%:/migrate.sh

docker inspect --format="{{ .State.Running }}" %DB_ID%

docker exec -it %DB_ID% bash /migrate.sh