#!/bin/sh

# fail after an error occurs
set -e

cd reverse-proxy

sudo npm install -g elm

docker build -t efp-reverse-proxy .