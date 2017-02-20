#!/usr/bin/env bash

userexists=0

while [ "$userexists" != '1' ]
do
    userexists=$(psql $POSTGRES_DB -U postgres -tAc "SELECT '1' FROM pg_roles WHERE rolname='$POSTGRES_USER'")
    echo "waiting for DB to start"
    sleep 1
done

echo "import data"

[ -f ./dumpForTraining.sql ] && psql -U $POSTGRES_USER -d $POSTGRES_DB < dumpForTraining.sql && echo "Date import done"
psql -U $POSTGRES_USER -d $POSTGRES_DB < changeTimeStamp.sql && echo "Timestamp change done"
psql -U $POSTGRES_USER -d $POSTGRES_DB < generateReportViews.sql && echo "Report generation done, please open localhost:8080 in browser"