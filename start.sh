#!/usr/bin/bash

docker-compose down -v
docker volume rm mysql-main-data
docker volume rm mysql-replica-data
docker-compose up -d

until docker exec mysql_main sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_main database connection..."
    sleep 4
done

priv_stmt='CREATE USER "mydb_replica_user"@"%" IDENTIFIED BY "mydb_replica_pwd"; GRANT REPLICATION SLAVE ON *.* TO "mydb_replica_user"@"%"; FLUSH PRIVILEGES;'
docker exec mysql_main sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt'"

until docker-compose exec mysql_replica sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_replica database connection..."
    sleep 4
done

MS_STATUS=`docker exec mysql_main sh -c 'export MYSQL_PWD=111; mysql -u root -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_replica_stmt="CHANGE REPLICATION SOURCE TO SOURCE_HOST ='mysql', SOURCE_USER ='mydb_replica_user', SOURCE_PASSWORD ='mydb_replica_pwd', SOURCE_SSL=1, SOURCE_SSL_CA = '/etc/mysql/ssl/ca-cert.pem', SOURCE_SSL_CERT = '/etc/mysql/ssl/server-cert.pem', SOURCE_SSL_KEY = '/etc/mysql/ssl/server-key.pem';"
start_replica_stmt+="START REPLICA UNTIL SOURCE_LOG_FILE='$CURRENT_LOG',SOURCE_LOG_POS=$CURRENT_POS;"
start_replica_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_replica_cmd+="$start_replica_stmt"
start_replica_cmd+='"'
docker exec mysql_replica sh -c "$start_replica_cmd"

docker exec mysql_replica sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
