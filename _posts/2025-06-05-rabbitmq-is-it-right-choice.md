---
layout: post
title: "Repeated RabbitMQ Incident That Lefts Thousands of Messages Unprocessed"
date: 2026-03-05 10:00:00 +0530
excerpt: "RabbitMQ consumers suddenly disconnected leaving queues with unacked messages and critical services like notifications and chat delivery stalled. This post walks through the debugging process, investigation steps, and the surprising root cause."
tags: [RabbitMQ, DevOps, IncidentManagement, SystemD, Infrastructure, Debugging, MessageQueue]
author: "Shantanu Sharma"
slug: "rabbitmq-is-it-right-choice"
---

Early one morning, an alert popped up on our monitoring system. (LoL emails!!)

```
⚠️ Executer Server, RabbitMQ connection closed:
Exception (320) Reason: "CONNECTION_FORCED - broker forced connection closure with reason 'shutdown'"
Reconnecting...
```

**Timestamp:** 06:28 AM

At first glance, this looked like a routine reconnect event. RabbitMQ clients sometimes reconnect automatically during transient network issues.

Team investigated on heartbeat mismatch as probable cause.
Added retry logic for reconnection attempts. This reduced the frequency of disconnects.

But something else was happening.

This issue was leaving our message consumers disconnected, and queues began accumulating unacknowledged messages.

That meant something serious.

Several critical services depended on this pipeline:

- **Notification delivery**
- **Chat message processing**
- **Background messaging workers**

If the consumers stayed disconnected, messages would stop flowing entirely.

So the investigation began.

---

## The Messaging Architecture

The system is built around a messaging pipeline where RabbitMQ acts as the broker between producers and worker services.

**Simplified flow:**

```
Producers → RabbitMQ → Consumers
```

**Consumers are responsible for:**

- Delivering notifications
- Processing chat messages
- Handling background messaging jobs

If RabbitMQ stops or consumers disconnect, the queues continue receiving messages but processing stops.

Which is exactly what we started seeing.

**Queues were filling up with unacknowledged messages.**

---

## First Hypotheses

Before diving into logs, I listed the most likely causes.

**Possible explanations included:**

1. RabbitMQ broker crash
2. EC2 instance reboot
3. Memory exhaustion
4. Disk exhaustion
5. Network failure
6. RabbitMQ service restart
7. Package upgrade triggering restart

The goal was simple: **eliminate possibilities one by one**.

---

## Checking the Server Health

The first step was to verify the machine itself.

### Uptime

```bash
uptime
```

**Result:**
```
199 days uptime
```

The instance had been running continuously for over six months.

**Conclusion:** ✅ The EC2 instance did not reboot.

### Disk Usage

```bash
df -h
```

**Result:**
```
48GB total
38GB free
```

**Conclusion:** ✅ Disk pressure was not the issue.

### Memory Usage

```bash
free -h
```

**Result:**
```
3.7GB RAM
2.4GB used
```

**Conclusion:** ✅ There was no memory exhaustion either.

The server itself was healthy.

That meant the issue likely originated from **RabbitMQ or the operating system**.

---

## Digging into RabbitMQ Logs

Next stop: the broker logs.

RabbitMQ stores its logs in:

```
/var/log/rabbitmq/
```

I inspected the historical logs using:

```bash
sudo zcat /var/log/rabbitmq/rabbitmq-server.log.2.gz
```

Inside the logs I found this sequence:

```
Stopping and halting node rabbit@waptoz-db
Gracefully halting Erlang VM
Starting broker...
```

This was interesting.

**RabbitMQ had not crashed.**

It had shut down **intentionally**.

That meant something external triggered the restart.

---

## Investigating Systemd

Since RabbitMQ runs as a systemd service, the next step was checking systemd logs.

**Command used:**

```bash
journalctl -u rabbitmq-server --since "06:20" --until "06:35"
```

The timeline revealed the following:

