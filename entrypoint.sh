#!/usr/bin/env bash 
set -e

function main() {
    echo "RUNNING!!"
}


function get_keys() {

    which jq || (echo "Must have jq installed: sudo apt install -y jq" && false)
    mkdir -p __deploykeys
    for key in $(shell grep '@git+ssh' settings.ini | sed -n -e 's/^.*\(@git+ssh:\/\/\)//p') ; do \
        fname=__deploykeys/$$( basename $$key ).key && echo $$fname ; \
        aws secretsmanager get-secret-value --secret-id $$key | jq '.SecretString' | tr -d '"' | sed 's/\\n/\n/g' > $$fname && \
        chmod 600 $$fname ; \
    done
}

main
