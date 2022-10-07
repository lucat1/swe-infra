#!/bin/bash -x
docker-compose down
su postgres -c "cd /postgres; pg_dumpall > db.out"
for dir in gitlab mattermost jenkins taiga sonarqube postgres
do
	rsync -avzh /$dir backup:/backup/$dir
done
docker-compose up -d
rm /postgres/db.out
