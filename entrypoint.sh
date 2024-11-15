#!/bin/bash

touch config

check_staging_cmd=$(cat config.example  | grep -v '#CA=' | grep 'CA="https://acme-staging-v02.api.letsencrypt.org/directory"')
exit_code=$(echo $?)

if [[ ! -z "$STAGING_MODE" ]] ; then

    if [[ $exit_code != 0 ]]; then
        echo 'CA="https://acme-staging-v02.api.letsencrypt.org/directory"' >> config 
    fi

    echo "STAGING MODE ENABLED";
else
    if [[ $exit_code == 0 ]]; then
        grep -v 'CA="https://acme-staging-v02.api.letsencrypt.org/directory"' config.example > config
    fi
    
    echo "PRODUCTION MODE ENABLED";
fi

if [ ! -f domains.txt ]; then
    echo "/opt/app/domains.txt missing. File not found!"
    echo "Please mount domains.txt"
fi

# ./dehydrated --register --accept-terms
# ./dehydrated -c -f config