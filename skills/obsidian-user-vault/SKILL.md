---
name: obsidian-user-vault
description: "Portable Obsidian vault playbook for agents: resolve vault path, PARA layout, no-space filenames, createBy/updateBy frontmatter, and pre-write Obsidian Headless Sync (ob) health checks. Use when creating/editing/searching notes or managing official Obsidian Sync via headless CLI."
version: 2.0.0
author: Minnie (Wei) / TeemoKench fork
license: MIT
metadata:
  hermes:
    tags: [obsidian, vault, notes, para, user-custom, headless-sync, portable]
    related_skills:
      - obsidian-markdown
      - obsidian-bases
      - json-canvas
      - defuddle
      - minnie-wei-ops
      - session-purpose
      - github-cli-contrib
---

# Obsidian User Vault (portable)

Agent playbook for an Obsidian vault that uses **official Obsidian Sync**, often via **[Headless Sync](https://obsidian.md/help/sync/headless)** (`ob`).

**This skill is path-agnostic.** Do not hard-code another user's machine paths. Resolve configuration first (below), then operate with **absolute paths** in file tools.

## When to Use

- Find / read / create / edit / move notes in the user's vault
- Wikilinks, callouts, properties, embeds (load `obsidian-markdown`)
- `.base` / `.canvas` (load `obsidian-bases` / `json-canvas`)
- Clip web → note (`defuddle`)
- Headless Sync: install `ob`, login, continuous sync, stuck watcher recovery

Don't use for: pure chat with no vault I/O; unrelated agent config.

## Configuration resolution (do this first)

Resolve once per session; reuse the absolute `VAULT` path afterward.

### Priority order

1. **Skill-local config file** (best for shared skills + per-machine secrets/paths):  
   `references/local-config.md` next to this `SKILL.md`  
   → If missing, copy from `references/local-config.example.md` and fill in.
2. **Environment variables** (good for Hermes/Docker/CI):

| Variable | Purpose |
|----------|---------|
| `OBSIDIAN_VAULT_PATH` | Absolute path to vault root |
| `OBSIDIAN_OB_HOME` | `HOME` to use for `ob` so credentials land in the right place (never mix root vs user) |
| `OBSIDIAN_OB_PATH` | Directory containing `ob` binary (prepend to `PATH`) |
| `OBSIDIAN_SYNC_LOG` | continuous sync log file |
| `OBSIDIAN_SYNC_PID` | optional pid file path |
| `OBSIDIAN_AGENT_NAME` | default `createBy` / `updateBy` nickname |

3. **Discover with CLI** (official Sync users):

```bash
# Use the same HOME you use for ob login
export HOME="${OBSIDIAN_OB_HOME:-$HOME}"
ob sync-list-local
ob sync-status --path "<candidate>"
```

4. **Common fallbacks** (only if they exist and look like a vault — e.g. contain notes or `.obsidian`):  
   `~/Documents/Obsidian Vault`, `~/Obsidian`, `~/obsidian`, `$HERMES_HOME/obsidian`  
   Prefer asking the user over guessing when multiple candidates exist.

### Hard rules for agents

1. File tools often **do not expand** `$VAR` or `~`. Always pass a **resolved absolute path**.
2. Never invent a vault path from another person's blog/skill defaults.
3. After resolving, treat `VAULT` as the only root for note I/O this session.
4. Optional host notes: `references/local-config.md` (git-ignore on public forks if paths are private).

## Recommended vault layout (PARA-style)

Relative to `VAULT` (create only if the user wants this layout; do not mass-migrate without asking):

| Dir | Use |
|-----|-----|
| `0-Inbox/` | Captures / unclear |
| `1-Projects/` | Goal + end date |
| `2-Areas/` | Ongoing responsibility |
| `3-Resources/` | Reference, SOPs, LifeTips |
| `4-Archives/` | Done / inactive |
| `5-Daily/` | `YYYY-MM-DD.md` |
| `6-Templates/` | Templates |
| `Attachments/` | Images, PDFs |

### Placement defaults

1. No unsolicited whole-vault reorg.
2. New captures → `0-Inbox/` unless clearly an active project.
3. Prefer Project over Area when both fit.
4. Short life SOPs → `3-Resources/LifeTips/` (dashed names).
5. Unsure → Inbox + `[[wikilink]]`.

## Mandatory: no spaces in new paths

**New** file names, folder names, and path segments: **no space characters**. Separate with `-`.

| Bad | Good |
|-----|------|
| `My Note.md` | `My-Note.md` |
| `项目 计划.md` | `项目-计划.md` |

- Do **not** bulk-rename old spaced files unless the user asks.
- Daily notes: `5-Daily/YYYY-MM-DD.md` is fine.
- Wikilink targets for new notes must match dashed filenames.

## Mandatory: frontmatter `createBy` / `updateBy`

When an AI agent **creates or edits** a Markdown note, set YAML:

| Field | Meaning | When |
|-------|---------|------|
| `createBy` | Creator (agent nick or model) | On **create**; do not overwrite later |
| `updateBy` | Last AI editor | On **create** and **every AI edit** |

**Value priority:** `OBSIDIAN_AGENT_NAME` / local-config nick → stable agent nickname → model id → `nick/model`.

```yaml
---
title: Example-Note
createBy: MyAgent
updateBy: MyAgent
---
```

- Keep existing `createBy` on edit; refresh `updateBy` only.
- Skip on pure read/search.
- `.base` / `.canvas`: skip unless the format has an obvious property slot.

## Mandatory: check Headless Sync before writes

If this vault is synced with **`ob` continuous** (official Obsidian Sync headless), the watcher **can freeze**. Before **any** create/edit/move/delete under `VAULT`:

```bash
export HOME="${OBSIDIAN_OB_HOME:-$HOME}"
# ensure `ob` is on PATH (OBSIDIAN_OB_PATH or local-config)

pgrep -af 'ob sync.*continuous' || cat "${OBSIDIAN_SYNC_PID:-/tmp/obsidian-sync.pid}" 2>/dev/null
tail -40 "${OBSIDIAN_SYNC_LOG:-/tmp/obsidian-sync.log}"
ob sync-status --path "$VAULT"
```

| Signal | Means healthy enough to write |
|--------|-------------------------------|
| continuous process | `ob sync … --continuous` alive |
| log | Recent progress or `Fully synced`; not a hard error spin |
| `ob sync-status` | Config only — **not** sufficient alone |

**If unhealthy:** inspect log → stop wedged continuous `ob sync` carefully → restart continuous for `$VAULT` → re-check → then write. If still broken: tell the user; **default = do not write** unless they allow local-only edits.

**Read-only** search/read: check optional, not blocking.

Desktop Obsidian Sync and Headless on the **same** device/vault is unsupported by Obsidian — pick one live sync client per device.

Details: `references/headless-sync.md`.

## Companion skills

| Skill | Use |
|-------|-----|
| `obsidian-markdown` | OFM syntax |
| `obsidian-bases` | `.base` |
| `json-canvas` | `.canvas` |
| `defuddle` | URL → clean markdown |

Prefer **filesystem + `ob`**. This pack often **omits** `obsidian-cli`.

## Standard operations

1. Resolve `VAULT` (+ ob HOME/PATH/log) via config order above.
2. Search: `search_files` with path = absolute `VAULT`.
3. Read: `read_file` absolute path.
4. **Before write:** Headless Sync gate (if they use continuous `ob`).
5. Create: PARA folder → dashed name → `createBy`/`updateBy` → write.
6. Edit: patch/write + update `updateBy`.
7. Daily: `5-Daily/YYYY-MM-DD.md`.
8. Web clip: defuddle → Inbox/Project + source URL + dates + attribution fields.

## Headless Sync quick start (generic)

```bash
export HOME="${OBSIDIAN_OB_HOME:-$HOME}"
# install: npm i -g obsidian-headless   (or package manager of choice)
ob login
ob sync-list-remote
ob sync-setup --path "$VAULT" --vault "<RemoteVaultName-or-id>"
ob sync --path "$VAULT"                 # one-shot
ob sync --path "$VAULT" --continuous    # long-running watcher
```

Official docs: https://obsidian.md/help/sync/headless

## Done checklist

- [ ] `VAULT` resolved (local-config / env / discover) — absolute paths only in tools
- [ ] Pre-write Sync gate OK (if using continuous `ob`)
- [ ] Placement OK (PARA / user request)
- [ ] New paths: **no spaces**, use `-`
- [ ] AI create: `createBy` + `updateBy`; AI edit: keep `createBy`, refresh `updateBy`
- [ ] OFM via `obsidian-markdown` when needed
- [ ] No unsolicited vault-wide rename/restructure
- [ ] Reply with vault-relative short paths when possible

## Common pitfalls

1. Copying someone else's absolute paths from a blog or another install.
2. Passing `$OBSIDIAN_VAULT_PATH` into file tools without resolving.
3. Writing while continuous sync is wedged.
4. Trusting `ob sync-status` alone.
5. Logging into `ob` as **root** then running the agent as another user (split config dirs).
6. Spaced filenames on new notes.
7. Overwriting `createBy` on edit.
8. Running desktop Sync + headless continuous on the same device.

## Quick map

> Resolve `VAULT` → **sync gate before write** → PARA → **no spaces / `-`** → **createBy/updateBy** → OFM skills → `references/headless-sync.md` + `local-config.md`

## Support files

| File | Role |
|------|------|
| `references/local-config.example.md` | Template for any user |
| `references/local-config.md` | **This machine** filled values (create from example) |
| `references/headless-sync.md` | Portable `ob` / Sync ops + pre-write gate |
