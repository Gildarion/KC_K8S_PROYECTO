#!/bin/bash
set -x
set -e
#Putting SELinux permissive mode  
setenforce 0

docker build -t flaskblog .
docker network create dev

#Reading database params
config=`cat blog/config.py | grep MYSQL`
password=`echo $config | grep MYSQL_DATABASE_PASSWORD | sed 's/MYSQL_DATABASE_PASSWORD = //g'`
user=`echo $config | grep MYSQL_DATABASE_USER | sed 's/MYSQL_DATABASE_USER = //g'`
host=`echo $config | grep MYSQL_DATABASE_HOST | sed 's/MYSQL_DATABASE_HOST = //g'`

#Creating database
docker run -d --name sql -v `pwd`/bbdd:/docker-entrypoint-initdb.d/ \ 
-e MYSQL_ROOT_PASSWORD=$password \
-e MYSQL_ROOT_USER=$user \
-e MYSQL_ROOT_HOST=$host \
--network dev percona:latest

#Running app container
docker run -d -p 80:5000 --network dev --name app flaskblog