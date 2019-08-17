#!/bin/bash
docker rm -f apache_server
docker rm -f mysql_server

docker-compose up -d
docker logs -f $(docker ps -qf name=make_shorten) > access.log &

# docker exec -i mysql_server mysql -u some_user -p some_password some_database < init.sql
# docker exec -it $(docker ps -q) /bin/bash
