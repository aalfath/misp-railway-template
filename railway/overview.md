# Deploy and Host MISP on Railway

MISP is an open-source threat intelligence platform for collecting, storing, correlating and sharing indicators of compromise, malware and incident data. Analysts record events and attributes, enrich them with modules, tag them with taxonomies and galaxies, and sync them with other MISP instances and feeds.

## About Hosting MISP

MISP needs several parts working together: a PHP-FPM application with background workers, a web server, a MariaDB database, Redis for sessions and job queues, and the misp-modules service for enrichment, import and export. This template deploys all of them as separate Railway services built from the official MISP Docker images, wired over Railway's private network. The first start creates the database schema, the admin account, a GPG key and downloads galaxies, taxonomies and warning lists, which takes a few minutes. Config, uploaded files and the GPG key live on a volume, and the database on its own volume, so they survive redeploys.

## Common Use Cases

* Run a private threat intelligence platform for a SOC or CERT team
* Share indicators with partner organisations and sync with other MISP instances
* Pull public OSINT feeds and enrich indicators with MISP modules

## Dependencies for MISP Hosting

* MariaDB 10.11 (database)
* Redis (sessions, background job queues, cache)

### Deployment Dependencies

* MISP core and web images: [MISP/misp-docker](https://github.com/MISP/misp-docker)
* MISP release notes: [MISP v2.5.52](https://github.com/MISP/MISP/releases/tag/v2.5.52)
* MISP modules: [MISP/misp-modules](https://github.com/MISP/misp-modules)
* Template source: [aalfath/misp-railway-template](https://github.com/aalfath/misp-railway-template)

### Implementation Details

Services in this template:

* **MISP**: nginx, the public web front end. Health check `/healthz`. Shows a "MISP is starting" page until misp-core is ready.
* **misp-core**: the MISP application (PHP-FPM), background workers and scheduler. Volume at `/data` for config, files and the GPG key.
* **misp-modules**: enrichment, import, export and action modules, reached by misp-core over the private network.
* **MariaDB**: the database, with its own volume.
* **Redis**: Railway's Redis, for sessions and job queues.

The only value you enter is `ADMIN_EMAIL`, the login of the first admin. The admin password, the database, Redis and GPG passwords, the encryption key and the salt are generated at deploy.

After deploy:

1. Wait for misp-core's first start to finish (about 3-5 minutes). Until then the public URL shows "MISP is starting".
2. Open the MISP service's public URL and sign in with `ADMIN_EMAIL` and the generated `ADMIN_PASSWORD` (misp-core service, Variables tab).
3. Under Administration, set your organisation name, then enable the feeds you want under Sync Actions, List Feeds.

Optional settings go on the misp-core service as variables, following the [misp-docker template.env](https://github.com/MISP/misp-docker/blob/master/template.env): `ADMIN_ORG` (organisation name), OIDC or LDAP login (`OIDC_ENABLE` and related variables), and outgoing mail (`SMTP_FQDN`, `SMTP_PORT`, pointing to your SMTP relay). This template has no mail relay, because one needs your own SMTP or SES credentials.

Updates: the template builds from the GitHub repo [aalfath/misp-railway-template](https://github.com/aalfath/misp-railway-template). When a new MISP version is pinned there, Railway shows an update notice in your project. Read the repo's CHANGELOG.md first. misp-core applies database updates on start.

## Why Deploy MISP on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying MISP on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
