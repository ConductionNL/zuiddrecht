#!/bin/sh
# SPDX-FileCopyrightText: 2026 Conduction B.V.
# SPDX-License-Identifier: EUPL-1.2
#
# Installs the demo once and writes the result to snapshot/out: the database
# as SQL and the Nextcloud config, data directory and .htaccess. None of it
# depends on the CPU architecture, so one snapshot feeds amd64 and arm64.
set -eu

cd "$(dirname "$0")/.."
out=snapshot/out
pg=
nc=
cleanup() { docker rm -f $pg $nc >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker build --target apps -t zuiddrecht-apps .

pg=$(docker run -d -e POSTGRES_DB=nextcloud -e POSTGRES_USER=nextcloud \
    -e POSTGRES_PASSWORD=zuiddrecht postgres:16-alpine)
until docker exec "$pg" pg_isready -q -h localhost -U nextcloud -d nextcloud; do sleep 1; done

nc=$(docker create --network "container:$pg" --entrypoint /seed.sh zuiddrecht-apps)
docker cp snapshot/seed.sh "$nc":/seed.sh
docker start -a "$nc"

rm -rf "$out"
mkdir -p "$out"
docker cp "$nc":/usr/src/nextcloud/config/config.php "$out/config.php"
docker cp "$nc":/usr/src/nextcloud/data "$out/data"
rm -f "$out/data/nextcloud.log"
docker cp "$nc":/usr/src/nextcloud/.htaccess "$out/.htaccess"
{
    docker exec "$pg" pg_dumpall -U nextcloud --roles-only | grep -vx 'CREATE ROLE nextcloud;'
    docker exec "$pg" pg_dump -U nextcloud --create nextcloud
} > "$out/db.sql"

if grep -q 'Encryption\$' "$out/db.sql"; then
    echo "The snapshot holds values encrypted with the instance secret." >&2
    exit 1
fi
echo "Snapshot written to $out."
