#!/bin/sh

# fail after an error occurs
set -e
set -o pipefail

cd ../frontend

# install all packages
elm-package install --yes

elm-make src/Main.elm --output efp-frontend.js

docker build -t efp-frontend .