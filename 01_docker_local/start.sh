#!/bin/bash
set -x
set -e
setenforce 0

docker build -t flaskblog .
docker network create dev
#Creating database
docker run -d --name sql -v $(pwd)/bbdd:/docker-entrypoint-initdb.d/ -e MYSQL_ROOT_PASSWORD=pruebas --network dev percona:latest

#Running app container
docker run -d -p 80:5000 --network dev --name app flaskblog