# Eventur Dev Kit

Shared Docker-based development environment used by Eventur's PHP packages.

It provides a consistent PHP runtime, Composer environment, quality checks, test commands, coverage verification, and optional PostgreSQL, MySQL, and MongoDB services. Each package keeps its own configuration and delegates local development commands to the kit through `./bin/dev`.

The repository centralizes development mechanics only. Package architecture, production behavior, and integration guidance belong to the corresponding package or the main Eventur documentation.
