#!/bin/sh
# SPDX-FileCopyrightText: 2026 Conduction B.V.
# SPDX-License-Identifier: EUPL-1.2
#
# Installs Nextcloud and loads the Zuiddrecht demo, once, for the snapshot.
# Runs as root in a container of the image's `apps` stage that shares the
# network namespace of a postgres container, so the database is on localhost.
set -eu

cd /usr/src/nextcloud
occ() { setpriv --reuid=www-data --regid=www-data --init-groups php occ "$@"; }

occ maintenance:install -n \
    --database=pgsql --database-host=localhost --database-name=nextcloud \
    --database-user=nextcloud --database-pass=zuiddrecht \
    --admin-user=admin --admin-pass=admin \
    --data-dir=/usr/src/nextcloud/data

occ app:enable thematiq
occ app:enable launchpad
occ app:disable firstrunwizard
occ background:cron

occ config:system:set default_language --value=nl
occ config:system:set default_locale --value=nl_NL
occ config:system:set default_phone_region --value=NL
occ config:system:set defaultapp --value=launchpad

occ thematiq:theme:set zuiddrecht --sync-core

# Demo users, groups and the boards of identity.conduction.nl/screens.
occ launchpad:demo:load --retire-showcases --lang=nl

# Values encrypted with the instance secret would be unreadable once the
# container picks its own secret; the notifications app recreates these.
occ config:app:delete notifications webpush_vapid_pubkey
occ config:app:delete notifications webpush_vapid_privkey

occ maintenance:update:htaccess

# The running stack reaches the database by its service name.
occ config:system:set dbhost --value=db
