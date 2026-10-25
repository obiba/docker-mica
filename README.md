Docker Mica
===========

Docker image for [Mica](https://www.obiba.org/pages/products/mica/), the OBiBa web portal for
epidemiological studies and data catalogues. Images are published on Docker Hub as
[`obiba/mica`](https://hub.docker.com/r/obiba/mica). See also the
[Mica installation documentation](https://micadoc.obiba.org/en/latest/admin/installation.html#docker-image-installation).

Quick start
-----------

Use [docker compose](https://docs.docker.com/compose/) to launch Mica with everything it needs:
MongoDB, Elasticsearch, [Agate](https://github.com/obiba/docker-agate) (authentication),
[Opal](https://github.com/obiba/docker-opal) (data) and Rock (R server for Opal):

```
docker compose up
```

Then connect to:

* Mica: [http://localhost:8882](http://localhost:8882) (login `administrator` / `password`)
* Opal: [http://localhost:8880](http://localhost:8880)
* Agate: [http://localhost:8881](http://localhost:8881)

The `docker-compose.yml` is a development setup: the application homes are mounted from `/tmp/mica`,
`/tmp/opal` and `/tmp/agate`, Elasticsearch runs with security disabled and the MongoDB credentials
default to `obiba` / `password` (override with `MONGO_USER` and `MONGO_PASSWORD`).

Image layout
------------

| Path | Purpose |
|------|---------|
| `/usr/share/mica2` | Mica distribution (binaries, default configuration, bundled plugins) |
| `/opt/mica/bin` | Image start scripts (`start.sh`, `first_run.sh`, `set_elasticsearch.sh`) |
| `/srv` | `MICA_HOME`: configuration, plugins, data and logs. Declared as a volume. |

Ports:

| Port | Protocol |
|------|----------|
| 8082 | HTTP |
| 8445 | HTTPS |

Bundled plugins: `mica-search-es8` (Elasticsearch 8 search engine) and `mica-tables-spss`
(SPSS tables import). Their versions are set in the `Dockerfile`.

On first start, the entrypoint copies the default configuration and plugins into `MICA_HOME/conf` and
`MICA_HOME/plugins`, then applies the environment variables below. The first-run step is marked done
inside the image (by renaming `first_run.sh`), so it runs once per container, not once per volume:
re-creating the container against an existing volume re-applies the environment to the existing
`conf`. The `conf` and `plugins` folders themselves are only seeded when missing, so edits made in the
volume are kept.

Environment variables
---------------------

| Variable | Default | Description |
|----------|---------|-------------|
| `MICA_ADMINISTRATOR_PASSWORD` | | Password of the `administrator` user. |
| `MICA_ANONYMOUS_PASSWORD` | | Password of the `anonymous` user. |
| `MONGODB_URI` | | Full MongoDB URI (`host:port/db?options`). Takes precedence over the `MONGO_*` variables. |
| `MONGO_HOST` | | MongoDB host. |
| `MONGO_PORT` | `27017` | MongoDB port. |
| `MONGO_DB` | `mica` | MongoDB database name. |
| `MONGO_USER` | | MongoDB user, authenticated against the `admin` database. Requires `MONGO_PASSWORD`. |
| `MONGO_PASSWORD` | | MongoDB password. |
| `OPAL_URL` | | Opal server URL (e.g. `http://opal:8080`). Takes precedence over `OPAL_HOST`. |
| `OPAL_HOST` | | Opal host, used to build `http://OPAL_HOST:OPAL_PORT`. |
| `OPAL_PORT` | `8080` | Opal port, with `OPAL_HOST`. |
| `OPAL_USERNAME` | | Opal user Mica connects with. |
| `OPAL_PASSWORD` | | Opal password. |
| `AGATE_URL` | | Agate server URL (e.g. `http://agate:8081`). Takes precedence over `AGATE_HOST`. |
| `AGATE_HOST` | | Agate host, used to build `http://AGATE_HOST:AGATE_PORT`. |
| `AGATE_PORT` | `8081` | Agate port, with `AGATE_HOST`. |
| `ELASTICSEARCH_HOST` | | Elasticsearch host. Replaces `localhost` in the search plugin's `site.properties` once the plugin has been installed by Mica. |
| `JAVA_OPTS` | `-Xmx2G` | JVM options. Read at every start. |

Without `MONGODB_URI` or `MONGO_HOST`, Mica connects to `localhost:27017/mica`.

Running as a non-root user
--------------------------

The image starts as root by default: the entrypoint takes ownership of `MICA_HOME` for the `mica`
user (uid and gid 10041) and drops to it before starting Mica. Started as that user instead, with
`--user 10041:10041` or `runAsUser: 10041` on Kubernetes, the entrypoint skips both steps and
starts Mica directly, which is what a Pod Security `restricted` namespace (`runAsNonRoot`)
needs. The volume's ownership is then yours to arrange: give it to uid 10041, or set
`fsGroup: 10041` on the pod, or Mica will not be able to write its home.

```
docker run --user 10041:10041 -v mica-home:/srv -p 8882:8082 obiba/mica
```

Running arbitrary commands
--------------------------

Any command other than `app` is executed as is:

```
docker run --rm obiba/mica ls /usr/share/mica2/plugins
```

Building
--------

```
make build tag=7.0.0
make push tag=7.0.0
```

The Mica and plugin versions are set by `MICA_VERSION`, `ES8_PLUGIN_VERSION` and
`SPSS_PLUGIN_VERSION` in the `Dockerfile`.
