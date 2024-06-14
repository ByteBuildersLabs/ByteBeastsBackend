#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050"

export WORLD_ADDRESS="0x446f1f19ba951b59935df72974f8ba6060e5fbb411ca21d3e3e3812e3eb8df8"

echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS
echo "---------------------------------------------------------------------------"

# enable system -> models authorizations
sozo auth grant --world $WORLD_ADDRESS --wait writer \
  Position,dojo_starter::systems::actions::actions\
  Moves,dojo_starter::systems::actions::actions\
  >/dev/null

echo "Default authorizations have been successfully set."
