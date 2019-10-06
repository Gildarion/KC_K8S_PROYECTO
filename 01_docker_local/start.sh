#!/bin/bash
set -x
set -e
#Putting SELinux permissive mode  
setenforce 0

docker build -t flaskblog .
docker network create dev

#Reading database params
cat blog/config.py | grep MYSQL | sed "s/'//g" > db.txt
password=`grep MYSQL_DATABASE_PASSWORD < db.txt | \
 sed 's/MYSQL_DATABASE_PASSWORD = //g'`
user=`grep MYSQL_DATABASE_USER < db.txt | \
 sed 's/MYSQL_DATABASE_USER = //g'`
host=`grep MYSQL_DATABASE_HOST < db.txt | \
 sed 's/MYSQL_DATABASE_HOST = //g'`

#Creating database
docker run -d --name sql -v `pwd`/bbdd:/docker-entrypoint-initdb.d/ -e MYSQL_ROOT_PASSWORD=$password -e MYSQL_ROOT_USER=$user -e MYSQL_ROOT_HOST=$host --network dev percona:latest

#Running app container
docker run -d -p 80:5000 --network dev --name app flaskblog
