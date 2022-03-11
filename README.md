# elastic-appscope

This demo presents observabiliy setup based on AppScope and Logstream.

## Contents
1. [Prerequisites](#prerequisites)
2. [Overview](#overview)
	* [Logstream configuration](#logstream-configuration)
3. [Building and Running](#building-and-running)
	* [Build Demo](#build-demo)
	* [Testing](#testing)
	* [Scoping the bash session](#scoping-the-bash-session)
	* [Scoping on demand](#scoping-on-demand)
	* [Clean up Demo](#clean-up-demo)
4. [Notes](#notes)
	* [Clean up the cribl data in ElasticSearch](#clean-up-the-cribl-data-in-elasticsearch)

## Prerequisites
For this demo environment, you will need Docker, `bash` and a `curl`.

Before run please ensure that Elasticsearch have proper virtual memory [settings](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/vm-max-map-count.html).

## Overview

This demo environment uses:

- [AppScope](https://appscope.dev/) to instrument application running in demo environment.
- [Logstream](https://cribl.io/logstream/) as a agent
- [ElasticSearch](https://www.elastic.co/elasticsearch/) to store data 
- [Kibana](https://www.elastic.co/products/kibana) to visualize metrics/events 

By default services will be available on following URL:

|Service|URL|
|-------|---|
|Kibana|[http://localhost:5601](http://localhost:5601)|
|ElasticSearch|[http://localhost:9200](http://localhost:9200)|
|LogStream|[http://localhost:9000](http://localhost:9000)|

If you need some custom values please modify `.env` file.

You

The diagram below depicts the demo cluster.
![Schema_overall](schema.png)


## Logstream configuration

The diagram below depicts the Logstream configuration
![Schema_logstream](logstream.png)


## Building and Running

The demo provides two interfaces:
- scoping the bash session `appscope01`
- scoping individual command `appscope02`

- running AppScope on host
To extend the functionality by using AppScope on host, please extend the ports settings in
`cribl01` configuration with following:

```
  cribl01:
    ...
    ports:
      - "${CRIBL_HOST_PORT:-9000}:9000"
      - 10070:10070
```

Set destination path to `tcp://127.0.0.1:10070` allows sending data to the observability setup.

## Build Demo

To build the demo, simply run `start.sh`:

```bash
./start.sh
```

## Testing

To confirm that everything works correctly:

```
docker ps
```

```
CONTAINER ID   IMAGE                                                  COMMAND                  CREATED         STATUS         PORTS                                                 NAMES
b7611e8bdfe9   docker.elastic.co/elasticsearch/elasticsearch:7.17.0   "/bin/tini -- /usr/l…"   4 seconds ago   Up 2 seconds   9200/tcp, 9300/tcp                                    es03
c8e5d96b909f   cribl/cribl:3.3.1                                      "/sbin/entrypoint.sh…"   4 seconds ago   Up 2 seconds   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp             cribl01
4a4da91d6562   docker.elastic.co/elasticsearch/elasticsearch:7.17.0   "/bin/tini -- /usr/l…"   4 seconds ago   Up 2 seconds   9200/tcp, 9300/tcp                                    es02
f171487fbf47   docker.elastic.co/kibana/kibana:7.17.0                 "/bin/tini -- /usr/l…"   4 seconds ago   Up 2 seconds   0.0.0.0:5601->5601/tcp, :::5601->5601/tcp             kib01
b5137275cb38   docker.elastic.co/elasticsearch/elasticsearch:7.17.0   "/bin/tini -- /usr/l…"   4 seconds ago   Up 2 seconds   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 9300/tcp   es01
```

## Scoping the bash session

Connect to the AppScope container and the scoping bash session will be captured:

```bash
docker-compose run appscope01
```

## Scoping on demand

Connect to the AppScope container and the scoping individual `command`:

```bash
docker-compose run appscope02
ldscope <command>
```

## Clean up Demo

To clean up the demo, simply run `stop.sh`:

```bash
./stop.sh
```

Elasticsearch by default store the data in `/elasticsearch/data` using `docker volume`, to clean it up:

```bash
docker volume prune
```
## Notes
## Clean up the cribl data

https://www.elastic.co/guide/en/kibana/current/console-kibana.html
https://www.elastic.co/guide/en/kibana/current/saved-objects-api-delete.html

Use query to clean up the current cribl data

```
DELETE cribl
```
