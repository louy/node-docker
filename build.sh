#!/bin/bash

IMAGE_NAME="louy/node-docker"

# https://nodejs.org/dist/latest-v9.x/
# https://nodejs.org/dist/latest-v8.x/
NODE_VERSIONS=("9.2.0" "8.9.2") # first one is latest

set -e

for version in "${NODE_VERSIONS[@]}"; do
  echo "Building Node v"$version
  YARN_VERSION="1.3.2"
  mkdir -p images/$version

  DOCKER_FILE=$(cat ./Dockerfile-template)

  source="NODE_VERSION 0.0.0"
  replacement="NODE_VERSION "$version
  DOCKER_FILE="${DOCKER_FILE//$source/$replacement}"
  source="YARN_VERSION 0.0.0"
  replacement="YARN_VERSION "$YARN_VERSION
  DOCKER_FILE="${DOCKER_FILE//$source/$replacement}"

  echo "$DOCKER_FILE" > ./images/$version/Dockerfile

  MINOR=$(echo "$version" | sed -e 's/\.[0-9]\{1,\}$//')
  MAJOR=$(echo "$MINOR" | sed -e 's/\.[0-9]\{1,\}$//')
  docker build -t "$IMAGE_NAME:$version" images/$version/
  docker tag "$IMAGE_NAME:$version" "$IMAGE_NAME:$MINOR"
  docker tag "$IMAGE_NAME:$version" "$IMAGE_NAME:$MAJOR"
  if [ "$version" == "$NODE_VERSIONS[0]" ]; then
    docker tag "$IMAGE_NAME:$version" "$IMAGE_NAME:latest"
  fi
done
