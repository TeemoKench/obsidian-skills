# Obsidian Skills (TeemoKench fork)

Agent Skills for [Obsidian](https://obsidian.md/), following the [Agent Skills specification](https://agentskills.io/specification). Compatible with skills-aware agents (Claude Code, Codex, OpenCode, Hermes, Grok, etc.).

Fork of [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) with customizations:

- **`obsidian-cli` removed** — needs Obsidian Desktop GUI; not suitable for pure CLI / headless hosts
- Upstream four kept: **markdown / bases / json-canvas / defuddle**
- Added **`obsidian-user-vault`** — template skill for a user vault on **Obsidian Sync**, with `init_guide.md` onboarding

## Who this is for

- **Linux / no-GUI / pure CLI** — agents treat the vault as files on disk; optional [Headless Sync](https://obsidian.md/help/sync/headless) (`ob`) on the server
- **[Obsidian Sync](https://obsidian.md/sync) users** — same vault as phone/desktop elsewhere; agent must check Sync health before writes (see `obsidian-user-vault`)

You do **not** need the Obsidian desktop app on the machine where the agent runs.

## Installation

Install skills into **`~/.agents/skills`** (one folder per skill, each with `SKILL.md`).

### Recommended: clone + symlink

```sh
git clone https://github.com/TeemoKench/obsidian-skills.git ~/src/obsidian-skills
mkdir -p ~/.agents/skills
for d in ~/src/obsidian-skills/skills/*/; do
  name="$(basename "$d")"
  ln -sfn "$d" "$HOME/.agents/skills/$name"
done
ls -la ~/.agents/skills
```

Reload / restart the agent so it rescans skills.

### Alternative: copy

```sh
mkdir -p ~/.agents/skills
cp -a ~/src/obsidian-skills/skills/. ~/.agents/skills/
```

Prefer symlink if you want `git pull` updates without recopying.

### Optional: SSH clone

```sh
git clone git@github.com:TeemoKench/obsidian-skills.git ~/src/obsidian-skills
# then the same mkdir + ln -sfn loop as above
```

### Notes

- Target layout: `~/.agents/skills/<skill-name>/SKILL.md`
- Do not install only the repo root without the inner `skills/*` folders
- If your agent uses another skills root, point it at `~/.agents/skills` or symlink accordingly

## Skills

| Skill | Description |
|-------|-------------|
| [obsidian-markdown](skills/obsidian-markdown) | Create and edit [Obsidian Flavored Markdown](https://help.obsidian.md/obsidian-flavored-markdown) (`.md`) — wikilinks, embeds, callouts, properties |
| [obsidian-bases](skills/obsidian-bases) | Create and edit [Obsidian Bases](https://help.obsidian.md/bases/syntax) (`.base`) |
| [json-canvas](skills/json-canvas) | Create and edit [JSON Canvas](https://jsoncanvas.org/) (`.canvas`) |
| [defuddle](skills/defuddle) | Extract clean markdown from web pages ([Defuddle](https://github.com/kepano/defuddle)) |
| [obsidian-user-vault](skills/obsidian-user-vault) | **Template** playbook for the user’s Sync vault: path + optional structure placeholders, create/edit/search rules, Sync gate, hard rules; onboard via `init_guide.md` |

## obsidian-user-vault

Portable **template** (not a hard-coded personal path). Interact with the user’s vault over the filesystem + Obsidian Sync.

| File | Role |
|------|------|
| [`skills/obsidian-user-vault/SKILL.md`](skills/obsidian-user-vault/SKILL.md) | Skill template with `{{placeholders}}` |
| [`skills/obsidian-user-vault/init_guide.md`](skills/obsidian-user-vault/init_guide.md) | Agent guide to initialize the template with the user |
| [`skills/obsidian-user-vault/references/headless-sync.md`](skills/obsidian-user-vault/references/headless-sync.md) | Optional: Headless Sync (`ob`) ops for filling Sync check/repair commands |

### What the skill covers

1. **Vault location** and write rules — create, modify, search notes under the configured root  
2. **Optional note structure** — only if the user provides one (no forced PARA)  
3. **Companion skills** — `obsidian-markdown`, `obsidian-bases`, `json-canvas`, `defuddle`  

### Hard rules (in the template)

1. **Do not modify** `.obsidian/` config  
2. **Before write/edit**: check Obsidian Sync; if unhealthy, **repair Sync first**  
3. **Titles: no spaces** — use `-` as separator  

### Initialize (first use)

Ask the agent to follow `init_guide.md` (three steps only):

1. Confirm vault path (and Sync check/repair commands for this host)  
2. Confirm note structure (**optional**)  
3. Write answers into `SKILL.md` **placeholders only** — do not rewrite the rest of the template unless necessary  

After init, `{{INITIALIZED}}` should be `是` and path/Sync placeholders should be filled. Symlinked installs edit the files in this repo clone.

## Upstream

- Upstream: https://github.com/kepano/obsidian-skills  
- License: MIT (see [LICENSE](LICENSE))  
- **Monthly sync (GitHub Actions):** on the **8th of each month** (03:20 UTC) and via **Actions → Sync upstream → Run workflow**, this fork merges `kepano/obsidian-skills` `main`, **deletes `skills/obsidian-cli` and `.claude-plugin`**, keeps the other upstream skills plus `obsidian-user-vault`, then pushes `main`. Script: [`scripts/sync-upstream.sh`](scripts/sync-upstream.sh) · workflow: [`.github/workflows/sync-upstream.yml`](.github/workflows/sync-upstream.yml).
