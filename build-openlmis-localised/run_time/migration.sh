#!/usr/bin/env bash

echo "import data"
PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB < /run_time/dumpForTraining.sql && echo "Data import done"

echo "Change timestamp"
PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB < /run_time/changeTimeStamp.sql && echo "Timestamp change done"

echo "Run migrations"
/opt/flyway/flyway \
 -url=jdbc:postgresql://$POSTGRES_HOST:5432/open_lmis \
 -schemas=public,atomfeed \
 -user=$POSTGRES_USER \
 -password=$POSTGRES_PASSWORD \
 -table=schema_version \
 -placeholderReplacement=false \
 -locations=filesystem:/opt/flyway/sql/db \
 migrate

/opt/flyway/flyway \
 -url=jdbc:postgresql://$POSTGRES_HOST:5432/open_lmis \
 -schemas=public,atomfeed \
 -user=$POSTGRES_USER \
 -password=$POSTGRES_PASSWORD \
 -table=migration_schema_version \
 -placeholderReplacement=false \
 -baselineOnMigrate=true \
 -locations=filesystem:/opt/flyway/sql/migration \
 migrate

echo "Generate reports"
PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB < /run_time/generateReportViews.sql && echo "Report generation done, please open localhost:8080 in browser"