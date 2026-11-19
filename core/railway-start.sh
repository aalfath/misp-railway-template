#!/bin/bash
# Railway wrapper for misp-core: keep MISP's state on the service volume,
# then hand over to the upstream entrypoint (supervisord -> init -> php-fpm).
set -euo pipefail

DATA="${MISP_DATA_DIR:-/data}"
mkdir -p "$DATA/app/Config" "$DATA/app/files" "$DATA/gnupg"

# Config/core.php loads dirname(__DIR__)/Vendor/autoload.php, and PHP resolves
# __DIR__ through the symlink, so point $DATA/app/Vendor back at the image.
ln -sfn /var/www/MISP/app/Vendor "$DATA/app/Vendor"

link() {
    local src="$1" dst="$2"
    if [ -L "$src" ]; then
        return 0
    fi
    if [ -e "$src" ]; then
        rm -r "$src"
    fi
    ln -s "$dst" "$src"
}
link /var/www/MISP/app/Config "$DATA/app/Config"  # config.php (salt, settings), database.php, ...
link /var/www/MISP/app/files  "$DATA/app/files"   # attachments, galaxies, taxonomies, feeds ...
link /var/www/MISP/.gnupg     "$DATA/gnupg"       # instance GPG key

# supervisord's local control port (127.0.0.1 only) gets a fresh password on
# every start instead of upstream's fixed default; MISP is told the same value.
if [ -z "${SUPERVISOR_PASSWORD:-}" ]; then
    SUPERVISOR_PASSWORD="$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
    export SUPERVISOR_PASSWORD
fi

exec /entrypoint.sh "$@"
