#!/usr/bin/env bash
docker run \
  -w /home/node \
  --mount type=bind,src=$(pwd)/src,dst=/home/node/ \
  $(docker build -q .) \
  "$@"
