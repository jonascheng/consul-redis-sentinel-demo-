## Overview

Deploy a Consul datacenter, and an sentinel-enabled redis service. These resources will be used to provide complete service mesh and redis high availability capabilities.

To prevent from confusing from redis cluster, avoid to use term - redis cluster.

## Prerequisites

- Vagrant
- VirtualBox
- Linux or OSX

## Deploy as standalone mode

All three nodes are independ, and all redis are master role.

1. Clone [consul-redis-sentinel-demo](https://github.com/jonascheng/consul-redis-sentinel-demo-.git) repository.
2. Navigate to this directory.
3. `vagrant up` to provision three servers, which are `server1` ~ `server5` respectively.
4. Execute the following commands in three servers

```console
$> vagrant ssh server1
vagrant@server1:~$ cd /vagrant
vagrant@server1:/vagrant$ ./docker-up-master.sh -d
```

## Deploy as cluster mode

All three nodes are joint cluster, and one of redis will play master role.
Any content was resident in the slave role will be overwritten by master one.

1. Execute the following commands in three servers

```console
$> vagrant ssh server1
vagrant@server1:~$ cd /vagrant
vagrant@server1:/vagrant$ ./docker-stop.sh
vagrant@server1:/vagrant$ ./docker-up-cluster.sh -d
```

## Remove one or two nodes from the cluster permanently

1. Stop the node you would like to remove permanently, let's say `server1`

```console
$> vagrant ssh server1
vagrant@server1:~$ cd /vagrant
vagrant@server1:/vagrant$ ./docker-stop.sh
```

2. Execute the following commands in one of alive nodes.

```console
$> vagrant ssh server2
vagrant@server2:/vagrant$ docker exec -it consul-server sh -c "consul force-leave -prune server1"
```

3. Accordingly, consul config should also be amended to reflect the new cluster setting.

```config-cluster.hcl
bootstrap_expect = 4
retry_join  = ["10.1.0.20", "10.1.0.30", "10.1.0.40", "10.1.0.50"]
retry_interval = "30s"
```

4. Pick one of the rest of nodes as redis master while starting redis and sentinel containers, amend `docker-up-cluster.sh` accordingly.

```docker-up-cluster.sh
MASTER_HOSTIP=10.1.0.30
```

## Common commands to verify consul and redis.

1. Lists the members of a Consul cluster and status.

```console
vagrant@server1:/vagrant$ docker exec -it consul-server sh -c "consul members"
```

2. Display the current Raft peer configuration includes leader and follower information.

```console
vagrant@server1:/vagrant$ docker exec -it consul-server sh -c "consul operator raft list-peers"
```

3. Redis replication status.

```console
# connect to slave node by replacing port 6379 with 6380
vagrant@server1:/vagrant$ docker exec -it redis sh -c "redis-cli -h redis-proxy -p 6379"
redis-proxy:6379> auth supersecret
redis-proxy:6379> info replication
```