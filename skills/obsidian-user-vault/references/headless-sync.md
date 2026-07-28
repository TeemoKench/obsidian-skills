# Obsidian Headless Sync — Hermes host

## Identity (critical)

| Who | HOME | config path |
|-----|------|-------------|
| Hermes agent | `/opt/data/home` | `/opt/data/home/.config/obsidian-headless/` |
| VS Code Attach Shell (default) | `/root` | `/root/.config/obsidian-headless/` |

Always for `ob`:

```bash
export HOME=/opt/data/home
export PATH="/opt/data/home/.npm-global/bin:/opt/data/bin:$PATH"
```

## Current vault binding

- Local: `/opt/data/obsidian`
- Remote name: **Claw**
- Vault id: `f73facb9e709a5a0970f4074ad5cff69`
- Host: `sync-39.obsidian.md` (Asia)
- Mode: bidirectional · conflict: merge
- Config sync: disabled (notes/attachments only)
- Account label seen by CLI: Tom_Kench

## Install CLI (no root /usr)

```bash
npm config set prefix /opt/data/home/.npm-global
npm install -g obsidian-headless
ln -sfn /opt/data/home/.npm-global/bin/ob /opt/data/bin/ob
ob --version
```

Docs: https://obsidian.md/help/sync/headless

## First-time setup

```bash
ob login
ob sync-list-remote
cd /opt/data/obsidian   # or --path
ob sync-setup --vault "Claw"   # or vault id
ob sync --path /opt/data/obsidian
```

## Root → hermes migration (after Attach Shell login)

```bash
# as root
mkdir -p /opt/data/home/.config
cp -a /root/.config/obsidian-headless /opt/data/home/.config/
chown -R 1000:1000 /opt/data/home/.config/obsidian-headless
chown -R 1000:1000 /opt/data/obsidian
su -s /bin/bash hermes -c '
  export HOME=/opt/data/home
  export PATH="/opt/data/home/.npm-global/bin:/opt/data/bin:$PATH"
  ob login
  ob sync-status --path /opt/data/obsidian
'
```

## Continuous sync

```bash
# Hermes: terminal(background=true) — do not use nohup in blocked shells
ob sync --path /opt/data/obsidian --continuous
```

- Log: `/opt/data/logs/obsidian-sync.log`
- Pid: `/opt/data/logs/obsidian-sync.pid`
- Watchdog script: `/opt/data/scripts/obsidian-sync-watchdog.sh` (cron every 5m, silent when healthy)
- Optional boot service draft: `/opt/data/scripts/s6-obsidian-sync/` (needs root install)

## Status interpretation

| Signal | Meaning |
|--------|---------|
| `ob login` prints email | token OK for this HOME |
| `ob sync-status` shows Vault/Location | local config linked |
| log `Fully synced` | last pass completed |
| `pgrep -af 'ob sync.*continuous'` | watcher alive |
| empty `.obsidian` except empty dir | config categories not synced (expected if disabled) |

## Pre-write gate (mandatory before vault mutations)

Continuous sync **can freeze**. Before create/edit/move/delete under `/opt/data/obsidian`:

```bash
export HOME=/opt/data/home
export PATH="/opt/data/home/.npm-global/bin:/opt/data/bin:$PATH"
pgrep -af 'ob sync.*continuous' || cat /opt/data/logs/obsidian-sync.pid 2>/dev/null
tail -40 /opt/data/logs/obsidian-sync.log
ob sync-status --path /opt/data/obsidian
```

**OK to write:** continuous process alive + log not stuck in a hard error loop.

**If dead/stuck:** inspect log → stop wedged continuous `ob sync` carefully → restart with Hermes `terminal(background=true)`:

```bash
ob sync --path /opt/data/obsidian --continuous
```

Re-check, then write. If still broken, tell Wei and **do not write** unless Wei explicitly allows local-only edits.

`ob sync-status` alone is **not** proof the watcher is healthy.

## LifeTips note placement

Short life SOPs/recipes → `3-Resources/LifeTips/<name-with-dashes>.md`
