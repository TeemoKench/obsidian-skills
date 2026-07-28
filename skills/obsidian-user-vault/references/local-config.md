# local-config (this host — Wei / Hermes)

Filled values for the Hermes agent host. Other users: copy `local-config.example.md` → `local-config.md` and replace.

## Vault
- OBSIDIAN_VAULT_PATH: `/opt/data/obsidian`
- Remote Sync name: **Claw**
- Remote vault id: `f73facb9e709a5a0970f4074ad5cff69`
- Sync host: `sync-39.obsidian.md` (Asia)
- Mode: bidirectional · conflict: merge
- Config sync: disabled (notes/attachments only)
- Account label (CLI): Tom_Kench

## Headless CLI (`ob`)
- OBSIDIAN_OB_HOME: `/opt/data/home`
  - config: `/opt/data/home/.config/obsidian-headless/`
  - **Never** use root HOME for agent `ob` (Attach Shell as root → `/root/.config/obsidian-headless/` is the wrong tree)
- OBSIDIAN_OB_PATH: `/opt/data/home/.npm-global/bin` (also `/opt/data/bin/ob` symlink)
- OBSIDIAN_SYNC_LOG: `/opt/data/logs/obsidian-sync.log`
- OBSIDIAN_SYNC_PID: `/opt/data/logs/obsidian-sync.pid`
- Watchdog: cron every 5m · `/opt/data/scripts/obsidian-sync-watchdog.sh`
- Optional boot: `/opt/data/scripts/s6-obsidian-sync/` (root install)

### Shell prelude (this host)

```bash
export HOME=/opt/data/home
export PATH="/opt/data/home/.npm-global/bin:/opt/data/bin:$PATH"
export OBSIDIAN_VAULT_PATH=/opt/data/obsidian
export OBSIDIAN_OB_HOME=/opt/data/home
export OBSIDIAN_SYNC_LOG=/opt/data/logs/obsidian-sync.log
export OBSIDIAN_SYNC_PID=/opt/data/logs/obsidian-sync.pid
export OBSIDIAN_AGENT_NAME=Minnie
```

## Agent identity
- OBSIDIAN_AGENT_NAME: `Minnie` (optional `Minnie/<model>`)

## Deprecated paths (do not use)
- `/home/hermes/obsidian`

## PARA helper notes (this vault)
- Root explain note may exist as `PARA 系统说明.md` (legacy spaced name — do not bulk-rename)
- Placement cheatsheet may exist under `3-Resources/`

## Skill install notes (Hermes)
- Runtime authority for edits: `user-custom/obsidian-user-vault` (not only the fork tree copy)
- Fork mirror: `user-custom/obsidian-skills/skills/obsidian-user-vault/` → GitHub `TeemoKench/obsidian-skills`
