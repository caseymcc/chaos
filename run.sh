#!/bin/bash

rebuild=false
stop=false
while getopts "rs" flag
do
    case "${flag}" in
        r) rebuild=true;;
        s) stop=true;;
    esac
done

TARGET_NAME="autogpt_llama_rocm"
DOCKERFILE="./"

DOCKER_NAME="${TARGET_NAME}"
CONTAINER_NAME="${TARGET_NAME}_container"

if [ "$rebuild" = true ] || [ "$stop" = true ]; then
  
  running=$(docker container inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)
  if [ "$running" == "true" ]; then
    echo "Stopping container"
    result=$(docker stop $CONTAINER_NAME)
  fi
  
  exists=$(docker ps -aq -f name=$CONTAINER_NAME)
  if [ "$exists" ]; then
    echo "Removing container"
    result=$(docker rm $CONTAINER_NAME)
  fi

  if [ "$rebuild" = true ]; then
    result=$(docker images -q $DOCKER_NAME )
    if [[ -n "$result" ]]; then
      "Deleting docker"
      result=$(docker rmi $DOCKER_NAME)
    fi
  fi

  if [ "$stop" = true ]; then
    exit 0
  fi
fi

result=$(docker images -q $DOCKER_NAME )
if [[ ! -n "$result" ]]; then
  echo "Building docker image"
  DOCKER_BUILDKIT=1 docker build \
    --build-arg USER_NAME=$(id -nu) --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    -t $DOCKER_NAME ${DOCKERFILE}
fi

exists=$(docker ps -aq -f name=$CONTAINER_NAME)
if [ ! "$exists" ]; then
  echo "Creating docker"

  docker create -it --name $CONTAINER_NAME \
    --net=host \
    --device=/dev/kfd \
    --device=/dev/dri \
    -v ${PWD}/Auto-GPT:/app \
    -v ${PWD}/:/projects \
    -v ${PWD}/llama.cpp/models:/models \
    $DOCKER_NAME
fi

running=$(docker container inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)
if [ "$running" != "true" ]; then
  echo "Starting docker"
  result=$(docker start $CONTAINER_NAME)
fi

echo "Attaching to docker"
docker exec -it $CONTAINER_NAME bash

