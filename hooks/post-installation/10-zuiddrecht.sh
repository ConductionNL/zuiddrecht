#!/bin/sh
# SPDX-FileCopyrightText: 2026 Conduction B.V.
# SPDX-License-Identifier: EUPL-1.2
#
# Runs once, as www-data, right after Nextcloud installs itself on first start.
set -eu

occ() { php /var/www/html/occ "$@"; }

occ app:enable thematiq
occ app:enable launchpad
occ app:disable firstrunwizard

occ config:system:set default_language --value="${DEMO_LANGUAGE:-nl}"
occ config:system:set default_locale --value="${DEMO_LOCALE:-nl_NL}"
occ config:system:set default_phone_region --value=NL
occ config:system:set defaultapp --value=launchpad

occ thematiq:theme:set zuiddrecht --sync-core

# Demo users, groups and the boards of identity.conduction.nl/screens.
occ launchpad:demo:load --retire-showcases --lang="${DEMO_LANGUAGE:-nl}" \
    ${DEMO_PASSWORD:+--password="$DEMO_PASSWORD"}

echo "Zuiddrecht demo ready."
