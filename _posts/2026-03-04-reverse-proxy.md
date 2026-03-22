---
layout: post
title: "Reverse Proxy in Backend Engineering"
date: 2026-03-04 03:48:38 +0530
description: "Learn how reverse proxies work in production backend systems — SSL termination, load balancing, routing, and caching. A practical guide for backend engineers using Nginx, Caddy, or custom Go proxies."
excerpt: "A reverse proxy sits between your clients and your backend services — handling SSL, routing, load balancing, caching, and more. Here's how it works and why every production system uses one."
tags: [Devops, Backend]
author: "Shantanu Sharma"
slug: "backendengineeringreverseproxy01"
---

Every production backend system has one thing between the internet and the application server: a reverse proxy. You deploy your FastAPI app on port 8000, your Go service on 8080, your Redis dashboard somewhere else — and none of them are directly exposed. A reverse proxy handles all incoming traffic and decides where it goes.

This article breaks down what a reverse proxy is, how it differs from a forward proxy, and the patterns you'll actually use in production.

---

## Forward Proxy vs Reverse Proxy

These two terms get mixed up constantly. The difference is about *who* it acts on behalf of.

**Forward proxy** — acts on behalf of the **client**. The client knows about the proxy; the server does not.

```
Client → Forward Proxy → Internet → Server
```

Use cases: corporate firewalls, anonymising clients, bypassing geo-restrictions.

**Reverse proxy** — acts on behalf of the **server**. The client knows nothing about the backend; it only talks to the proxy.

```
Client → Reverse Proxy → Server(s)
```

Use cases: hiding backend topology, SSL termination, load balancing, caching, rate limiting.

In backend engineering, when you say "proxy" you almost always mean the reverse kind.

---

## What a Reverse Proxy Actually Does

When a request hits your reverse proxy, it can:

1. **Terminate SSL** — decrypt the HTTPS request so your app only handles plain HTTP internally
2. **Route by path or host** — send `/api/*` to the API service, `/static/*` to a CDN or object store
3. **Load balance** — distribute requests across multiple instances of the same service
4. **Cache responses** — serve repeated requests without hitting the app at all
5. **Compress** — gzip/brotli responses before sending to the client
6. **Rate limit** — drop or queue traffic above a threshold
7. **Add/strip headers** — inject `X-Forwarded-For`, `X-Request-ID`, remove internal headers before responding

Each of these would require individual middleware in every service. A reverse proxy centralises them.

---

## Nginx: The Most Common Setup

Nginx is still the default choice for most teams. Here's a minimal but realistic config for a Python/Go backend:

```nginx
# /etc/nginx/sites-available/myapp

upstream api_backend {
    server 127.0.0.1:8000;  # FastAPI / Django
    server 127.0.0.1:8001;  # second instance
    keepalive 32;            # reuse connections
}

server {
    listen 80;
    server_name api.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate     /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;

    # Security headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;

    # Proxy to app
    location /api/ {
        proxy_pass         http://api_backend;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_read_timeout 30s;
    }

    # Serve static files directly — don't hit the app at all
    location /static/ {
        alias /var/www/myapp/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

Two things worth noting:

- `upstream` with multiple servers gives you round-robin load balancing with zero extra config
- `keepalive 32` reuses connections to the backend — critical for high-throughput services

---

## Path-Based Routing Across Multiple Services

Microservices need path-based (or host-based) routing. Nginx handles this cleanly:

```nginx
server {
    listen 443 ssl;
    server_name example.com;

    # Auth service (Go, port 9001)
    location /auth/ {
        proxy_pass http://127.0.0.1:9001/;
    }

    # ML inference service (Python, port 9002)
    location /predict/ {
        proxy_pass          http://127.0.0.1:9002/;
        proxy_read_timeout  120s;   # ML models can be slow
    }

    # Frontend (Node, port 3000)
    location / {
        proxy_pass http://127.0.0.1:3000;
    }
}
```

> Note the trailing slash on `proxy_pass` — `proxy_pass http://host:port/` strips the location prefix before forwarding. `proxy_pass http://host:port` keeps it. This is a silent gotcha that breaks routing in subtle ways.

---

## Traefik: Proxy-as-Config for Docker

If you work with Docker or Kubernetes, Traefik auto-discovers your services via labels without touching a config file.

