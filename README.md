# Github-Installer

> *「装完了，然后呢？」*

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-blueviolet)](https://claude.ai/code)
[![Skills](https://img.shields.io/badge/skills.sh-Compatible-green)](https://skills.sh)

**Claude Code 安装 GitHub 项目，最容易漏的不是安装本身，而是装完之后的那几步。**

检查 API Key 了吗？触发词分析了吗？Skills README 更新了吗？——每次都说"下次不会忘"，每次都忘。

Github-Installer 用 **Skill + Hook 双层机制**解决这个问题：Hook 检测意图，Skill 强制执行检查清单，确保每次安装都走完完整流程。

[看效果](#效果示例) · [安装](#安装) · [工作原理](#工作原理) · [English](#english)

---

## 效果示例

```
用户      ❯ 安装 https://github.com/alchaincyf/nuwa-skill

AI        ❯ 🔍 检测到安装 GitHub 项目意图，调用 github-installer 技能...

            步骤 1/4：检查配置需求
            ✅ 纯 Markdown 指令型技能，无需 API Key / Token / 依赖安装

            步骤 2/4：分析触发词
            ✅ 「造skill」「蒸馏XX」「女娲」「造人」「XX的思维方式」

            步骤 3/4：更新 Skills README
            ✅ 已在速查表、全局技能表、新增记录表中登记

            步骤 4/4：确认汇报
            📦 Nuwa-Skill（女娲思维蒸馏）| ⭐ 3,217 | 社区技能
            📁 社区技能（网络下载）/nuwa-skill_女娲思维蒸馏
            🔧 无需额外配置

            ✅ 安装完成
```

没有 Hook 也行。但有了 Hook，你连"调用技能"这句话都不用说——检测到"安装"+ GitHub URL 就自动触发。

---

## 安装

### 方式一：Skill + Hook（推荐）

**1. 安装 Skill**

```bash
cd ~/.claude/skills/  # 或你的自定义 Skills 目录
git clone https://github.com/JinHanAI/Github-Installer.git github-installer
```

**2. 配置 Hook**

Hook 是关键——它监听你提交的每条消息，检测到"安装"+ GitHub URL 时自动注入提示。

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/github-installer-trigger.sh << 'EOF'
#!/bin/bash
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

if echo "$PROMPT" | grep -qi "安装" && echo "$PROMPT" | grep -qi "github\.com"; then
    echo '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"检测到安装 GitHub 项目的意图。请立即使用 Skill 工具调用 github-installer 技能执行完整安装流程（分类→克隆→安装依赖→检查配置→分析触发词→更新README→确认汇报）。"}}'
    exit 0
fi

exit 0
EOF

chmod +x ~/.claude/hooks/github-installer-trigger.sh
```

在 `~/.claude/settings.json` 中添加：

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/Users/YOUR_USERNAME/.claude/hooks/github-installer-trigger.sh"
          }
        ]
      }
    ]
  }
}
```

> 把 `YOUR_USERNAME` 替换成你的系统用户名。

**3. 自定义目录**

编辑 `SKILL.md` 中的分类表，将 `{Skills根目录}` 替换为你自己的目录结构。

### 方式二：只用 Skill（无 Hook）

```bash
cd ~/.claude/skills/
git clone https://github.com/JinHanAI/Github-Installer.git github-installer
```

手动触发：对话中说 `github-installer` + GitHub URL 即可。

---

## 工作原理

```
┌──────────────────────────────────────────────────────────┐
│                      用户提交 Prompt                       │
│              "安装 https://github.com/xxx/yyy"            │
└────────────────────────┬─────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────┐
│              UserPromptSubmit Hook                        │
│         检测到 "安装" + "github.com"                      │
│         注入提示："请调用 github-installer 技能"            │
└────────────────────────┬─────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────┐
│              github-installer Skill 加载                  │
│                                                          │
│   步骤 1：解析与分类                                      │
│   ├── 提取 GitHub URL                                    │
│   ├── gh repo view 获取项目信息                           │
│   └── 自动分类（MCP / 插件 / 技能 / CLI / 其他）          │
│                                                          │
│   步骤 2：克隆与安装                                      │
│   ├── 克隆到对应分类目录                                  │
│   ├── 安装依赖                                           │
│   └── 如果是 Skill → npx skills add 全局安装              │
│                                                          │
│   步骤 3：4 步闭环（铁律）                                │
│   ├── 3.1 检查配置需求（API Key / Token / 依赖）          │
│   ├── 3.2 分析触发词（中英文各至少一个）                   │
│   ├── 3.3 更新 Skills README（3 处登记）                  │
│   └── 3.4 确认汇报（摘要展示）                            │
└──────────────────────────────────────────────────────────┘
```

### 4 步闭环检查清单

| 步骤 | 做什么 | 为什么重要 |
|------|--------|-----------|
| **1. 检查配置** | 读取 SKILL.md，检查 API Key / Token / 环境变量 | 装了不能用，等于没装 |
| **2. 分析触发词** | 提炼 2-4 个触发词（中英文各至少一个） | 没触发词的技能是隐形技能 |
| **3. 更新 README** | 在 Skills 管理文档中 3 处登记 | 下次搜不到，等于不存在 |
| **4. 确认汇报** | 展示安装摘要：名称、分类、配置需求、触发词 | 让你知道装了什么、缺什么 |

### 自动分类

| 类型 | 判断关键词 | 安装位置 |
|------|-----------|---------|
| **MCP 服务器** | mcp, model context protocol | `{根目录}/MCP/` |
| **插件** | plugin, claude code plugin | `{根目录}/plugins/` |
| **技能** | skill | `{根目录}/Skills/` |
| **CLI 工具** | cli, command-line tool | `{根目录}/cli-tools/` |
| **其他** | — | 提醒用户确认 |

---

## 铁律

1. **4 步闭环必须全部完成才能说"安装完成"**
2. **任何步骤失败必须告知原因，不可静默跳过**
3. **README 更新是必选项，不是可选项**

---

## 依赖

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `gh` CLI — 获取 GitHub 项目信息
- `jq` — Hook 脚本中解析 JSON

---

## 许可证

GPL 3.0 — 随便用，随便改，改了请开源。

---

## English

> *"You installed it. Then what?"*

The hardest part of installing GitHub projects into Claude Code isn't the installation itself — it's the post-install steps you keep forgetting.

Did you check for API keys? Analyze trigger words? Update your Skills README?

**Github-Installer** solves this with a **Skill + Hook dual mechanism**: the Hook detects your intent, the Skill enforces a mandatory 4-step checklist. Every time.

**Install:**

```bash
cd ~/.claude/skills/
git clone https://github.com/JinHanAI/Github-Installer.git github-installer
```

**How it works:**

```
You say: "安装 https://github.com/xxx/yyy"
  → UserPromptSubmit Hook fires (detects "安装" + "github.com")
  → Hook injects: "Please invoke github-installer skill"
  → Skill loads 4-step checklist
  → Step 1: Check config (API keys, tokens, env vars)
  → Step 2: Analyze trigger words (at least 1 EN + 1 CN)
  → Step 3: Update Skills README (3 locations)
  → Step 4: Confirm report (summary to user)
```

**Auto-classification:** MCP servers, plugins, skills, CLI tools — sorted by keywords, installed to the right directory automatically.

**The 3 iron rules:**
1. All 4 steps must complete before saying "done"
2. Any failure must be reported, never silently skipped
3. README update is mandatory, not optional

See the Chinese README above for the Hook setup guide and detailed configuration.

---

**Author:** Victor.Chen ([@AIJinHan](https://github.com/JinHanAI))

**License:** GPL 3.0

