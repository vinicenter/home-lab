sleep 10

mount UUID=1ba3c27d-be0d-4b1e-a2ef-2a01850ba769 /media/Files

sleep 10

BASEDIR=$(dirname "$0")
cd $BASEDIR

./.env
docker compose --profile ceres up
