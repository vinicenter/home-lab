#!/bin/bash

BASEDIR=$(dirname "$0")
cd $BASEDIR

./.env
docker compose up --force-recreate
