#!/bin/bash

set -e
if [ -d "target" ]; then
    rm -rf "target"
fi

if [ -d "manifests" ]; then
    rm -rf "manifests"
fi

echo "sozo build && sozo migrate apply"
sozo build && sozo migrate apply

echo -e "\n✅ Setup finish!"

export world_address=$(cat ./manifests/dev/deployment/manifest.json | jq -r '.world.address')

echo -e "\n✅ Init Torii!"
torii --world $world_address --allowed-origins "*"
