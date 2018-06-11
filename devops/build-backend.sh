#!/bin/sh

# fail after an error occurs
set -e

cd ../backend

docker build -t efp-backend .