```
06:28:15 Stopping rabbitmq-server.service
06:28:24 Stopped rabbitmq-server.service
06:28:24 Starting rabbitmq-server.service
06:28:31 Started rabbitmq-server.service
```

RabbitMQ had been **stopped and restarted by systemd**.

But what triggered that restart?

---

## Looking Beyond RabbitMQ

To trace the trigger, I checked package manager logs.

**Relevant files included:**

```
/var/log/apt/history.log
/var/log/dpkg.log
```

I also checked unattended upgrade activity:

```bash
journalctl -u unattended-upgrades
```

Surprisingly, nothing obvious appeared.

However, systemd logs revealed something more interesting.

At the exact same time as the RabbitMQ restart:

```
Starting apt-daily-upgrade.service
systemd reexecuting
```

And immediately afterward, several services stopped:

```
Stopping rabbitmq-server.service
Stopping redis-server.service
Stopping postgresql
Stopping ssh
Stopping cron
Stopping mongod
```

Then they started again.

Now the picture was becoming clear.

---

## The Root Cause

The restart had been triggered by:

```
apt-daily-upgrade.service
```

This service executed a **systemd reexec**, which caused multiple services to restart.

**The failure chain looked like this:**

```
apt-daily-upgrade
     ↓
systemd reexec
     ↓
RabbitMQ stopped
     ↓
AMQP connections closed
     ↓
Consumers received CONNECTION_FORCED
     ↓
Consumers reconnected
```

**Total downtime:** approximately 9 seconds

---

## Why Consumers Saw CONNECTION_FORCED

RabbitMQ closes client connections during shutdown using the following error:

```
CONNECTION_FORCED
reason: shutdown
```

This is **expected behavior**.

**When the broker shuts down:**

- AMQP connections are terminated
- Consumers lose their channels
- Unacknowledged messages remain in the queue
- Consumers must reconnect

Fortunately, our consumers had automatic reconnection logic.

So the system recovered quickly once RabbitMQ restarted.

---

## Immediate Preventive Action

To avoid unexpected service restarts, I disabled automatic upgrade timers.

**Commands executed:**

```bash
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl stop apt-daily.timer
sudo systemctl stop apt-daily-upgrade.timer
```

**Verification:**

```bash
systemctl list-timers | grep apt
```

**Result:**
```
(no output)
```

✅ Automatic maintenance was now disabled.

---

## Operational Changes

From now on, system updates will be performed **manually during maintenance windows**.

**The update process:**

```bash
sudo apt update
sudo apt upgrade
sudo reboot
```

This prevents critical services from restarting during production hours.

---

## Infrastructure Observations

This incident also exposed a bigger architectural issue.

**The EC2 instance currently runs:**

- RabbitMQ
- Redis
- MongoDB
- PostgreSQL

When the OS performed maintenance, **all services restarted together**.

This creates a **single point of failure**.

---

## Recommended Improvements

Several improvements are planned.

### Add Swap Memory

**Current server configuration:**

Adding swap helps protect services during memory spikes.

**Example setup:**

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

**Persist configuration:**

```bash
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Separate Infrastructure

**Recommended architecture:**

```
RabbitMQ → messaging node
Database → separate instance
Redis → separate instance
```

This isolates failures and prevents maintenance tasks from affecting the entire system.

---

## Monitoring Worked as Expected

One positive takeaway from this incident was the monitoring pipeline.

**The system successfully:**

✅ Detected the RabbitMQ shutdown  
✅ Triggered consumer reconnection  
✅ Sent an alert immediately

**This confirmed that:**

- Reconnection logic works
- Monitoring is effective
- Message processing recovered automatically

---

## Final Takeaway

The root cause of the incident was **not a crash or resource failure**.

Instead, it was triggered by:

> **Ubuntu automatic maintenance (apt-daily-upgrade)** which executed a systemd reexec, restarting RabbitMQ and briefly disconnecting consumers.

**Impact:**

- ~9 seconds of consumer disconnection
- Queues temporarily paused
- No message loss

The system recovered automatically, but the investigation highlighted important infrastructure improvements to implement going forward.