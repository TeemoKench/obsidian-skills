# Obsidian Skills (TeemoKench fork)

Agent Skills for use with Obsidian.

Fork of [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) with customizations: **`obsidian-cli` removed**; added **`obsidian-user-vault`** (Wei vault rules: no-space filenames, `createBy`/`updateBy`).

These skills follow the [Agent Skills specification](https://agentskills.io/specification) so they can be used by any skills-compatible agent, including Claude Code, Codex, Open Code, and Hermes.

## Installation

### Marketplace

```
/plugin marketplace add TeemoKench/obsidian-skills
/plugin install obsidian@obsidian-skills
```

### npx skills

```
npx skills add git@github.com:TeemoKench/obsidian-skills.git
```

Instead of ssh, if you prefer to use https:

```
npx skills add https://github.com/TeemoKench/obsidian-skills
```

### Manually

#### Claude Code

Add the contents of this repo to a `/.claude` folder in the root of your Obsidian vault (or whichever folder you're using with Claude Code). See more in the [official Claude Skills documentation](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview).

#### Codex

Copy the `skills/` directory into your Codex skills path (typically `~/.codex/skills`). See the [Agent Skills specification](https://agentskills.io/specification) for the standard skill format.

#### OpenCode

Clone the entire repo into the OpenCode skills directory (`~/.opencode/skills/`):

```sh
git clone https://github.com/TeemoKench/obsidian-skills.git ~/.opencode/skills/obsidian-skills
```

Do not copy only the inner `skills/` folder — clone the full repo so the directory structure is `~/.opencode/skills/obsidian-skills/skills/<skill-name>/SKILL.md`.

OpenCode auto-discovers all `SKILL.md` files under `~/.opencode/skills/`. No changes to `opencode.json` or any config file are needed. Skills become available after restarting OpenCode.

## Skills

| Skill | Description |
|-------|-------------|
| [obsidian-markdown](skills/obsidian-markdown) | Create and edit [Obsidian Flavored Markdown](https://help.obsidian.md/obsidian-flavored-markdown) (`.md`) with wikilinks, embeds, callouts, properties, and other Obsidian-specific syntax |
| [obsidian-bases](skills/obsidian-bases) | Create and edit [Obsidian Bases](https://help.obsidian.md/bases/syntax) (`.base`) with views, filters, formulas, and summaries |
| [json-canvas](skills/json-canvas) | Create and edit [JSON Canvas](https://jsoncanvas.org/) files (`.canvas`) with nodes, edges, groups, and connections |
| [defuddle](skills/defuddle) | Extract clean markdown from web pages using [Defuddle](https://github.com/kepano/defuddle), removing clutter to save tokens |
| [obsidian-user-vault](skills/obsidian-user-vault) | Wei vault playbook: **check headless-sync before writes**, PARA, no-space filenames (`-`), frontmatter `createBy`/`updateBy`, headless Sync (`ob`) |

## Upstream

- Upstream: https://github.com/kepano/obsidian-skills
- License: MIT (see [LICENSE](LICENSE))
