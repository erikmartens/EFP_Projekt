#!/bin/sh

# fail after an error occurs
set -e
set -o pipefail

cd reverse-proxy

npm install -g elm

docker build -t efp-reverse-proxy .