#!/bin/bash

CONSUL_CONFIG=/config/config-cluster.hcl

OS="$(uname -s)"

docker rm -f `docker ps -qa`

case "${OS}" in
    Darwin*)    HOSTIP=`ipconfig getifaddr en0`;;
    *)          HOSTIP=`hostname --ip-address`;;
esac

case "${HOSTIP}" in
    10.1.0.10*) HOSTIP=${HOSTIP} CONSUL_CONFIG=${CONSUL_CONFIG} REPLICATION=master docker-compose up $@;;
    *)          HOSTIP=${HOSTIP} CONSUL_CONFIG=${CONSUL_CONFIG} REPLICATION=slave  docker-compose up $@;;
esac
