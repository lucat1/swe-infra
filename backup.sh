#!/bin/bash -x
su postgres -c "cd /postgres; pg_dumpall > db.out"
docker-compose down
for dir in gitlab mattermost jenkins taiga sonarqube postgres
do
	rsync -avzh /$dir backup:/backup/$dir
done
docker-compose up -d
rm /postgres/db.out
