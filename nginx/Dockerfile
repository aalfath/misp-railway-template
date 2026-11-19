# MISP web front end (nginx serving the static webroot and passing PHP to misp-core).
# Upstream image from MISP/misp-docker, pinned by version and digest.
# Bump the tag and digest together with core/Dockerfile, and add a CHANGELOG.md entry.
FROM ghcr.io/misp/misp-docker/misp-nginx:v2.5.52@sha256:e2e60001b72f908bd28043cdc1e2d2881675a61741ee1846dae137386989e2e1

USER root

# Railway changes to upstream's nginx template:
# - look up misp-core on every request through the private-network resolver
#   (nginx would otherwise keep the first IP, and break after misp-core redeploys);
# - answer /railway-health without MISP, for Railway's health check;
# - show a "starting" page instead of a bare 502 while misp-core runs its first setup.
# The grep checks make a version bump fail loudly if upstream changes these lines.
RUN set -e; f=/etc/nginx/templates/misp.conf.template; \
    grep -q '    fastcgi_pass ${FASTCGI_LISTEN};' "$f"; \
    sed -i 's#^        fastcgi_pass ${FASTCGI_LISTEN};#        fastcgi_pass $misp_core;#' "$f"; \
    sed -i 's#^    index index.php;#    index index.php;\n\n    include /etc/nginx/conf.d/railway/railway.conf;#' "$f"; \
    grep -q 'fastcgi_pass $misp_core;' "$f"; grep -q 'include /etc/nginx/conf.d/railway/railway.conf;' "$f"; \
    s=/etc/nginx/templates/status.conf.template; \
    grep -q 'fastcgi_pass ${FASTCGI_LISTEN_STATUS};' "$s"; \
    sed -i 's#fastcgi_pass ${FASTCGI_LISTEN_STATUS};#resolver ${NGINX_LOCAL_RESOLVERS} valid=10s;\n        set $misp_core_status "${FASTCGI_LISTEN_STATUS}";\n        fastcgi_pass $misp_core_status;#' "$s"; \
    grep -q 'fastcgi_pass $misp_core_status;' "$s"

COPY --chown=nginx:nginx railway.conf.template /etc/nginx/templates/railway/railway.conf.template
COPY --chown=nginx:nginx starting.html /usr/share/nginx/railway/starting.html
COPY --chmod=0755 00-railway.envsh /docker-entrypoint.d/00-railway.envsh

# Railway's private-network resolver comes from /etc/resolv.conf.
ENV NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1

USER nginx
EXPOSE 8080
