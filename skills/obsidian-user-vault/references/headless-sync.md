# Obsidian Headless Sync (portable)

Official docs: https://obsidian.md/help/sync/headless

Optional companion for `obsidian-user-vault`. Use this doc when filling §4 Sync placeholders in `SKILL.md` during [`init_guide.md`](../init_guide.md) (check / repair commands).

Below, `$VAULT` is the absolute vault root from the skill; `$OB_HOME` is the HOME used for `ob` login (agent user, not root).
## Identity (critical)

`ob` stores login under **`$HOME/.config/obsidian-headless/`**.

| Pitfall | What goes wrong |
|---------|-----------------|
| Agent uses user A, you logged in as root | Token in `/root/...`, agent cannot see it |
| Two different `HOME` values | "Logged in" on one shell, logged out on another |

Always:

```bash
export HOME="$OB_HOME"          # e.g. from local-config OBSIDIAN_OB_HOME
export PATH="$OB_PATH:$PATH"    # directory containing `ob`
```

## Install CLI

```bash
# user-level npm prefix example (no root)
npm config set prefix "${OB_HOME}/.npm-global"
npm install -g obsidian-headless
export PATH="${OB_HOME}/.npm-global/bin:$PATH"
ob --version
```

Any install method is fine if `ob` is on `PATH` for the agent user.

## First-time setup

```bash
export HOME="$OB_HOME"
ob login
ob sync-list-remote
ob sync-setup --path "$VAULT" --vault "<RemoteName-or-id>"
ob sync --path "$VAULT"
```

## Continuous sync

```bash
# Long-running: prefer your agent's background process API
# Redirect stdout/stderr to OBSIDIAN_SYNC_LOG if you use a log file
ob sync --path "$VAULT" --continuous
```

Recommended extras (per host):

- Log file: `OBSIDIAN_SYNC_LOG`
- Pid file: `OBSIDIAN_SYNC_PID`
- Cron/systemd watchdog that restarts continuous if dead
- **Do not** run desktop Obsidian Sync on the same device while headless continuous is active

## Status interpretation

| Signal | Meaning |
|--------|---------|
| `ob login` shows account | token OK for this `HOME` |
| `ob sync-status --path "$VAULT"` | local folder linked (config only) |
| log contains `Fully synced` | last pass completed |
| `pgrep -af 'ob sync.*continuous'` | watcher process alive |

## Pre-write gate (mandatory before vault mutations)

Continuous sync **can freeze**. Before create/edit/move/delete under `$VAULT`:

```bash
export HOME="$OB_HOME"
export PATH="$OB_PATH:$PATH"
pgrep -af 'ob sync.*continuous' || cat "${OBSIDIAN_SYNC_PID}" 2>/dev/null
tail -40 "${OBSIDIAN_SYNC_LOG}"
ob sync-status --path "$VAULT"
```

**OK to write:** continuous process alive + log not stuck in a hard error loop.

**If dead/stuck:**

1. Read log tail  
2. Stop only the wedged continuous `ob sync`  
3. Restart continuous for `$VAULT`  
4. Re-check, then write  
5. If still broken → tell the user; default **do not write** unless they allow local-only edits  

`ob sync-status` alone is **not** proof the watcher is healthy.

## Migrating credentials between OS users

If you accidentally logged in as root (or another user), copy the config directory into the agent user's `OBSIDIAN_OB_HOME/.config/obsidian-headless/`, fix ownership, then `ob login` / `ob sync-status` as the agent user.

## Mapping into SKILL.md placeholders

When initializing `obsidian-user-vault`, map this host’s commands into:

| Placeholder | Typical source |
|-------------|----------------|
| `{{VAULT_ROOT}}` | `$VAULT` absolute path |
| `{{SYNC_CHECK_COMMANDS}}` | pre-write gate block above |
| `{{SYNC_HEALTH_CRITERIA}}` | continuous alive + log not in hard error loop |
| `{{SYNC_REPAIR_COMMANDS}}` | stop wedged continuous → restart → re-check |
| `{{SYNC_LIGHT_CHECK}}` | e.g. same session: only `pgrep` / is-active equivalent |

Do not hard-code another user’s paths into the shared template without init.