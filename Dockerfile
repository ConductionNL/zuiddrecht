# SPDX-FileCopyrightText: 2026 Conduction B.V.
# SPDX-License-Identifier: EUPL-1.2
#
# Nextcloud with thematiq and launchpad baked in, so a demo starts without
# downloading apps. The official image copies custom_apps from /usr/src/nextcloud
# into the volume on first start, and runs the post-installation hooks once.

ARG NEXTCLOUD_VERSION=34.0.6-apache
FROM nextcloud:${NEXTCLOUD_VERSION}

ARG THEMATIQ_VERSION=1.2.49-unstable.20261127105728
ARG LAUNCHPAD_VERSION=1.1.23-unstable.20261127110215

RUN set -eux; \
    cd /usr/src/nextcloud/custom_apps; \
    curl -fsSL "https://github.com/ConductionNL/thematiq/releases/download/v${THEMATIQ_VERSION}/thematiq-${THEMATIQ_VERSION}.tar.gz" | tar -xz; \
    curl -fsSL "https://github.com/ConductionNL/launchpad/releases/download/v${LAUNCHPAD_VERSION}/launchpad-${LAUNCHPAD_VERSION}.tar.gz" | tar -xz; \
    # The launchpad release package leaves out data/ (demo seed, showcases,
    # templates); take it from the source archive of the same tag.
    curl -fsSL "https://github.com/ConductionNL/launchpad/archive/refs/tags/v${LAUNCHPAD_VERSION}.tar.gz" \
        | tar -xz --strip-components=1 -C launchpad --wildcards '*/data/*'; \
    test -f launchpad/data/demo-seed/zuiddrecht-boards.json; \
    test -f thematiq/css/tokens/zuiddrecht.css; \
    chown -R www-data:www-data /usr/src/nextcloud/custom_apps

COPY --chmod=0755 hooks/ /docker-entrypoint-hooks.d/

LABEL org.opencontainers.image.source="https://github.com/ConductionNL/zuiddrecht" \
      org.opencontainers.image.description="Nextcloud demo environment of the fictitious municipality Zuiddrecht, with thematiq and launchpad" \
      org.opencontainers.image.licenses="EUPL-1.2"
