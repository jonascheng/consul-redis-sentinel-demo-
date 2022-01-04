#!/bin/bash

CONSUL_CONFIG=/config/config-master.hcl

OS="$(uname -s)"

docker rm -f `docker ps -qa`

case "${OS}" in
    Darwin*)    HOSTIP=`ipconfig getifaddr en0`;;
    *)          HOSTIP=`hostname --ip-address`;;
esac

HOSTIP=${HOSTIP} CONSUL_CONFIG=${CONSUL_CONFIG} REPLICATION=master docker-compose up $@
