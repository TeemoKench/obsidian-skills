---
name: obsidian-user-vault
description: "Use when Wei asks to find, read, rewrite, create, organize, or search notes in his Obsidian vault; also headless Sync status/install/continuous sync. Before ANY vault write: verify headless-sync healthy. Vault path, PARA, naming, createBy/updateBy."
version: 1.4.0
author: Minnie (Wei)
license: MIT
metadata:
  hermes:
    tags: [obsidian, vault, notes, para, wei, user-custom, headless-sync]
    related_skills:
      - obsidian-markdown
      - obsidian-bases
      - json-canvas
      - defuddle
      - minnie-wei-ops
      - session-purpose
---

# Obsidian User Vault

## Overview

Wei(User) 的 Obsidian vault 操作手册。查找 / 改写 / 创建笔记时**先加载本 skill**，再按任务类型叠加下方 related skills。涉及 **Headless Sync (`ob`)** 时先读 `references/headless-sync.md`。

## When to Use

- 查笔记、搜 vault、列目录
- 新建 / 改写 / 追加 / 移动笔记
- 写 wikilink、callout、properties、embed
- 做 `.base` / `.canvas`
- 网页内容整理进 vault（defuddle）
- 问 vault 在哪、PARA 往哪放
- **Obsidian Headless Sync**：login/status、安装 `ob`、continuous 后台、watchdog、root vs hermes

Don't use for: 纯聊天不碰笔记；改 Hermes 配置（见 `minnie-wei-ops`）；系统 bundled `obsidian` skill 未启用时也不依赖它——本 skill + 文件工具 + `ob` 足够。

## Vault path（权威）

| 项 | 值 |
|----|-----|
| 绝对路径 | `/opt/data/obsidian` |
| 环境变量 | `OBSIDIAN_VAULT_PATH=/opt/data/obsidian`（写在 `$HERMES_HOME/.env`） |
| 库内配置目录 | `/opt/data/obsidian/.obsidian/` |
| Headless CLI | `ob` → `/opt/data/home/.npm-global/bin/ob` 或 `/opt/data/bin/ob` |
| Headless 账号/配置 | `/opt/data/home/.config/obsidian-headless/` |
| 远程库（当前） | **Claw** · id `f73facb9e709a5a0970f4074ad5cff69` · `sync-39.obsidian.md` |
| Continuous 日志/pid | `/opt/data/logs/obsidian-sync.log` · `obsidian-sync.pid` |
| Watchdog | cron every 5m · `/opt/data/scripts/obsidian-sync-watchdog.sh` |

**规则：**

1. 文件工具**不**展开 shell 变量；必须用**解析后的绝对路径**。
2. 禁止把含 `$OBSIDIAN_VAULT_PATH` 的字符串直接塞进文件工具。
3. 跑任何 `ob` 前：`export HOME=/opt/data/home` + PATH 含 npm-global。**绝不用 root HOME。**
4. 旧路径 `/home/hermes/obsidian` **已废弃**；只认 `/opt/data/obsidian`。

## PARA 布局

| 目录 | 用途 | 放什么 |
|------|------|--------|
| `0-Inbox/` | 收件箱 | 拿不准先丢这；临时碎片 |
| `1-Projects/` | 项目 | 有目标 + 有终点 |
| `2-Areas/` | 领域 | 长期责任，无明确终点 |
| `3-Resources/` | 资源 | 参考资料、SOP、LifeTips、技术笔记 |
| `4-Archives/` | 归档 | 完成/不活跃 |
| `5-Daily/` | 日记 | `YYYY-MM-DD.md` |
| `6-Templates/` | 模板 | 项目/领域/资源/每日模板 |
| `Attachments/` | 附件 | 图、PDF |
| `database/` | 数据库相关 | vault 内 database 笔记 |

根说明：`/opt/data/obsidian/PARA 系统说明.md`  
放置速查：`/opt/data/obsidian/3-Resources/Obsidian PARA 放置规则速查表.md`  
（旧路径备注以本 skill 为准。）

### 放置默认习惯

1. 不擅自大搬家；Wei 没说就别整库重构。
2. 新捕获 → `0-Inbox/`，除非明显属于进行中 Project。
3. 能放 Project 的不先塞 Area。
4. 生活向短 SOP/配方 → `3-Resources/LifeTips/`（文件名无空格用 `-`）。
5. 拿不准 → Inbox + `[[wikilink]]`。

## 强制规则：改 vault 前先检查 Headless Sync

`obsidian-headless` continuous sync **有时会卡死**。对 vault **任何写入/改写/移动/删除**（含 `write_file` / `patch` / terminal 写文件）之前，必须先确认 sync 服务正常；**不正常就先修/拉起，再动内容**。

### 写前检查（每次写操作会话至少做一轮；长任务中若怀疑卡死再查）

