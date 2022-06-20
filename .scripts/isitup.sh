#!/bin/bash
# debug
# set -x
# exit on first error
set -e

URL=${1?"URL Parameter Missing !"}

echo "Waiting for address $URL attempting every 3s"
until $(curl --silent --fail $URL >op); do
    echo '.'
    ((c++)) && ((c == 15)) && c=0 && break # don't run more than 15 times
    sleep 3
done
echo ' Success: Reached URL'