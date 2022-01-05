#!/bin/bash

CONSUL_CONFIG=/config/config-cluster.hcl
MASTER_HOSTIP=10.1.0.10

for server in "10.1.0.10" "10.1.0.20" "10.1.0.30" "10.1.0.40" "10.1.0.50"
do
    echo === check if server/port is alive ===
    if nc -z $server 26379; then
        echo "${server} is alive"
    else
        echo "${server} is not alive"
        continue
    fi

    echo === check if master node is available ===
    # expect output from docker run command
    # Welcome to the Bitnami redis-sentinel container
    # Subscribe to project updates by watching https://github.com/bitnami/bitnami-docker-redis-sentinel
    # Submit issues and feature requests at https://github.com/bitnami/bitnami-docker-redis-sentinel/issues
    # 1) "10.1.0.20"
    # 2) "6379"
    master_hostip=`docker run -it docker.io/bitnami/redis-sentinel:5.0.4-debian-9-r39 sh -c "echo SENTINEL get-master-addr-by-name dc1 | redis-cli -h ${server} -p 26379" | head -n 6 | tail -n 1 | awk '{print $2}'`
    # remove carrage return
    master_hostip=`echo ${master_hostip} | tr -d '\r'`
    # remove double quotes
    master_hostip=`echo ${master_hostip} | tr -d '"'`
    if [ ! -z ${master_hostip} ]; then
        MASTER_HOSTIP=${master_hostip}
        break
    fi
done

echo MASTER_HOSTIP=${MASTER_HOSTIP}

OS="$(uname -s)"

docker rm -f `docker ps -qa`

case "${OS}" in
    Darwin*)    HOSTIP=`ipconfig getifaddr en0`;;
    *)          HOSTIP=`hostname --ip-address`;;
esac

case "${HOSTIP}" in
    ${MASTER_HOSTIP}*) HOSTIP=${HOSTIP} CONSUL_CONFIG=${CONSUL_CONFIG} REPLICATION=master MASTER_HOSTIP=${MASTER_HOSTIP} docker-compose up $@;;
    *)                 HOSTIP=${HOSTIP} CONSUL_CONFIG=${CONSUL_CONFIG} REPLICATION=slave MASTER_HOSTIP=${MASTER_HOSTIP} docker-compose up $@;;
esac
