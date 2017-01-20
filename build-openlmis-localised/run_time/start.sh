#!/usr/bin/env bash

#replace placeholders in properties files and ini file
#using the env vars provided with "docker run"
ruby /run_time/replace_configs.rb

#run migration
#/run_time/migration.sh

#start cubes
sh /app/cubes/bin/start.sh

#setenv.sh will make sure tomcat pickup the extra properties files
cp /run_time/setenv.sh /usr/local/tomcat/bin/setenv.sh

#start tomcat
catalina.sh run
