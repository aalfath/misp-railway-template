# MISP core (PHP-FPM, background workers, first-run setup) for Railway.
# Upstream image from MISP/misp-docker, pinned by version and digest.
# Bump the tag and digest together with nginx/Dockerfile, and add a CHANGELOG.md entry.
FROM ghcr.io/misp/misp-docker/misp-core:v2.5.52@sha256:7a81a831c053ec477122ad5d57dc79c1f8212e939c6306f879a686bef7657b5e

# app/Config, app/files and .gnupg live on one Railway volume at /data and are
# symlinked into place by railway-start.sh. Upstream's permission fixes run
# `find`/`chown -R` on those paths, which don't follow a symlink by default, so
# make them follow it (-H). The grep checks make a version bump fail loudly if
# upstream changes these lines.
RUN set -e; \
    sed -i 's#find /var/www/MISP/app/#find -H /var/www/MISP/app/#g' /init_misp.sh; \
    sed -i 's#chown -R www-data:www-data \${GPG_DIR}#chown -R -H www-data:www-data ${GPG_DIR}#; s#find \${GPG_DIR}#find -H ${GPG_DIR}#g' /configure_misp.sh; \
    test "$(grep -c 'find -H /var/www/MISP/app/' /init_misp.sh)" -ge 7; \
    grep -q 'chown -R -H www-data:www-data ${GPG_DIR}' /configure_misp.sh; \
    test "$(grep -c 'find -H ${GPG_DIR}' /configure_misp.sh)" -eq 2

# Fewer background workers than upstream's default of 5 per queue, so the
# service fits a small Railway plan. Override any of them on the service.
# Credentials are never printed to the deploy logs.
ENV NUM_WORKERS_DEFAULT=2 \
    NUM_WORKERS_PRIO=2 \
    NUM_WORKERS_EMAIL=1 \
    NUM_WORKERS_CACHE=1 \
    NUM_WORKERS_UPDATE=1 \
    DISABLE_PRINTING_PLAINTEXT_CREDENTIALS=true \
    ENABLE_BACKGROUND_UPDATES=true \
    MISP_DATA_DIR=/data

COPY --chmod=0755 railway-start.sh /railway-start.sh

EXPOSE 9002
ENTRYPOINT ["/railway-start.sh"]
