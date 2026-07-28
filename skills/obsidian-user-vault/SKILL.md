---
name: obsidian-user-vault
description: >
  与用户个人 Obsidian vault 交互：在 {{VAULT_ROOT}} 下创建、修改、搜索笔记。
  Vault 经 Obsidian Sync 同步。写库前须检查 sync；禁止改 .obsidian；标题禁用空格。
  用户提到笔记、vault、Obsidian、日记或知识库时使用。辅助：obsidian-markdown、
  obsidian-bases、json-canvas、defuddle。
---

# Obsidian User Vault

> **模板说明**：`{{...}}` 为初始化占位符，由 agent 按同目录 [`init_guide.md`](init_guide.md) 写入用户确认值。  
> **非必要不改**占位符以外的模板正文、标题层级与硬性规则。  
> 若 `{{INITIALIZED}}` 不是「是」、或仍含未填 `{{...}}`：先完成初始化，再写库。
---

## 1. 用途

本 skill 用于与用户的 **Obsidian vault** 交互。Vault 通过 **Obsidian Sync** 同步。

Agent 应能在遵守本文件规则的前提下，帮助用户完成：

- **创建**笔记（及约定范围内的相关文件）
- **修改**已有笔记内容
- **搜索 / 阅读** vault 内笔记与结构

正文格式与专项文件类型，委托下列辅助 skill（见 §6），本 skill 负责**路径、结构、硬性规则与写前闸门**。

---

## 2. Vault 位置

| 项 | 值 |
|----|-----|
| Vault 根路径 | `{{VAULT_ROOT}}` |
| 配置目录 | `{{VAULT_ROOT}}/.obsidian/`（**禁止修改**，见 §5） |
| Sync | Obsidian Sync（本机检查方式见 §4） |

- 所有笔记读写默认只在 `{{VAULT_ROOT}}` 下进行。
- 初始化后请将本表填实，并视需要更新 frontmatter `description` 中的路径。

---

## 3. 笔记结构

> 用户**可以不提供**固定结构。未提供时：放置前 `ls` vault 根与目标目录，询问用户，勿臆造体系。

### 3.1 组织法（可选）

| 项 | 值 |
|----|-----|
| 组织法 / 说明 | `{{ORG_METHOD}}` |
| 结构说明文档（vault 内路径，可选） | `{{STRUCTURE_DOC}}` |

### 3.2 顶层目录（可选，用户提供则填写）

| 相对路径 | 用途 |
|----------|------|
| `{{TOP_LEVEL_ROWS}}` | （初始化时替换为本表多行；无则写「未指定，按实况 ls + 用户指示」） |

### 3.3 放置提示（可选）

```text
{{PLACEMENT_HINTS}}
```

无结构信息时保持：

```text
未指定固定结构：创建或移动前先 ls，并询问用户目标路径。
```

---

## 4. 写前闸门：Obsidian Sync

**在任何 create / edit / move / delete 之前，必须检查 Obsidian Sync 状态。**  
状态异常时：**先修复 Sync，再写入**。只读搜索/阅读可跳过本闸门。

### 4.1 检查命令（按用户环境填写）

Linux / Headless Sync（`ob`）可参考 [`references/headless-sync.md`](references/headless-sync.md) 填写下列占位符。

```bash
{{SYNC_CHECK_COMMANDS}}
```
### 4.2 健康标准

`{{SYNC_HEALTH_CRITERIA}}`

### 4.3 异常时修复

```bash
{{SYNC_REPAIR_COMMANDS}}
```

修复后须重新检查，确认健康再写。  
若修复后仍异常：告知用户并**停止写入**，除非用户明确允许仅本地编辑。

### 4.4 Session 内策略（可选细化）

| 项 | 值 |
|----|-----|
| 同 session 后续写入 | `{{SYNC_LIGHT_CHECK}}` |

---

## 5. 硬性规则

以下规则**不可在初始化时删改含义**；仅允许把命令类占位符填成用户环境的具体命令。

### 5.1 禁止修改 `.obsidian`

- **禁止**创建、编辑、删除 `{{VAULT_ROOT}}/.obsidian/` 下任何配置文件或插件状态。
- 该目录为 Obsidian 应用配置，不是笔记内容区。

### 5.2 写入前必须保证 Sync 正常

- 见 §4。Sync 异常 → 先修复 → 再写。
- 不得在已知 Sync 异常时继续改笔记。

### 5.3 标题禁止空格

- 笔记**标题**不得包含空格（space）。
- 多词使用 `-` 分隔。  
  - 正确：`My-Note-Title`、`会议纪要-2026-07-28`  
  - 错误：`My Note Title`、`会议纪要 2026-07-28`
- 建议文件名与标题一致且同样无空格，避免链接与同步困扰。
- 库内**历史**已含空格的标题/文件名：不要批量重命名，除非用户明确要求改某一文件。

---

## 6. 辅助 Skill

为更好的 Obsidian 笔记格式，按任务加载：

| Skill | 用途 |
|-------|------|
| `obsidian-markdown` | `.md`：wikilink、embed、callout、properties 等 |
| `obsidian-bases` | `.base` 数据库视图 |
| `json-canvas` | `.canvas` 画布 |
| `defuddle` | 网页剪藏为干净 Markdown 再入库 |

- 库内链接优先 `[[wikilink]]`；外部链接用 `[text](url)`。
- 检索用文件系统工具（`rg` / `find` / 读文件）在 `{{VAULT_ROOT}}` 下进行。
- **不要**依赖需要 Desktop GUI 的 `obsidian` CLI（除非用户在初始化时明确改写本节——默认禁止）。

| 项 | 值 |
|----|-----|
| 是否禁止 Obsidian CLI | `{{FORBID_OBSIDIAN_CLI}}` |

---

## 7. 工作自检

写库前快速确认：

- [ ] 路径在 `{{VAULT_ROOT}}` 下
- [ ] **未**改动 `.obsidian/`
- [ ] 已按 §4 确认 Sync 健康（或只读任务）
- [ ] 新标题（及建议的新文件名）**无空格**，词间用 `-`
- [ ] 结构按 §3 / 用户当次指示；格式按 §6 辅助 skill

---

## 8. 初始化状态

| 项 | 值 |
|----|-----|
| 是否已完成用户化 | `{{INITIALIZED}}` |
| 初始化日期 | `{{INIT_DATE}}` |
