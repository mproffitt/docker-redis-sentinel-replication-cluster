#!/bin/bash

echo "Starting the Redis Replication Cluster on Docker Swarm"
docker-compose --x-networking --x-network-driver overlay up -d
echo "Done"


