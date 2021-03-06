#!/bin/bash
source .env

KEY_CERT_DIR="/opt/"
PRIVATE_KEY_NAME="domain.key"
CERT_NAME="domain.crt"
VM_COUNT=`sysctl -n vm.max_map_count`

#######################################
# Copy private key to specific docker container
# Arguments:
#   Name of the docker container
#######################################
copy_key () {
    local output_dir=$1:$KEY_CERT_DIR

    echo "Copying the TLS private key to $output_dir"
    docker cp $PRIVATE_KEY_NAME $output_dir$PRIVATE_KEY_NAME
}

#######################################
# Copy certificate to specific docker container
# Arguments:
#   Name of the docker container
#######################################
copy_cert () {
    local output_dir=$1:$KEY_CERT_DIR

    echo "Copying the TLS certificate to $output_dir"
    docker cp $CERT_NAME $output_dir$CERT_NAME
}

echo "Checking virtual memory settings"

if [ $VM_COUNT -lt $VM_EXPECTED_LIMIT ];then
    echo "Error with vm.max_map_count settings value $VM_COUNT it too low"
    echo "Please change the limit with: 'sudo sysctl -w vm.max_map_count=$VM_EXPECTED_LIMIT'"
    exit 1
fi

echo "Start docker compose"
docker-compose --env-file .env up -d --build

echo "Copying the Cribl Configuration"
docker cp cribl/ cribl01:/opt/cribl/local/

echo "Generate TLS keys"
openssl req -newkey rsa:2048 -nodes -keyout $PRIVATE_KEY_NAME -x509 -days 365 -out $CERT_NAME -subj "/C=PL/ST=Warsaw/L=GoatTown/O=Cribl/OU=Appscope/CN=cribl.io"

copy_key "cribl01"
copy_cert "cribl01"
copy_cert "appscope01_tls"

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
echo "To use TCP:"
echo "To start scoping bash session run: 'docker-compose run appscope01'"
echo "To start scoping individual commands run: 'docker exec -it appscope02 bash' and use ldscope/scope"
echo "To use TLS:"
echo "To start scoping individual commands run: 'docker exec -it appscope01_tls bash' and use ldscope/scope"
