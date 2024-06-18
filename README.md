# docker-mysql-replication-ssl

MySQL 8.0 master-slave replication with using Docker, with SSL encrypted connection.


## Run

To run this examples you will need to start containers with "docker-compose" 
and after starting setup replication. See commands inside ./build.sh. 

#### Create 2 MySQL containers with master-slave row-based replication 

```bash
./start.sh
```

#### Make changes to master

```bash
docker exec mysql_main sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'create table code(code int); insert into code values (100), (200)'"
```

#### Read changes from slave

```bash
docker exec mysql_replica sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'select * from code \G'"
```

## Troubleshooting

#### Check Logs

```bash
docker-compose logs
```

#### Start containers in "normal" mode

> Go through "build.sh" and run command step-by-step.

#### Check running containers

```bash
docker-compose ps
```

#### Clean data dir

```bash
docker volume rm mysql-main-data
docker volume rm mysql-replica-data
```

#### Run command inside "mysql_main"

```bash
docker exec mysql_main sh -c 'mysql -u root -p111 -e "SHOW MASTER STATUS \G"'
```

#### Run command inside "mysql_replica"

```bash
docker exec mysql_replica sh -c 'mysql -u root -p111 -e "SHOW SLAVE STATUS \G"'
```

#### Enter into "mysql_main"

```bash
docker exec -it mysql_main bash
```

#### Enter into "mysql_replica"

```bash
docker exec -it mysql_replica bash
```


# Thanks
[vbabak/docker-mysql-master-slave](https://github.com/vbabak/docker-mysql-master-slave)