```bash
export HOME=/opt/data/home
export PATH="/opt/data/home/.npm-global/bin:/opt/data/bin:$PATH"

# 1) continuous 进程在跑？
pgrep -af 'ob sync.*continuous' || cat /opt/data/logs/obsidian-sync.pid 2>/dev/null

# 2) 最近日志是否还在推进 / 是否 Fully synced（而非卡死报错刷屏）
tail -40 /opt/data/logs/obsidian-sync.log

# 3) 配置仍绑定本 vault（辅助）
ob sync-status --path /opt/data/obsidian
```

### 怎样算「正常」

| 信号 | 期望 |
|------|------|
| continuous 进程 | `pgrep` 能看到 `ob sync ... --continuous`，或 pid 文件对应进程仍存活 |
| 日志 | 近期有活动或出现过 `Fully synced`；无持续卡死、无疯狂重复同一错误占满 |
| `ob sync-status` | 仍指向 `/opt/data/obsidian` / Claw（只证明配置，**不能单独**当“活着”） |

### 不正常时（先修再写）

1. 看 log 尾部确认卡死/报错类型。
2. 停掉僵死进程（若 pid 在但无响应）：按 pid/`pkill` 谨慎结束 **continuous** 的 `ob sync`（勿乱杀其它 `ob`）。
3. 重新拉起：`terminal(background=true)` 执行  
   `ob sync --path /opt/data/obsidian --continuous`  
   （日志仍写 `/opt/data/logs/obsidian-sync.log`；也可靠 5m watchdog）。
4. 再跑一遍写前检查，**通过后再**创建/修改笔记。
5. 若短时间无法恢复：先告诉 Wei sync 异常与 log 要点，**默认暂停写 vault**；只有 Wei 明确说「先本地写、同步稍后」才继续写。

### 范围

- **必须检查**：新建/改写/追加/移动/删除笔记与附件等会改 vault 磁盘内容的操作。
- **可只读不强制**：纯搜索、只读 `read_file`、只问路径/PARA——仍建议偶发确认 sync，但不阻断回答。
- 细节与安装见 `references/headless-sync.md`。

## 强制规则：文件名无空格

**新建**的笔记文件名、文件夹名、以及作为路径片段的标题：**禁止空格 (space)**。分隔一律用 **`-`（dash/hyphen）**。

| 错误 | 正确 |
|------|------|
| `My Note.md` | `My-Note.md` |
| `项目 计划.md` | `项目-计划.md` |
| `Life Tips/foo bar.md` | `LifeTips/foo-bar.md` 或 `Life-Tips/foo-bar.md` |

细则：

1. 只约束**新建/另存/移动到的新路径**；vault 里已有带空格的旧文件**不要擅自批量改名**（除非 Wei 明确要求）。
2. 日记例外格式固定：`5-Daily/YYYY-MM-DD.md`（日期里的 `-` 是格式的一部分，合法）。
3. Wikilink 指向新笔记时，目标文件名同样无空格。
4. 扩展名前也不要空格：`foo-bar.md`，不是 `foo-bar .md`。

## 强制规则：frontmatter `createBy` / `updateBy`

AI agent **创建或修改** vault 内 Markdown 笔记时，必须在 YAML frontmatter 写入署名字段。

### 字段

| 字段 | 含义 | 何时写 |
|------|------|--------|
| `createBy` | 创建者（agent 昵称或模型名） | **新建**时写入；之后**不要覆盖/删除**（除非 Wei 明确要求） |
| `updateBy` | 最近一次修改者（agent 昵称或模型名） | **新建与每次 AI 修改**都更新为当前 agent |

### 取值优先级

1. **有稳定昵称** → 用昵称（本环境默认：`Minnie`）
2. **无昵称** → 用当前模型标识（如 `grok-4.5`、`claude-sonnet-4`）
3. 可写成 `昵称/模型`（如 `Minnie/grok-4.5`），但同一会话内保持一致，勿每次换格式

### 示例

新建：

```yaml
---
title: Example-Note
createBy: Minnie
updateBy: Minnie
---
```

或：

```yaml
---
title: Example-Note
createBy: Minnie/grok-4.5
updateBy: Minnie/grok-4.5
---
```

AI 修改已有笔记：

- 若已有 `createBy` → **保留原值**
- 将 `updateBy` 设为当前 agent（昵称或模型）
- 若无 frontmatter → 补上 frontmatter；若缺 `createBy` 且能判断非本次新建 → 可只写 `updateBy`，或 `createBy: unknown`（不要伪造 Wei）
- 若无 `createBy` 且本次是 AI 首次实质性改写、历史作者不明 → `createBy` 可省略或 `unknown`，**必须**写 `updateBy`

### 范围

- 适用于 agent 写入/改写的 `.md` 笔记。
- Wei 本人手改无需 agent 代填；agent 也不要在「只读/只搜」时改 frontmatter。
- `.base` / `.canvas` 无 YAML frontmatter 惯例则跳过这两字段；若格式支持自定义 properties 且任务相关，可按同名属性写入。

## 配套 skills（kepano fork / user-custom）

