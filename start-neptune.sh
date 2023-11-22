sysctl -w net.ipv4.ip_forward=1

BASEDIR=$(dirname "$0")
cd $BASEDIR

./.env
docker compose --profile neptune up --force-recreate
