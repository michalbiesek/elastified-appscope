#!/bin/bash
source .env


VM_COUNT=`sysctl -n vm.max_map_count`

echo "Checking virtual memory settings"

if [ $VM_COUNT -lt $VM_EXPECTED_LIMIT ];then
    echo "Error with vm.max_map_count settings value $VM_COUNT it too low"
    echo "Please change the limit with: sudo sysctl -w vm.max_map_count=$VM_EXPECTED_LIMIT"
    exit 1
fi

echo "Start docker compose"
docker-compose --env-file .env up -d

echo "Copying the Cribl Configuration"
docker cp cribl/ cribl01:/opt/cribl/local/

echo "Waiting for the kibana to start"

counter=0
limit=10

until $(curl --output /dev/null --silent --head --fail http://localhost:$KIBANA_HOST_PORT); do
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
curl -X POST http://localhost:$KIBANA_HOST_PORT/api/saved_objects/_import?overwrite=true -H "kbn-xsrf: true" --form file=@$KIBANA_CFG_FILE

printf '\n'
echo "Demo is ready."
echo "To start scoping bash session run: docker-compose run appscope01"
echo "To start scoping individual commands run: docker-compose run appscope02 and use ldscope/scope"