---
name: container-stacks
description: Write and maintain Dockerfiles/Containerfiles and compose stacks that work with both Docker and Podman — multi-stage builds, layer caching, debug vs staging stacks, secrets handling, and start/stop scripts. Use when creating or editing a Dockerfile, docker-compose file, or container start script, or when a container build or stack fails.
---

# Container images and stacks

## Engine-agnostic

Projects must run on Docker **and** Podman. Scripts pick the engine from an env var:

```bash
ENGINE="${CONTAINER_ENGINE:-podman}"   # or docker, per the repo's default
"$ENGINE" compose -f compose.yml up -d --build
```

- Don't use Docker-only features without a fallback (Docker Desktop host names like `host.docker.internal` — Podman uses `host.containers.internal`).
- Podman is rootless by default: ports < 1024 won't bind, and bind-mounted files may need `:Z` on SELinux hosts (Fedora).
- Use fully qualified image names (`docker.io/library/postgres:17`, `mcr.microsoft.com/dotnet/aspnet:10.0`) — Podman won't guess a registry.

## Dockerfile

- Multi-stage: `build` (SDK) → `publish` → `final` (runtime-only image). Final image runs as a non-root user.
- Copy dependency manifests (`*.csproj`, `package.json` + lockfile) and restore **before** copying the rest of the source, so restore is cached.
- Restore/publish the entry project, not the whole solution, so test projects aren't needed in the build context.
- A `BUILD_CONFIGURATION` build arg lets a `debug` target reuse the same build stage instead of a second Dockerfile.
- Keep `.dockerignore` in sync: exclude `bin/`, `obj/`, `.git/`, `node_modules/`, local secrets, test output.
- Pin base image tags to at least major.minor; no `latest`.

## Stacks

Keep separate, clearly named stacks rather than one file with many overrides:

| Stack | Purpose |
|---|---|
| `debug` | Debug build, debugger-attachable, real dependencies (DB, broker) in containers |
| `staging` | Release image, production-like env, TLS proxy in front, no debugger |

Each stack has `start.sh` / `stop.sh` and a README describing ports, URLs and how to reset data. Scripts are idempotent and `set -euo pipefail`.

## Secrets

- Never bake secrets into images or commit them in compose files. Use git-ignored `.env`/`secrets/` files or compose `secrets:`, and commit an `.example` with placeholders.
- Generate dev TLS certs and passwords in the start script if missing, rather than committing them.

## Health and ordering

- Give dependencies a `healthcheck` and use `depends_on: { db: { condition: service_healthy } }` instead of sleeps.
- Apps that migrate on startup need the DB healthy first.

## Debugging a failed stack

```bash
"$ENGINE" compose ps
"$ENGINE" compose logs --tail=200 <service>
"$ENGINE" compose config            # see the fully resolved file
"$ENGINE" compose down -v           # reset volumes (destroys data — confirm first)
```
