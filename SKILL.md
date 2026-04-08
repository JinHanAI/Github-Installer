---
name: github-installer
description: "GitHub 项目安装器：当用户说'安装'+ GitHub URL 时触发，自动分类、克隆、安装依赖、检查配置、分析触发词、更新 README，4 步闭环。配合 UserPromptSubmit Hook 实现强制触发。"
risk: safe
author: Victor.Chen
---

# GitHub 项目安装器（github-installer）

当用户说"安装"并附带 GitHub URL 时，自动执行完整的安装+登记流程。

配合 Claude Code 的 `UserPromptSubmit` Hook，实现"说了就装、装完不漏"的闭环体验。

---

## 触发条件

**强制触发**（由 Hook 注入触发）：
- 用户消息包含"安装" + GitHub URL（`github.com/owner/repo`）

**不触发**：
- 用户说"收藏" / "记录" + GitHub URL
- 用户只是提到项目名但没有安装意图

---

## 工作流程（必须逐项执行，不可跳过）

### 步骤 1：解析与分类

1. 从用户消息中提取 GitHub URL（`github.com/owner/repo`）
2. 用 `gh repo view` 获取项目信息（description、language 等）
3. 根据下表自动分类：

| 类型 | 安装位置 | 判断关键词 |
|------|----------|-----------|
| **MCP** | `{Skills根目录}/MCP/` | mcp, model context protocol |
| **插件** | `{Skills根目录}/plugins/` | plugin, claude code plugin |
| **技能** | `{Skills根目录}/Skills/` 对应子目录 | skill |
| **CLI 工具** | `{Skills根目录}/cli-tools/` | cli, command-line tool |
| **其他** | — | **提醒用户并询问** |

> `{Skills根目录}` 请根据你自己的目录结构替换。

### 步骤 2：克隆与安装

1. 克隆到对应分类目录
2. 检查并安装依赖（`npm install` / `pip install` / 其他）
3. 如果是 Claude Code Skill，执行 `npx skills add owner/repo@skill -g -y` 安装到全局

### 步骤 3：安装后 4 步闭环（铁律，不可省略）

#### 3.1 检查配置需求

读取 `SKILL.md` 或 `README.md`，检查是否需要：
- API Key / Token
- 额外依赖安装
- 环境变量配置

如果需要配置，列出清单并告知用户。

#### 3.2 分析触发词

根据技能功能，提炼 2-4 个触发词（中英文各至少一个）。

#### 3.3 更新 Skills README

在你的 Skills 管理文档中更新以下信息：
1. **已安装技能表**：如果安装到了全局，添加一行
2. **技能调用速查表**：添加技能条目 + 触发词
3. **新增技能记录表**：添加安装记录（日期、来源、功能、存放位置）

#### 3.4 确认汇报

向用户展示安装结果摘要：
- 项目名称 + 分类
- 安装位置
- 是否需要额外配置
- 触发词

---

## 铁律

1. **步骤 3 的 4 个子步骤必须全部执行完毕后才能告知用户"安装完成"**
2. **如果任何步骤失败，必须告知用户失败原因，不可静默跳过**
3. **README 更新是必选项，不是可选项**

---

## 使用示例

| 用户说 | 技能动作 |
|--------|---------|
| "安装 https://github.com/xxx/skill" | 分类 → 克隆 → 安装 → 4步闭环 → 汇报 |
| "安装这个 https://github.com/xxx/mcp-server" | 分类为 MCP → 克隆到 MCP 目录 → 安装 → 汇报 |
