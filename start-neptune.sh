BASEDIR=$(dirname "$0")
cd $BASEDIR

./.env
docker compose --profile neptune up
