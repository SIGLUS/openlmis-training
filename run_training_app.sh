#!/usr/bin/env bash

#init all containers
docker-compose down --volumes && docker-compose pull && docker-compose up -d --force-recreate