| Skill | 何时用 |
|-------|--------|
| `obsidian-markdown` | wikilink、callout、properties |
| `obsidian-bases` | `.base` |
| `json-canvas` | `.canvas` |
| `defuddle` | URL → markdown 入库 |

本 fork **不含** `obsidian-cli`；本环境优先**文件系统 + headless `ob`**。

## 标准操作（文件系统优先）

### 查找 / 读取 / 创建 / 改写

- 查找：`search_files` 以 `/opt/data/obsidian` 为 path
- 读取：`read_file` 绝对路径
- **任何写入前**：按「强制规则：改 vault 前先检查 Headless Sync」确认 continuous 正常
- 创建：定 PARA 目录 → **无空格文件名** → frontmatter 含 **`createBy` + `updateBy`** → 需 OFM 时先 `skill_view("obsidian-markdown")` → `write_file`
- 局部改：`patch`（记得更新 `updateBy`）；大改可整写
- 日记：`5-Daily/YYYY-MM-DD.md`（同样要维护 createBy/updateBy）

### 网页入笔记

`defuddle` 清洗 → Inbox 或 Project；带来源链接与日期；文件名无空格；frontmatter 署名。

## Headless Sync（`ob`）

详操与 checklist：`references/headless-sync.md`

### 状态检查（标准顺序）

```bash
export HOME=/opt/data/home
export PATH="/opt/data/home/.npm-global/bin:/opt/data/bin:$PATH"
ob login
ob sync-list-local
ob sync-status --path /opt/data/obsidian
ob sync-list-remote
pgrep -af 'ob sync.*continuous' || cat /opt/data/logs/obsidian-sync.pid
tail -30 /opt/data/logs/obsidian-sync.log
```

`ob sync-status` **只报配置**；是否 Fully synced 看 **sync.log** 或再 `ob sync`。

### Continuous

1. Hermes：`terminal(background=true)` 跑 `ob sync --path /opt/data/obsidian --continuous`（勿在被拦环境用 `nohup`）。
2. Watchdog 每 5m；健康静默；挂了 Python `start_new_session` 拉起。
3. 容器重启后最多等一个 cron 周期自愈；开机即起见 `/opt/data/scripts/s6-obsidian-sync/INSTALL-as-root.md`（需 root）。

### 安装 CLI（无 /usr 写权限）

```bash
npm config set prefix /opt/data/home/.npm-global
npm install -g obsidian-headless
ln -sfn /opt/data/home/.npm-global/bin/ob /opt/data/bin/ob
```

## 完成标准

- [ ] **写 vault 前已检查 headless continuous：进程在 + 日志未卡死**
- [ ] 路径是 `/opt/data/obsidian/...` 绝对路径
- [ ] 新笔记位置符合 PARA / 用户指定
- [ ] **新文件名/文件夹名无空格，分隔用 `-`**
- [ ] **AI 新建：frontmatter 含 `createBy` + `updateBy`**
- [ ] **AI 修改：保留 `createBy`，更新 `updateBy` 为当前 agent**
- [ ] OFM 语法已按 `obsidian-markdown`
- [ ] 未擅自整库重构、未批量改旧空格文件名
- [ ] 回 Wei 用短路径说明
- [ ] 若动 Sync：用 hermes HOME；status 含 login + continuous 进程/log

## Common Pitfalls

1. **sync 卡着还写笔记** — 先 pgrep + tail log；挂了先拉起 continuous。
2. **只看 `ob sync-status` 当活着** — 那只是配置；要以 continuous 进程和 log 为准。
3. **猜路径** — 不信 macOS 旧路径或 `/home/hermes/obsidian`。
4. **文件工具塞 `$VAR`** — 先解析。
5. **文件名带空格** — 新建一律 `-`，不要 `My Note.md`。
6. **漏写 createBy/updateBy** — AI 落盘笔记必须署名。
7. **修改时覆盖 createBy** — 只更新 `updateBy`。
8. **跳过 obsidian-markdown** — 双链半吊子。
9. **Inbox 永久堆积** — 整理时再分类。
10. **VS Code Attach Shell = root** — 凭证进 `/root/.config/...`，Hermes 看不见。必须 hermes + `HOME=/opt/data/home`；root 登过则拷 config + `chown -R 1000:1000` vault 与 config。
11. **root 同步后的属主** — `chown -R 1000:1000 /opt/data/obsidian`。
12. **桌面 Sync + Headless 同设备** — 官方禁止；本机只跑 headless continuous。
13. **write_file 写 vault 被拦** — 改 terminal 写入，核属主 hermes。
14. **status 有配置 ≠ continuous 在跑** — 要 pgrep / pid / log。

## Quick map

> Vault=`/opt/data/obsidian` · **写前先查 headless continuous** · `ob`+HOME=`/opt/data/home` · PARA · **文件名禁止空格用 `-`** · **createBy/updateBy** · continuous+5m watchdog · 语法 `obsidian-markdown` · headless 见 `references/headless-sync.md`。

## Support files

- `references/headless-sync.md` — login/setup/continuous/watchdog/root 迁移
