#!/bin/bash

echo "Start docker compose"
docker-compose up -d

echo "Copying the Cribl Configuration"
docker cp cribl/ cribl01:/opt/cribl/local/

echo "Waiting for the kibana to start"

counter=0
limit=10

until $(curl --output /dev/null --silent --head --fail http://localhost:5601); do
    if [ ${counter} -eq ${limit} ];then
      printf '\n'
      echo "Max attempts reached"
      exit 1
    fi

    printf '.'
    counter=$(($counter+1))
    sleep 5
done

printf '\n'
echo "Copying the kibana Configuration"
curl -X POST http://localhost:5601/api/saved_objects/_import?overwrite=true -H "kbn-xsrf: true" --form file=@elastic_cfg.ndjson

printf '\n'
echo "Demo is ready."
echo "To start scoping session run: docker-compose run appscope01"