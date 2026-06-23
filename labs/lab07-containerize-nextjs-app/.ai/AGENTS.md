# Next.js + Docker Best Practices Guide

This document outlines best practices for running **Next.js** in Docker: standalone mode, static export, and development. It applies to this project's Dockerfiles and Compose setup.

## Table of Contents

1. [Next.js Deployment Modes](#nextjs-deployment-modes)
2. [Image Version Pinning](#image-version-pinning)
3. [Base Image Selection](#base-image-selection)
4. [Multi-Stage Builds for Next.js](#multi-stage-builds-for-nextjs)
5. [Non-Root User](#non-root-user)
6. [Layer Caching Optimization](#layer-caching-optimization)
7. [Security Best Practices](#security-best-practices)
8. [Docker Compose Best Practices](#docker-compose-best-practices)
9. [.dockerignore for Next.js](#dockerignore-for-nextjs)
10. [Project Dockerfiles Reference](#project-dockerfiles-reference)
11. [Common Mistakes to Avoid](#common-mistakes-to-avoid)

---

## Next.js Deployment Modes

### Standalone (Node server)

- **Config:** `next.config.ts`: `output: "standalone"`
- **Build output:** `.next/standalone/` (minimal Node server + traced files), `.next/static/`, `public/`
- **Run:** `node server.js` (from standalone directory)
- **Use when:** You need SSR, API routes, middleware, or dynamic features.
- **Project file:** `Dockerfile` (port 3000)

```dockerfile
# Copy standalone server and static assets
COPY --from=builder --chown=node:node /app/public ./public
COPY --from=builder --chown=node:node /app/.next/standalone ./
COPY --from=builder --chown=node:node /app/.next/static ./.next/static
USER node
CMD ["node", "server.js"]
```

### Static Export

- **Config:** `next.config.ts`: `output: "export"` (for that build)
- **Build output:** `out/` (static HTML/CSS/JS)
- **Serve with:** Nginx (`Dockerfile.nginx`) or `serve` (`Dockerfile.serve`) on port 8080
- **Use when:** App is fully static (no SSR, no API routes, no middleware that needs a server).
- **Project files:** `Dockerfile.nginx`, `Dockerfile.serve`

```dockerfile
# After build stage that produces out/
COPY --from=builder /app/out /usr/share/nginx/html
# or
COPY --from=build --chown=node:node /app/out /app/static
CMD ["npx", "serve", "-s", "static", "-l", "8080"]
```

### Development

- **Run:** `next dev` (with optional `WATCHPACK_POLLING=true` in Docker)
- **Project file:** `Dockerfile.dev`; Compose uses `watch` for sync/rebuild.

---

## Image Version Pinning

### ✅ DO: Pin Exact Versions

Pin base image tags for reproducible builds.

```dockerfile
# ✅ GOOD
ARG NODE_VERSION=24.14.0-alpine
ARG NGINXINC_IMAGE_TAG=alpine3.22
FROM node:${NODE_VERSION} AS builder
FROM nginxinc/nginx-unprivileged:${NGINXINC_IMAGE_TAG} AS runner

# ❌ BAD
FROM node:latest
FROM node:24-alpine
FROM nginx:alpine
```

- Prevents breaking changes and keeps builds consistent.
- This project uses `24.14.0-alpine` (serve/nginx) and `24.14.0-slim` (standalone/dev) by default.

---

## Base Image Selection

### ✅ DO: Use Alpine or Slim

- **Alpine:** Smallest; use for static export (serve/nginx) and most Next.js builds.
- **Slim:** Debian-based; use when you need glibc or better compatibility (e.g. Next.js standalone with native deps).

```dockerfile
# ✅ GOOD
FROM node:24.14.0-alpine
FROM node:24.14.0-slim

# ❌ BAD
FROM node:24.11.1
```

This project uses Alpine for `Dockerfile.serve` and `Dockerfile.nginx`, Slim for `Dockerfile` and `Dockerfile.dev`.

---

## Multi-Stage Builds for Next.js

### Standalone

- **Stages:** dependencies → builder (copy node_modules + source, `next build`) → runner
- **Copy to runner:** `public/`, `.next/standalone/`, `.next/static/`; optional `.next/cache/` for fetch cache.
- Use BuildKit cache mount for `.next/cache` in builder to speed up rebuilds:  
  `RUN --mount=type=cache,target=/app/.next/cache npm run build`

### Static Export

- **Stages:** dependencies → builder (produces `out/`) → runner (nginx or node + serve).
- **Copy to runner:** only `out/` (and `nginx.conf` for nginx).
- No Node runtime in final image when using Nginx.

### ✅ DO

- Copy dependency manifests before source; use `npm ci` (or equivalent) with cache mounts.
- Copy only the artifacts needed for the chosen mode (standalone vs `out/`).

### ❌ DON'T

- Single-stage with full `COPY . .` then `npm install` and `npm run build` for production.
- Copy `.next/` entirely into a standalone runner; use only `.next/standalone` and `.next/static`.

---

## Non-Root User

### ✅ DO: Run as Non-Root

- Use built-in `node` or `nginx` when possible.
- Set ownership when copying: `COPY --chown=node:node` or `--chown=nginx:nginx`.
- Set `USER node` / `USER nginx` before `CMD`/`ENTRYPOINT`.

```dockerfile
# ✅ GOOD
COPY --from=builder --chown=node:node /app/.next/standalone ./
USER node
CMD ["node", "server.js"]

# ✅ GOOD (Nginx)
FROM nginxinc/nginx-unprivileged:${NGINXINC_IMAGE_TAG}
COPY --from=builder /app/out /usr/share/nginx/html
USER nginx
```

---

## Layer Caching Optimization

### ✅ DO

1. Copy `package.json` and lockfiles first.
2. Install dependencies (with cache mount), then copy source.
3. Run `next build` last in the build stage.
4. Use `npm ci` (or yarn/pnpm equivalent) for reproducible installs.
5. For Next.js builder, use:  
   `RUN --mount=type=cache,target=/app/.next/cache npm run build`  
   so `.next/cache` is reused across builds.

```dockerfile
# ✅ GOOD
COPY package.json package-lock.json* ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
RUN --mount=type=cache,target=/app/.next/cache npm run build
```

---

## Security Best Practices

- Do **not** hardcode secrets in Dockerfiles; use env vars or Docker secrets.
- Set `ENV NODE_ENV=production` in production stages.
- Set `ENV NEXT_TELEMETRY_DISABLED=1` if you want to disable Next.js telemetry.
- Use specific `COPY` (e.g. `package.json` + lockfiles) instead of broad wildcards.
- Prefer `nginxinc/nginx-unprivileged` over default `nginx` when using Nginx.
- Scan images (e.g. `docker scout`, `trivy`) and keep base images updated.

---

## Docker Compose Best Practices

- Use unique `container_name`s per service.
- Pin image tags in production; avoid `latest`.
- Add healthchecks for app and proxy services where appropriate.
- Use named networks and sensible restart policies (`unless-stopped` for long-running services).
- For dev, use Compose Watch to sync source and rebuild when `package.json` changes.

This project's `compose.yaml` defines:

- **nextjs-prod-standalone** — `Dockerfile`, port 3000
- **nextjs-prod-static-nginx** — `Dockerfile.nginx`, port 8080
- **nextjs-prod-static-serve** — `Dockerfile.serve`, port 8080
- **nextjs-dev** — `Dockerfile.dev`, port 3000, watch
- **nextjs-test** / **nextjs-lint** — tools profile

---

## .dockerignore for Next.js

Exclude at least:

- `node_modules/`, `.next/`, `out/`, `dist/`, `build/`, `.vercel/`
- `.env*`, `*.log`, `.git/`, `.vscode/`, `.idea/`, `.cursor/`
- `Dockerfile*`, `compose*.yaml`, `.dockerignore`
- `*.md`, `docs/`, `.github/`
- Test and cache dirs: `coverage/`, `.turbo/`, `.vitest/`, etc.

This keeps the build context small and avoids copying secrets or dev-only files.

---

## Project Dockerfiles Reference

| File               | Mode        | Port | Notes                                      |
|--------------------|------------|------|--------------------------------------------|
| `Dockerfile`       | Standalone | 3000 | `output: "standalone"`, `node server.js`   |
| `Dockerfile.serve` | Static     | 8080 | `out/` + `serve`                           |
| `Dockerfile.nginx` | Static     | 8080 | `out/` + nginx                             |
| `Dockerfile.dev`   | Development| 3000 | `next dev`, optional watch                 |

- **Node:** Default `NODE_VERSION=24.14.0-alpine` or `24.14.0-slim` depending on Dockerfile.
- **Nginx:** `nginxinc/nginx-unprivileged` with tag from `NGINXINC_IMAGE_TAG`.
- **Serve:** Pinned (e.g. `serve@14.2.6`) in `Dockerfile.serve`.
- **Working directory:** `/app`.

---

## Common Mistakes to Avoid

- ❌ Using `latest` or floating tags for base images.
- ❌ Running as root; always set `USER` and use `--chown` where needed.
- ❌ Copying full `.next/` into runner; for standalone use only `.next/standalone` and `.next/static`.
- ❌ Using `npm install` in production; use `npm ci` and lockfiles.
- ❌ Copying source before dependency install; copy package files first for cache.
- ❌ Hardcoding secrets in Dockerfiles.
- ❌ Forgetting `NODE_ENV=production` in production stages.
- ❌ Omitting `.dockerignore` or including `.env*` and `node_modules` in context.

---

## Checklist for Next.js Dockerfiles

- [ ] Base image version pinned (no `latest`)
- [ ] Alpine or Slim variant chosen appropriately
- [ ] Multi-stage build: dependencies → build → runtime
- [ ] Non-root user and correct `--chown`
- [ ] Dependency manifests copied before source; `npm ci` (or equivalent)
- [ ] BuildKit cache for npm and optionally `.next/cache`
- [ ] Correct artifacts copied: standalone (standalone + static + public) or static (`out/`)
- [ ] `.dockerignore` includes `.next/`, `out/`, `node_modules`, `.env*`
- [ ] No secrets in Dockerfile; `NODE_ENV=production` set
- [ ] Healthcheck considered for production services

---

## References

- [Next.js with Docker (official)](https://github.com/vercel/next.js/tree/canary/examples/with-docker)
- [Next.js Output File Tracing](https://nextjs.org/docs/advanced-features/output-file-tracing)
- [Dockerfile Best Practices (Docker)](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [OWASP Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

---

**Last Updated:** 2025  
**Project:** docker-nextjs-sample  
**Maintained by:** Kristiyan Velkov
