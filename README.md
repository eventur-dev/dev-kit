# Eventur Dev Kit

Docker-based development runtime shared by Eventur's independent PHP repositories. It gives every package the same PHP version, Composer behavior, quality commands, test commands, and optional database services.

Each package keeps the kit in `.dev-kit` and exposes it through its own `./bin/dev` wrapper. The package repository is mounted as the component workspace; commands therefore operate on that package, not on `dev-kit` itself.

## Runtime model

`./bin/dev` builds one PHP component container and starts only the database profiles enabled by the package. Local runs additionally mount the whole Eventur workspace and Composer's local package configuration, allowing one package to resolve current sibling working copies. CI uses the normal Composer configuration and does not depend on that workspace mount.

Defaults can be overridden in the package's ignored `.env`:

```dotenv
PHP_VERSION=8.5
DEVKIT_POSTGRES=1
DEVKIT_MYSQL=1
DEVKIT_MONGO=1
```

`DEVKIT_ALL_SERVICES=1` enables every database. MongoDB runs as a single-node replica set so integration tests exercise sessions, transactions, and commit outcomes instead of standalone-server behavior.

## Container lifecycle

| Command | Responsibility |
| --- | --- |
| `./bin/dev build` | Builds the package's PHP component image. |
| `./bin/dev up` | Starts the component and enabled services in the background. |
| `./bin/dev stop` | Stops containers without removing them. |
| `./bin/dev down` | Removes containers and networks while preserving named data volumes. |
| `./bin/dev clean` | Removes containers, networks, and database volumes. |
| `./bin/dev logs` | Follows Compose logs. |
| `./bin/dev bash` | Opens Bash in the running component container. |
| `./bin/dev exec <command>` | Runs an arbitrary command in the component container. |
| `./bin/dev config [--raw]` | Shows the interpolated or raw Compose configuration. |
| `./bin/dev ports` | Prints current host ports and local connection details for enabled databases. |
| `./bin/dev fix-perms` | Restores workspace ownership to the current host UID/GID. |

Commands that need the component call `up` automatically. `check` removes its containers when it finishes but preserves database volumes.

## Composer commands

```bash
./bin/dev composer-install
./bin/dev composer-update
./bin/dev composer-update eventur/envelope
./bin/dev composer-req vendor/package:^1.0
./bin/dev composer-autoload
./bin/dev composer-validate
```

Install, update, and require expose `COMPOSER_ROOT_VERSION=2.x-dev` by default so sibling packages can resolve the current Eventur development line. Arguments are forwarded to Composer; a selected update includes that package's dependencies.

## Tests

| Command | Responsibility |
| --- | --- |
| `test-unit` | Runs the `unit` suite, or skips cleanly when it does not exist. |
| `test-integration` | Runs the `integration` suite, or skips cleanly when it does not exist. |
| `test-all` | Runs every configured PHPUnit suite. |
| `test-group <group>` | Runs one PHPUnit group. |
| `test-single <filter>` | Runs tests selected by a PHPUnit filter. |
| `test-single-debug <filter>` | Runs a filter with Xdebug step debugging enabled. |
| `test-cover` | Produces an HTML coverage report in `coverage-report`. |
| `test-cover-strict` | Requires 100% class, method, and line coverage; skips only repositories without tests. |
| `test-notice-summary <suite>` | Runs a suite in debug mode and groups unique PHPUnit notices by test. |
| `phpunit-config-upgrade` | Applies PHPUnit's configuration migration. |

`test-single-debug` uses `PHP_IDE_CONFIG`; a package can override its server name in `.env` when the IDE path mapping differs.

## Static quality commands

```bash
./bin/dev cs-check
./bin/dev cs-fix
./bin/dev rector-check
./bin/dev rector-fix
./bin/dev phpstan
```

Check commands are read-only. Fix commands intentionally mutate the package and their diff must be reviewed.

The complete package gate is:

```bash
./bin/dev check
```

It runs strict Composer validation, coding-style verification, Rector drift detection, PHPStan, and strict coverage. Every stage runs even if an earlier stage fails, and the command exits non-zero with a complete failure summary.

## Database access

After `./bin/dev up`, use `./bin/dev ports` rather than assuming a host port. Compose publishes dynamic host ports so multiple package environments can coexist. Container-side test defaults are:

- MySQL: `mysql:3306`, database `mysql_db`, root password `root`;
- PostgreSQL: `postgres:5432`, database `postgres_db`, user/password `root`;
- MongoDB: `mongodb://mongo:27017/?replicaSet=rs0`.

Database data is disposable test data. `clean` removes it permanently.

## Using and updating the kit

Package `init.sh` scripts clone or update `eventur-dev/dev-kit` in `.dev-kit`; packages do not copy its command files into their own repositories. A dev-kit change can therefore affect every package after initialization and must be verified through the workspace automation tool.

```bash
./bin/dev help
../automation-tool/bin/eventur dev check
```

See the [development workflow](https://github.com/eventur-dev/eventur/blob/main/docs/development.md) and [`dev-tools-config`](https://github.com/eventur-dev/dev-tools-config) for the tool policies consumed by these commands.
