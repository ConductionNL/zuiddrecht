#!/bin/sh
# SPDX-FileCopyrightText: 2026 Conduction B.V.
# SPDX-License-Identifier: EUPL-1.2
#
# Starts the pre-installed demo. On the first start of a container it gives the
# instance its own secret and applies the passwords and language from the
# environment. Then it runs cron and Apache.
set -eu

cd /usr/src/nextcloud
occ() { setpriv --reuid=www-data --regid=www-data --init-groups php occ "$@"; }

if [ ! -f config/secret.config.php ]; then
    php -r 'file_put_contents("config/secret.config.php", "<?php\n\$CONFIG = " . var_export([
        "secret" => base64_encode(random_bytes(48)),
        "passwordsalt" => base64_encode(random_bytes(30)),
    ], true) . ";\n");'
    chown www-data:www-data config/secret.config.php
    chmod 0640 config/secret.config.php
fi

if [ ! -f data/.first-start-done ]; then
    if [ -n "${ADMIN_PASSWORD:-}" ] && [ "$ADMIN_PASSWORD" != admin ]; then
        OC_PASS="$ADMIN_PASSWORD" occ user:resetpassword --password-from-env admin
    fi
    if [ -n "${DEMO_PASSWORD:-}" ]; then
        for user in $(occ user:list --output=json | php -r 'foreach (json_decode(stream_get_contents(STDIN), true) as $id => $name) { if ($id !== "admin") { echo $id, "\n"; } }'); do
            OC_PASS="$DEMO_PASSWORD" occ user:resetpassword --password-from-env "$user"
        done
    fi
    if [ "${DEMO_LANGUAGE:-nl}" != nl ]; then
        occ config:system:set default_language --value="$DEMO_LANGUAGE"
        occ launchpad:demo:load --lang="$DEMO_LANGUAGE"
    fi
    touch data/.first-start-done
fi

busybox crond -L /dev/stderr
exec "$@"
