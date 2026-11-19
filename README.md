[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/misp?utm_medium=integration&utm_source=button&utm_campaign=misp)

# MISP on Railway

This repo packages [MISP](https://github.com/MISP/MISP) **v2.5.52**, the open-source threat intelligence sharing platform, as a Railway template. It runs the full stack from upstream's [misp-docker](https://github.com/MISP/misp-docker) as separate Railway services on the private network. Every service except Redis builds from a folder of this repo, whose `Dockerfile` pins the upstream image by version **and** digest.

## What it deploys

| Service | Source | Role | Storage |
| --- | --- | --- | --- |
| **MISP** (public) | `nginx/` (`misp-nginx:v2.5.52`) | Web front end, passes PHP to misp-core. Health check `/healthz` | none |
| **misp-core** | `core/` (`misp-core:v2.5.52`) | MISP app (PHP-FPM), background workers, scheduler, first-run setup and DB updates | Volume at `/data` (`app/Config`, `app/files`, GPG key) |
| **misp-modules** | `modules/` (`misp-modules:v3.1.5`) | Enrichment, import, export and action modules. Health check `/healthcheck` | none |
| **MariaDB** | `mariadb/` (`mariadb:10.11.19`) | Database | Volume at `/var/lib/mysql` |
| **Redis** | Railway's Redis | Sessions, job queues, cache | Railway volume |

Left out on purpose: upstream's mail relay (it needs your own SMTP or SES credentials; point `SMTP_FQDN`/`SMTP_PORT` on misp-core at your relay instead) and the optional `misp-guard` sync proxy.

## Variables

| Service | Variable | Value |
| --- | --- | --- |
| misp-core | `ADMIN_EMAIL` | **You enter it**: the login of the first admin |
| misp-core | `ADMIN_PASSWORD` | Generated (24 characters). Read it in the misp-core Variables tab |
| misp-core | `ENCRYPTION_KEY`, `SALT`, `GPG_PASSPHRASE` | Generated |
| misp-core | `BASE_URL` | `https://${{MISP.RAILWAY_PUBLIC_DOMAIN}}` |
| misp-core | `MYSQL_*`, `REDIS_*`, `MISP_MODULES_FQDN` | References to the MariaDB, Redis and misp-modules services |
| MISP | `PORT`, `FASTCGI_LISTEN`, `FASTCGI_LISTEN_STATUS` | `8080` and misp-core's private address |
| MariaDB | `MARIADB_USER`, `MARIADB_DATABASE`, `MARIADB_PASSWORD`, `MARIADB_ROOT_PASSWORD` | `misp`, `misp`, generated, generated |

Optional misp-core settings follow upstream's [template.env](https://github.com/MISP/misp-docker/blob/master/template.env): `ADMIN_ORG`, OIDC/LDAP login, `SMTP_FQDN`/`SMTP_PORT`, worker counts (`NUM_WORKERS_DEFAULT` and others; this template defaults to 1-2 per queue instead of upstream's 5).

## First start

misp-core's first start takes about 5-10 minutes: it loads the schema, creates the admin, generates a GPG key and imports galaxies, taxonomies and warning lists. Until it's done, the public URL shows a "MISP is starting" page. Then sign in with `ADMIN_EMAIL` and `ADMIN_PASSWORD`.

## What the wrapper changes

- **core**: keeps `app/Config`, `app/files` and `.gnupg` on the volume (symlinks), makes upstream's permission fixes follow those symlinks, gives supervisord's local control port a random password, hides credentials in the logs, and lowers the worker counts.
- **nginx**: listens on `PORT`, resolves misp-core through Railway's private DNS on each request (so a misp-core redeploy doesn't break it), answers `/healthz`, and shows a "starting" page instead of a 502 during first setup.
- **modules**: listens on IPv4 and IPv6 (Railway's private network is IPv6).
- **mariadb**: data directory in a subfolder of the volume, MISP's recommended InnoDB settings with a 512 MB buffer pool.

## Updates

Deployers get Railway's "update available" notice when `main` changes. Each version bump updates the pinned tag and digest in `core/`, `nginx/` and `modules/` together and adds a [CHANGELOG.md](CHANGELOG.md) entry, breaking changes first. misp-core runs MISP's database updates on start.

The overview shown on Railway's marketplace is [railway/overview.md](railway/overview.md).

## Licence

MISP is AGPL-3.0. This wrapper only adds Dockerfiles and small scripts around the official images.
