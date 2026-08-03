# Eventur Dev Kit

Docker-based development command runner shared by Eventur PHP repositories.

Each package stores the kit in `.dev-kit` and exposes it through its own `./bin/dev` wrapper. Commands run against that package mounted at `/workspace`.

## Common commands

```bash
./bin/dev composer-install
./bin/dev phpstan
./bin/dev test-unit
./bin/dev test-integration
./bin/dev test-cover-strict
./bin/dev check
```

`check` runs Composer validation, coding-style verification, Rector drift detection, PHPStan, and strict coverage. It reports every failed stage instead of stopping at the first one.

## Storage services

Enable only the service required by a package through its `.env`:

```dotenv
DEVKIT_POSTGRES=1
DEVKIT_MYSQL=1
DEVKIT_MONGO=1
```

Then use:

```bash
./bin/dev up
./bin/dev ports
./bin/dev down
```

MongoDB runs as a replica set so transaction tests exercise real session semantics. `./bin/dev clean` also removes volumes and therefore test-service data.

Run `./bin/dev help` for the complete command list. See the [workspace development workflow](https://github.com/eventur-dev/eventur/blob/main/docs/development.md) for cross-package checks.
