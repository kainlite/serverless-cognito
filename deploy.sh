#!/bin/bash
set -u
source config.sh

cleanup() {
    echo 'Cleaning up'
    rm -f lambda.zip
}

create_zip() {
    echo 'Zipping lambda'
    cd src
    go get ./...
    go build ./...
    mv api.skynetng.pw main
    cd ..
    zip --junk-paths -r src/main.zip src/main
}

cleanup
create_zip
cd terraform
terraform apply -auto-approve \
    -var "region=us-east-1" \
    -var "profile_name=${profile_name}" \
    -var "domain_name=${domain_name}"
cd ..
