# Obsidian Skills (TeemoKench fork)

Fork of [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) with customizations:
- **`obsidian-cli` removed** (not used here)
- kepano four kept: markdown / bases / json-canvas / defuddle
- may include **`obsidian-user-vault`** (local vault playbook)


Agent Skills for use with Obsidian.

Fork of [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) with customizations:
- **`obsidian-cli` removed** (not used here, required Obsidian desktop GUI, can't run without GUI)
- kepano four kept: markdown / bases / json-canvas / defuddle
- added **`obsidian-user-vault`** (portable vault playbook + headless Sync; per-host `local-config.md`)

These skills follow the [Agent Skills specification](https://agentskills.io/specification) so they can be used by any skills-compatible agent, including Claude Code, Codex, Open Code, and Hermes.

## Who this is for

- **Linux / no-GUI / pure CLI users** — Aimed at headless servers, VPS, containers, and other environments **without a desktop Obsidian app**. Agents work on the vault as files on disk and (optionally) drive sync from the terminal. Desktop-only tooling such as `obsidian-cli` is **not** included in this fork.
- **Official [Obsidian Sync](https://obsidian.md/sync) users** — If your vault already lives on Obsidian Sync, you can use this pack **directly**: point the agent at your local vault folder, and for Linux/CLI hosts use [Headless Sync](https://obsidian.md/help/sync/headless) (`ob`) so the same Sync account stays up to date. See `obsidian-user-vault` (`references/local-config.example.md` + `references/headless-sync.md`) for path setup and a pre-write sync health check.

You do **not** need the Obsidian desktop GUI on the machine where the agent runs. A phone/desktop app elsewhere can still open the same Sync vault.

## Installation

Install skills into **`~/.agents/skills`** (Agent Skills layout). Each skill is a folder with a `SKILL.md`.

### Recommended: clone this repo, then link skills

```sh
# 1) clone (pick any path you like)
git clone https://github.com/TeemoKench/obsidian-skills.git ~/src/obsidian-skills

# 2) ensure target dir exists
mkdir -p ~/.agents/skills

# 3) link each skill into ~/.agents/skills
for d in ~/src/obsidian-skills/skills/*/; do
  name="$(basename "$d")"
  ln -sfn "$d" "$HOME/.agents/skills/$name"
done

# 4) check
ls -la ~/.agents/skills
```

After linking you should see folders such as:

`~/.agents/skills/obsidian-markdown/SKILL.md`  
`~/.agents/skills/obsidian-user-vault/SKILL.md`  
…and the other skills in this repo.

Restart or reload your agent so it re-scans skills.

### Alternative: copy (no git updates)

```sh
mkdir -p ~/.agents/skills
cp -a ~/src/obsidian-skills/skills/. ~/.agents/skills/
```

Copying is simple but **won’t** pick up upstream/fork updates until you copy again. Prefer the **clone + symlink** method above, then `git -C ~/src/obsidian-skills pull` when this repo updates.

### Optional: SSH clone

```sh
git clone git@github.com:TeemoKench/obsidian-skills.git ~/src/obsidian-skills
# then the same mkdir + ln -sfn loop as above
```

### Per-host vault config

For `obsidian-user-vault`, copy and edit local config once:

```sh
cp ~/.agents/skills/obsidian-user-vault/references/local-config.example.md \
   ~/.agents/skills/obsidian-user-vault/references/local-config.md
# edit local-config.md — set OBSIDIAN_VAULT_PATH, ob HOME, agent name, etc.
```

### Notes

- Target path is always **`~/.agents/skills/<skill-name>/SKILL.md`**.
- Do **not** only copy the repo root without the inner `skills/*` folders.
- If your agent uses a different skills root, point it at `~/.agents/skills` or symlink that directory accordingly.

## Skills

| Skill | Description |
|-------|-------------|
| [obsidian-markdown](skills/obsidian-markdown) | Create and edit [Obsidian Flavored Markdown](https://help.obsidian.md/obsidian-flavored-markdown) (`.md`) with wikilinks, embeds, callouts, properties, and other Obsidian-specific syntax |
| [obsidian-bases](skills/obsidian-bases) | Create and edit [Obsidian Bases](https://help.obsidian.md/bases/syntax) (`.base`) with views, filters, formulas, and summaries |
| [json-canvas](skills/json-canvas) | Create and edit [JSON Canvas](https://jsoncanvas.org/) files (`.canvas`) with nodes, edges, groups, and connections |
| [defuddle](skills/defuddle) | Extract clean markdown from web pages using [Defuddle](https://github.com/kepano/defuddle), removing clutter to save tokens |
| [obsidian-user-vault](skills/obsidian-user-vault) | Portable vault playbook: resolve path via `local-config`/env, PARA, no-space names, `createBy`/`updateBy`, **headless Sync gate before writes** |

## Upstream

- Upstream: https://github.com/kepano/obsidian-skills
- License: MIT (see [LICENSE](LICENSE))
- **Monthly sync (GitHub Actions):** on the **8th of each month** (03:20 UTC) and via **Actions → Sync upstream → Run workflow**, this fork merges `kepano/obsidian-skills` `main`, **deletes `skills/obsidian-cli`**, keeps the other upstream skills plus `obsidian-user-vault`, then pushes `main`. Script: [`scripts/sync-upstream.sh`](scripts/sync-upstream.sh) · workflow: [`.github/workflows/sync-upstream.yml`](.github/workflows/sync-upstream.yml).
