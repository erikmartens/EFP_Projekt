#!/bin/sh

docker-compose -p efp -f efp.yaml logs -f -t $@