#!/usr/bin/env sh
source ./.env

command=$1
case $1 in
  start-dev) docker-compose up -d builder;;
  stop-dev) docker-compose down -v;;
  status) docker-compose ps;;
  list) docker-compose run --rm manager list;;
  push) docker-compose run --rm manager push;;
  checkout) docker-compose run --rm -e HOST_USER_ID=$(id -u $USER) manager checkout $2;;
  delete) docker-compose run --rm manager delete $2;;
  *)
    echo "Invalid command $1"
  ;;
esac
