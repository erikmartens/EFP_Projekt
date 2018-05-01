#!/bin/sh

# fail after an error occurs
set -e
set -o pipefail

cd ../backend

docker build -t efp-backend .