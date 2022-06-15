#!/bin/bash
source .env

KEY_CERT_DIR="/opt/"
PRIVATE_KEY_NAME="domain.key"
CERT_NAME="domain.crt"

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

echo "Copying public key(s) from host to docker container"
cp ~/.ssh/*pub images/

echo "Start docker compose"
docker-compose --env-file .env up -d --build

echo "Copying the Cribl Configuration"
docker cp cribl/ cribl01:/opt/cribl/local/

echo "Generate TLS keys"
openssl req -newkey rsa:2048 -nodes -keyout $PRIVATE_KEY_NAME -x509 -days 365 -out $CERT_NAME -subj "/C=PL/ST=Warsaw/L=GoatTown/O=Cribl/OU=Appscope/CN=cribl.io"

copy_key "cribl01"
copy_cert "cribl01"
copy_cert "appscope01_tls"

printf '\n'
echo "Demo is ready."
echo "To use TCP:"
echo "To start scoping bash session run: 'docker-compose run appscope01'"
echo "To start scoping individual commands run: 'docker exec -it appscope02 bash' and use ldscope/scope"
echo "To use TLS:"
echo "To start scoping individual commands run: 'docker exec -it appscope01_tls bash' and use ldscope/scope"
