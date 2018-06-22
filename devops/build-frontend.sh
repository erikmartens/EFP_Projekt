#!/bin/sh

# fail after an error occurs
set -e

cd ../frontend

# install all packages
elm-package install --yes

elm-make src/Main.elm --output efp-frontend.js --warn

docker build -t efp-frontend .