```yaml
# docker-compose.yml

services:
  api:
    image: myapp:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.example.com`) && PathPrefix(`/api`)"
      - "traefik.http.routers.api.entrypoints=websecure"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"
      - "traefik.http.services.api.loadbalancer.server.port=8000"

  traefik:
    image: traefik:v3.0
    command:
      - "--providers.docker=true"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.email=you@example.com"
    ports:
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

Spin up a new service, add labels, and Traefik picks it up live — no reload. This is why it dominates Docker-based stacks.

---

## The `X-Forwarded-For` Problem

When your app sits behind a reverse proxy, `request.client.host` always returns the proxy's IP, not the real client IP. You need to read `X-Forwarded-For`.

In **FastAPI**:

```python
from fastapi import FastAPI, Request

app = FastAPI()

@app.get("/ip")
def get_ip(request: Request):
    # X-Forwarded-For can be a comma-separated chain of proxies
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for:
        client_ip = forwarded_for.split(",")[0].strip()
    else:
        client_ip = request.client.host
    return {"ip": client_ip}
```

In **Go** (using `net/http`):

```go
func realIP(r *http.Request) string {
    if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
        ips := strings.Split(xff, ",")
        return strings.TrimSpace(ips[0])
    }
    ip, _, _ := net.SplitHostPort(r.RemoteAddr)
    return ip
}
```

**Security note:** `X-Forwarded-For` is client-controlled. A client can spoof it. Only trust it when your proxy explicitly sets it and strips any client-supplied version. In Nginx, `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for` appends — use `$remote_addr` only if you want a clean replacement.

---

## Rate Limiting at the Proxy Level

Doing rate limiting in your application code is wasteful — the request already consumed CPU and connections before being rejected. Do it at the proxy.

**Nginx rate limiting:**

```nginx
# Define a zone: 10MB memory, keyed by IP, 10 req/sec limit
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

server {
    location /api/ {
        # Allow burst of 20 requests, then queue (no delay) up to rate
        limit_req zone=api_limit burst=20 nodelay;
        limit_req_status 429;

        proxy_pass http://api_backend;
    }
}
```

This handles the token bucket algorithm for you. 429 responses are returned before your app code even runs.

---

## WebSocket Proxying

WebSockets need special handling because they upgrade the HTTP connection and hold it open. The default proxy config drops them.

```nginx
location /ws/ {
    proxy_pass          http://127.0.0.1:8000;
    proxy_http_version  1.1;
    proxy_set_header    Upgrade    $http_upgrade;
    proxy_set_header    Connection "upgrade";
    proxy_set_header    Host       $host;
    proxy_read_timeout  3600s;   # hold open for an hour if needed
}
```

The `Upgrade` and `Connection` headers are required. Without `proxy_http_version 1.1`, Nginx defaults to HTTP/1.0 which doesn't support the upgrade mechanism.

---

## Health Checks and Passive Failure Detection

Nginx Plus has active health checks; in open-source Nginx you rely on passive detection — if a backend returns errors, it gets temporarily removed.

```nginx
upstream api_backend {
    server 127.0.0.1:8000 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8001 max_fails=3 fail_timeout=30s;
}
```

After 3 failures within 30 seconds, that server is marked down for 30 seconds. Combined with your application's own `/health` endpoint, this gives you automatic failover without an orchestrator.

---

## Quick Reference: Header Cheat Sheet

| Header | Set by | Purpose |
|---|---|---|
| `X-Forwarded-For` | Proxy | Real client IP chain |
| `X-Forwarded-Proto` | Proxy | Original scheme (http/https) |
| `X-Forwarded-Host` | Proxy | Original Host header |
| `X-Real-IP` | Proxy (Nginx) | Single real client IP |
| `X-Request-ID` | Proxy | Unique request ID for tracing |
| `Via` | Proxy (auto) | Proxy chain info |

---

## Wrapping Up

A reverse proxy is not an optional add-on — it's the front door of every serious backend. The logic it centralises (SSL, routing, rate limiting, compression, header injection) would otherwise be duplicated across every service you write.

For most setups:
- **Single server, single app** → Nginx is all you need
- **Docker Compose** → Traefik with labels is far less friction
- **Kubernetes** → Nginx Ingress Controller or Traefik Ingress
- **High-scale / service mesh** → Envoy or Caddy with plugins

The pattern is always the same: let the proxy handle the cross-cutting concerns, keep your application code focused on business logic.

---

*Found this useful? Connect on [LinkedIn](https://linkedin.com/in/mathoholic) or check out [RebuildHQ](https://rebuildhq.in).*