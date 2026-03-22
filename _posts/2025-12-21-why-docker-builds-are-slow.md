---
layout: post
title: "Why Some Docker Builds Are Fast and Others Are Painfully Slow"
date: 2025-12-21 10:00:00 +0530
description: "Docker build optimization guide: layer caching, multi-stage builds, .dockerignore, and 7 Dockerfile anti-patterns that slow CI/CD pipelines by 70–90%. Fix them today."
excerpt: "Most people blame Docker when builds are slow. The real culprit is almost always the Dockerfile. Here's how Docker caching actually works, the seven patterns that kill performance, and the fixes that cut rebuild times by 70–90%."
tags: [Docker, DevOps, CI, Performance, Containers, BuildOptimization]
author: "Shantanu Sharma"
slug: "why-docker-builds-are-slow"
---

When people complain "Docker builds are slow," what they really mean is one thing:

> **They didn't design their Dockerfile properly.**

Most articles, blog posts, and AI chat responses try to "fix" slow builds by:

- disabling cache
- increasing CI timeouts
- using bigger runners
- blaming Docker itself

None of these actually fix the underlying issue.

Docker builds are predictable. Just look at the Dockerfile.
If your builds are slow or unpredictable, it's because of **how your Dockerfile is written**.

This article explains what's really going on, how Docker caching works in real life, and exactly what you must do to fix slow builds once and for all.

## Docker Builds Aren't Magic : They're Predictable

When you run:

```plaintext
docker build .
```

Docker does **three things**:

1. Uploads your build context to the daemon (or remote builder)
2. Walks through your Dockerfile, step by step
3. For each instruction, checks if it can reuse a cached result

This is not a compiler with AI. It's a **filesystem snapshot engine**.
Each instruction creates a **layer** — a snapshot of the filesystem at that point.

These layers are **immutable**. Once a layer is created, it never changes. When you build again, Docker doesn't "re-run" everything. Instead, it compares each instruction and its inputs with a previously built layer:

- If Docker can prove that **the instruction and its inputs didn't change**, it will reuse the layer from cache.
- If anything changed — even something irrelevant — the cache breaks and Docker re-runs that step and all subsequent ones.

That's the whole model.

---

## The Real Causes of Slow Docker Builds (and How to Fix Them)

Let's unpack the real reasons builds slow down and how you fix them.

## 1. Bad Layer Ordering Nukes Cache

If you copy everything before installing dependencies, you've guaranteed rebuilds on every change.

### Bad Pattern

```plaintext
FROM node:latest

WORKDIR /app

COPY . .

RUN npm install
RUN npm run build
CMD ["npm", "start"]
```

**What's wrong here?**

- `node:latest` is non-deterministic — you don't know what you're building tomorrow (if a new package is available tomorrow it will pull that, hence cache HIT got missed…rebuilds that again)
- `COPY . .` invalidates cache for *everything* whenever *any* file changes
- So every tiny source tweak reruns `npm install`

### Fix: Copy only what matters, in the order that matters

```plaintext
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:1.25-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
```

**Why this is better:**

- Pin a stable base (`node:20-alpine`) → reproducible builds
- Copy only dependency manifests before install → that layer stays cached as long as your dependencies don't change
- Copy app code later → changes here don't invalidate the dependency install

This simple reordering often cuts rebuild time by **70–90%**.

---

## 2. "Latest" Kills Reproducibility

If your base image changes under you, cache semantics become unreliable.

```plaintext
FROM node:latest
```

Today's build is not the same as tomorrow's build.

Use **versioned base images** instead:

```plaintext
FROM node:20-alpine
```

This fixes:

- reproducibility
- downstream debugging
- predictable cache

---

## 3. Every Line Creates a Layer

Dockerfiles are **immutable histories**.
Every `RUN`, `COPY`, `ADD` becomes a layer.

If you install something and then delete it in a later line, the data is still in earlier layers — and therefore your image is still big.

### Bad:

```plaintext
RUN apt-get update
RUN apt-get install -y build-essential
RUN rm -rf /var/lib/apt/lists/*
```

### Better:

```plaintext
RUN apt-get update && \
    apt-get install -y build-essential && \
    rm -rf /var/lib/apt/lists/*
```

Now the package lists don't survive in a separate layer.

---

## 4. Build Tools Don't Belong in Runtime Images

Build tools are only needed at build time. Shipping them to production is wasteful.

Use **multi-stage builds** intentionally:

```plaintext
FROM golang:1.22 as builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o app

FROM gcr.io/distroless/base-debian12
COPY --from=builder /app/app /app
CMD ["/app"]
```

Final image includes only:

- the binary
- runtime libs

No Go, no compilers, no shells, no build cache.

This:

- cuts image size
- reduces attack surface
- eliminates unnecessary rebuild work

---

## 5. Large Build Context = Slow Upload

Docker always uploads your build context to the builder.

If your context includes:

- node_modules
- .git
- logs
- tests, docs, temp files

Then every build has to send megabytes or more over the wire.

Fix this with a `.dockerignore`:

```plaintext
node_modules
.git
*.log
```

Smaller context = faster uploads = faster builds.

---

## 6. CI Isn't Lying: *It Exposes Bad Dockerfiles*

Locally, you might have warm cache.
CI runs on fresh machines.

That means:

- no existing cache
- slow cold builds
- every package download happens again

If your Dockerfile depends on warm local cache to be fast, you built it wrong.

In CI, you must explicitly:

- export/import cache
- use BuildKit with `--cache-from` / `--cache-to`
- or use dedicated layer caching

Otherwise your CI builds always recreate steps that could be cached.

---

## 7. Pin Dependencies, Don't Let Them Float

Floating dependencies (`latest`, `*`, unpinned versions) make builds unpredictable.

Lockfiles (`package-lock.json`, `go.sum`, `requirements.txt`) should only change when you change dependencies, not every code update.

This means:

- cache hits stay valid longer
- CI builds stable graphs
- debugging is possible

---

## A Simple Mental Model

Here's the core truth you should adopt now:

> **Docker builds are predictable. Your Dockerfile determines whether they're fast or slow.**

Treat Dockerfiles as:

- deterministic build graphs
- ordered instruction sequences
- cache design problems, not scripts

When you write a Dockerfile, ask:

- What changes frequently?
- What changes rarely?
- What steps can stay cached?

Design around **cache boundaries**, not commands.

## Checklist for Faster Docker Builds

Before shipping or committing a Dockerfile, ensure:

🟠 Base image is pinned  
🟠 Dependency install layer is early  
🟠 App code is copied after deps  
🟠 Build context is minimal  
🟠 Multi-stage builds separate build & runtime  
🟠 No unnecessary tools in final image  
🟠 Lockfiles are present  
🟠 CI cache is configured

If any of these are missing, your builds aren't engineered — they're accidental.
