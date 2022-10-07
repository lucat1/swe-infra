#!/bin/bash -ex

for dir in gitlab mattermost jenkins taiga sonarqube
do
	rsync -avzh /$dir backup:/backup/$dir
done
