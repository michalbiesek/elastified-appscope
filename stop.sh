#!/bin/bash

echo "Stop docker compose"
docker-compose down
rm domain.crt 2> /dev/null
rm domain.key 2> /dev/null
