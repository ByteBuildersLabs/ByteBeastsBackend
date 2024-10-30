#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://0.0.0.0:5050";

export WORLD_ADDRESS=$(cat ./manifests/dev/deployment/manifest.json | jq -r '.world.address')

echo $WORLD_ADDRESS

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
sozo execute --world $WORLD_ADDRESS world_setup setWorld --wait
