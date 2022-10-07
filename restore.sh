#!/bin/bash -x
docker-compose down
for dir in gitlab mattermost jenkins taiga sonarqube postgres
do
	rm /$dir/*
	rsync -avzh backup:/backup/$dir /$dir
done
psql -f /postgres/db.out postgres
docker-compose up -d
