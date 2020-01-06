#!/usr/bin/env sh
source ./.env

command=$1
case $command in
  start-dev)
    if [[ ! -e './builder/src/node_modules' ]]; then
      docker-compose run --rm builder npm i --no-save
    fi

    docker-compose up builder
    ;;

  stop-dev)
    docker-compose down -v
    ;;

  status)
    docker-compose ps
    ;;

  list)
    docker-compose run --rm manager list
    ;;

  push)
    docker-compose run --rm manager push
    ;;

  checkout)
    remoteDirectoryName=$2

    docker-compose run --rm -e HOST_USER_ID=$(id -u $USER) manager checkout $remoteDirectoryName
    ;;

  delete)
    docker-compose run --rm manager delete $2
    ;;

  *)
    echo "Invalid command $command"
    ;;
esac
