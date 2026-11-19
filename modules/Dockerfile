# MISP modules (enrichment, import, export and action modules) for Railway.
# Upstream image from MISP/misp-docker, pinned by version and digest.
FROM ghcr.io/misp/misp-docker/misp-modules:v3.1.5@sha256:5d6f6b3ad878255c67d84ff1dc04de6acb1a2ace7868f4a552f995474a53b4a2

# Listen on all IPv4 and IPv6 addresses (an empty address makes Tornado bind
# both), so misp-core reaches it over Railway's private network. Port 6666 is
# the port MISP expects; GET /healthcheck answers without login.
EXPOSE 6666
ENTRYPOINT ["/usr/local/bin/misp-modules", "-l", "", "-p", "6666", "-c", "/custom/"]
