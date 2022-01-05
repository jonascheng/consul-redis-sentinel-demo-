#!/bin/bash

CONSUL_CONFIG=/config/config-cluster.hcl
MASTER_HOSTIP=10.1.0.10

OS="$(uname -s)"

docker rm -f `docker ps -qa`

case "${OS}" in
    Darwin*)    HOSTIP=`ipconfig getifaddr en0`;;
    *)          HOSTIP=`hostname --ip-address`;;
esac

case "${HOSTIP}" in
    ${MASTER_HOSTIP}*) HOSTIP=${HOSTIP} CONSUL_CONFIG=${CONSUL_CONFIG} REPLICATION=master MASTER_HOSTIP=${MASTER_HOSTIP} docker-compose up $@;;
    *)          HOSTIP=${HOSTIP} CONSUL_CONFIG=${CONSUL_CONFIG} REPLICATION=slave  MASTER_HOSTIP=${MASTER_HOSTIP} docker-compose up $@;;
esac
