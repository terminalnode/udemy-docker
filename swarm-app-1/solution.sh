#!/usr/bin/env sh
# Create the networks
docker network create -d overlay voting-frontend
docker network create -d overlay voting-backend

# Create the services
## Create the vote service
docker service create --detach --name vote \
  --network voting-frontend \
  -p 80:80 \
  --replicas 2 \
  dockersamples/examplevotingapp_vote:before

## Create the redis service
docker service create --detach --name redis \
  --network voting-frontend \
  --replicas 2 \
  redis:3.2

## Create the worker service
# One replica (default)
docker service create --detach --name worker \
  --network voting-frontend \
  --network voting-backend \
  bretfisher/examplevotingapp_worker:java

## Create the db service
# One replica (default)
docker service create --detach --name db \
  --network voting-backend \
  --mount type=volume,source=db-data,target=/var/lib/postgresql/data \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  postgres:9.4

## Create the result service
# One replica (default)
docker service create --detach --name result \
  --network voting-backend \
  -p 5001:80 \
  bretfisher/examplevotingapp_result
