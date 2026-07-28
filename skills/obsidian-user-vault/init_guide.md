# init_guide · 初始化 `obsidian-user-vault`

本文供 **AI agent** 使用：指导用户完成 `obsidian-user-vault` skill 的初始化。

## 交付物

| 文件 | 角色 |
|------|------|
| `SKILL.md` | 模板 → 把用户确认的内容写入 **placeholder（`{{...}}`）** |
| `init_guide.md` | 本指引（流程说明；**非必要不修改**） |

初始化时：**非必要不修改** `SKILL.md` 里占位符以外的模板正文、标题层级与硬性规则条文。

---

## 初始化顺序（仅三步）

```text
1. 确认 vault 路径
2. 确认笔记结构（可选，不一定有）
3. 将用户反馈写入 SKILL.md 的 placeholder
```

---

## Step 1 · 确认 vault 路径

与用户确认：

1. Obsidian vault 在本机的**绝对路径**（例：`/home/user/obsidian`）。
2. （建议）该路径是否存在、是否可见 `.obsidian/`（用于确认是 vault 根；**不要修改**其中文件）。
3. （建议）本机如何检查 / 修复 Obsidian Sync（服务名、命令等）。  
   - Linux + [Headless Sync](https://obsidian.md/help/sync/headless)（`ob`）：可参考同 skill 下 `references/headless-sync.md` 起草检查/修复命令，再请用户确认。  
   - 若用户暂时给不出命令，可先写入简短待补说明，并在 `{{INITIALIZED}}` 旁备注「Sync 命令待补」。
写入 `SKILL.md` 对应项：

| Placeholder | 来源 |
|-------------|------|
| `{{VAULT_ROOT}}` | 用户确认的绝对路径 |
| `{{SYNC_CHECK_COMMANDS}}` | 用户环境的检查命令 |
| `{{SYNC_HEALTH_CRITERIA}}` | 何为健康（用户或环境约定） |
| `{{SYNC_REPAIR_COMMANDS}}` | 异常时的修复命令 |
| `{{SYNC_LIGHT_CHECK}}` | 可选：同 session 轻量策略 |
| `{{FORBID_OBSIDIAN_CLI}}` | 默认 `是`（无 Desktop 时）；用户明确有 GUI 需求再改 |

同步更新 frontmatter `description` 里的路径（若仍含未替换的 `{{VAULT_ROOT}}` 则一并替换）。

---

## Step 2 · 确认笔记结构（可选）

明确告诉用户：**可以没有固定结构**；没有则跳过细化，只保留模板中「未指定」类默认表述。

若用户愿意提供，再收集：

1. 组织法名称或一句话说明（如 PARA、自制、无）。
2. 顶层文件夹列表及各自用途（可先 `ls {{VAULT_ROOT}}` 再请用户确认）。
3. 可选：vault 内已有结构说明文档的路径。
4. 可选：简单放置习惯（判断几句即可）。

写入：

| Placeholder | 来源 |
|-------------|------|
| `{{ORG_METHOD}}` | 用户说明；无则 `未指定` |
| `{{STRUCTURE_DOC}}` | 路径或 `无` |
| `{{TOP_LEVEL_ROWS}}` | 换成表格多行，或 `未指定，按实况 ls + 用户指示` |
| `{{PLACEMENT_HINTS}}` | 用户提示；无则保留模板默认「先 ls + 询问」 |

**不要**在用户未提供时编造 PARA 或其他体系。

---

## Step 3 · 写入 placeholder 并收尾

1. 打开本目录 `SKILL.md`，**只替换** `{{...}}` 为用户确认值。  
2. 硬性规则章节（禁止改 `.obsidian`、写前检查 Sync、标题禁用空格）**保持原文**，不要删、不要改成软建议。  
3. 辅助 skill 列表（`obsidian-markdown` / `obsidian-bases` / `json-canvas` / `defuddle`）**保持原文**。  
4. 设置：

   | Placeholder | 建议值 |
   |-------------|--------|
   | `{{INITIALIZED}}` | `是` |
   | `{{INIT_DATE}}` | 当天日期 |

5. 自检：全文不应再残留需要用户信息却未填的 `{{...}}`（用户明确跳过的项应写成 `未指定` / `无` / `不适用`，而不是留括号占位）。  
6. 向用户简短复述：路径、结构是否填写、Sync 检查方式；确认无误即结束。  
7. 若用户要求安装到 agent skills 目录（如 `~/.agents/skills/obsidian-user-vault/SKILL.md`），再复制就位——**复制不属于改模板结构**，允许。

---

## 禁止事项（初始化过程中）

- 非必要改动 `SKILL.md` 的 heading 层级、§5 硬性规则表述、§6 辅助 skill 表。  
- 修改用户 vault 内 `.obsidian/` 或借初始化之机大改笔记。  
- 在用户未确认路径前，把 skill 当成已绑定某默认库使用。  
- 用户未提供结构时，写入虚构的目录树。

---

## 进度清单

```text
- [ ] Step 1：vault 路径（及 Sync 命令）已写入 placeholder
- [ ] Step 2：结构已写或明确「未指定」
- [ ] Step 3：全部 placeholder 已替换；INITIALIZED=是
- [ ] 未改动硬性规则与辅助 skill 等模板正文
- [ ] （可选）安装到用户 skills 目录
```

---

## 初始化完成后

Agent 与该 vault 交互时：

1. 加载已填写的 `obsidian-user-vault` `SKILL.md`  
2. 创建 / 修改 / 搜索均遵守其中路径与 §5 硬性规则  
3. 格式类任务加载 §6 辅助 skill  
4. 若仍存在未替换的 `{{...}}` 或 `INITIALIZED` 不为「是」：先续跑本指引，再写库  
