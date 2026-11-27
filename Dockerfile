# SPDX-FileCopyrightText: 2026 Conduction B.V.
# SPDX-License-Identifier: EUPL-1.2
#
# Nextcloud with thematiq and launchpad, installed and seeded at build time so
# a demo starts in seconds. Run snapshot/build.sh first: it installs the demo
# once from the `apps` stage and writes the result to snapshot/out.
#
#   docker build --target db -t ghcr.io/conductionnl/zuiddrecht-db .
#   docker build -t ghcr.io/conductionnl/zuiddrecht .

ARG NEXTCLOUD_VERSION=34.0.6-apache

FROM nextcloud:${NEXTCLOUD_VERSION} AS apps

ARG THEMATIQ_VERSION=1.2.49-unstable.20261127105728
ARG LAUNCHPAD_VERSION=1.1.25-unstable.20261127151102

RUN set -eux; \
    cd /usr/src/nextcloud/custom_apps; \
    curl -fsSL "https://github.com/ConductionNL/thematiq/releases/download/v${THEMATIQ_VERSION}/thematiq-${THEMATIQ_VERSION}.tar.gz" | tar -xz; \
    curl -fsSL "https://github.com/ConductionNL/launchpad/releases/download/v${LAUNCHPAD_VERSION}/launchpad-${LAUNCHPAD_VERSION}.tar.gz" | tar -xz; \
    test -f launchpad/data/demo-seed/zuiddrecht-boards.json; \
    test -f thematiq/css/tokens/zuiddrecht.css; \
    chown -R www-data:www-data /usr/src/nextcloud/custom_apps; \
    chown www-data:www-data /usr/src/nextcloud/config /usr/src/nextcloud/data /usr/src/nextcloud/.htaccess; \
    sed -i 's#/var/www/html#/usr/src/nextcloud#' \
        /etc/apache2/sites-available/000-default.conf /var/spool/cron/crontabs/www-data

COPY image/apache.conf /etc/apache2/conf-enabled/zuiddrecht.conf
COPY image/zuiddrecht.config.php /usr/src/nextcloud/config/
COPY --chmod=0755 image/entrypoint.sh /zuiddrecht-entrypoint.sh

WORKDIR /usr/src/nextcloud
ENTRYPOINT ["/zuiddrecht-entrypoint.sh"]
CMD ["apache2-foreground"]

LABEL org.opencontainers.image.source="https://github.com/ConductionNL/zuiddrecht" \
      org.opencontainers.image.licenses="EUPL-1.2"

# The database with the demo restored into a data directory outside the
# image's volume, so a new container starts on it at once. Restoring per
# architecture keeps the data directory native to each platform.
FROM postgres:16-alpine AS db

ENV PGDATA=/var/lib/postgresql/seed

COPY snapshot/out/db.sql /tmp/db.sql
RUN set -eux; \
    install -d -o postgres -g postgres -m 0700 "$PGDATA"; \
    su-exec postgres initdb --username=nextcloud --auth-local=trust --auth-host=scram-sha-256 >/dev/null; \
    echo 'host all all all scram-sha-256' >> "$PGDATA/pg_hba.conf"; \
    su-exec postgres pg_ctl -w -o "-c listen_addresses=''" start; \
    su-exec postgres psql -q -v ON_ERROR_STOP=1 -U nextcloud -d postgres -f /tmp/db.sql >/dev/null; \
    su-exec postgres pg_ctl -w -m fast stop; \
    rm /tmp/db.sql

LABEL org.opencontainers.image.source="https://github.com/ConductionNL/zuiddrecht" \
      org.opencontainers.image.description="Database of the Zuiddrecht demo environment, with the demo loaded" \
      org.opencontainers.image.licenses="EUPL-1.2"

FROM apps AS nextcloud

COPY --chown=www-data:www-data snapshot/out/config.php /usr/src/nextcloud/config/config.php
COPY --chown=www-data:www-data snapshot/out/data/ /usr/src/nextcloud/data/
COPY --chown=www-data:www-data snapshot/out/.htaccess /usr/src/nextcloud/.htaccess
RUN rm /usr/src/nextcloud/config/CAN_INSTALL

LABEL org.opencontainers.image.description="Nextcloud demo environment of the fictitious municipality Zuiddrecht, with thematiq and launchpad"
