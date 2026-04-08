# Github-Installer

> A Claude Code Skill + Hook combo that automates GitHub project installation with a mandatory 4-step checklist.
> Claude Code 技能 + Hook 组合，自动安装 GitHub 项目并强制执行 4 步闭环检查。

---

## The Problem / 解决什么问题

**EN:** When installing GitHub projects into Claude Code, it's easy to skip post-install steps — forgetting to check for API keys, forgetting to update your Skills README, or forgetting to document trigger words.

**CN:** 安装 GitHub 项目到 Claude Code 时，很容易漏掉后续步骤——忘了检查是否需要 API Key、忘了更新 Skills README、忘了记录触发词。

**EN:** Github-Installer solves this with a **Skill + Hook dual-layer mechanism**: the Hook detects your intent and forces the Skill to run its checklist every time.

**CN:** Github-Installer 通过 **Skill + Hook 双层机制**解决这个问题：Hook 检测你的安装意图，强制触发 Skill 的检查清单，确保每次都不遗漏。

---

## How It Works / 工作原理

```
You say: "安装 https://github.com/xxx/yyy"
  → UserPromptSubmit Hook fires (detects "安装" + "github.com")
  → Hook injects: "Please invoke github-installer skill"
  → AI loads Skill checklist
  → Executes step by step:
      Classify → Clone → Install → Check Config → Analyze Triggers → Update README → Confirm
```

```
你说："安装 https://github.com/xxx/yyy"
  → UserPromptSubmit Hook 触发（检测到"安装" + "github.com"）
  → Hook 注入提示："请调用 github-installer 技能"
  → AI 加载 Skill 检查清单
  → 逐步执行：
      分类 → 克隆 → 安装 → 检查配置 → 分析触发词 → 更新README → 确认汇报
```

---

## Features / 功能特点

| EN | CN |
|----|-----|
| Auto-classify project type (MCP / Plugin / Skill / CLI / Other) | 自动分类项目类型（MCP / 插件 / 技能 / CLI / 其他） |
| Clone to correct directory based on classification | 根据分类克隆到正确目录 |
| Install dependencies automatically | 自动安装依赖 |
| Mandatory 4-step post-install checklist | 强制 4 步安装后检查清单 |
| Hook-enforced trigger (never miss the flow) | Hook 强制触发（绝不漏流程） |

---

## Installation / 安装

### 1. Install the Skill / 安装技能

```bash
# Clone to your Skills directory
cd ~/.claude/skills/  # or your custom Skills directory
git clone https://github.com/JinHanAI/Github-Installer.git github-installer
```

### 2. Set up the Hook (Recommended) / 配置 Hook（推荐）

**EN:** The Hook watches every prompt you submit. When it detects "安装" + a GitHub URL, it injects a reminder to invoke the Skill.

**CN:** Hook 监听你提交的每条消息。当检测到"安装" + GitHub URL 时，自动注入调用技能的提示。

Create the Hook script / 创建 Hook 脚本：

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

Add Hook config to `~/.claude/settings.json` / 在 `~/.claude/settings.json` 中添加配置：

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

> Replace `YOUR_USERNAME` with your actual username. / 将 `YOUR_USERNAME` 替换为你的系统用户名。

### 3. Customize / 自定义

**EN:** Edit the classification table in `SKILL.md` to match your directory structure. Replace `{Skills根目录}` with your own path.

**CN:** 编辑 `SKILL.md` 中的分类表以匹配你的目录结构。将 `{Skills根目录}` 替换为你自己的路径。

---

## The 4-Step Checklist / 4 步闭环检查清单

**EN:** Every installation must complete all 4 steps before reporting "done":

**CN:** 每次安装必须完成全部 4 步才能报告"安装完成"：

| Step / 步骤 | EN | CN |
|-------------|----|-----|
| 1 | **Check Config** — Read SKILL.md, check for API keys, tokens, env vars | **检查配置** — 读取 SKILL.md，检查 API Key、Token、环境变量 |
| 2 | **Analyze Triggers** — Extract 2-4 trigger words (at least 1 EN + 1 CN) | **分析触发词** — 提炼 2-4 个触发词（至少 1 英文 + 1 中文） |
| 3 | **Update README** — Add entry to your Skills management doc | **更新 README** — 在 Skills 管理文档中添加记录 |
| 4 | **Confirm Report** — Show summary: name, category, config needs, triggers | **确认汇报** — 展示摘要：名称、分类、配置需求、触发词 |

---

## Usage / 使用方法

| You say / 你说 | Action / 动作 |
|---------------|--------------|
| `安装 https://github.com/xxx/skill` | Classify → Clone → Install → 4-step checklist → Report |
| `安装这个 https://github.com/xxx/mcp-server` | Classify as MCP → Clone → Install → Report |

---

## Requirements / 依赖

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `gh` CLI — for fetching GitHub project info / 获取 GitHub 项目信息
- `jq` — for JSON parsing in Hook script / Hook 脚本中解析 JSON

---

## Author / 作者

Victor.Chen ([@AIJinHan](https://github.com/JinHanAI))

## License

[GPL 3.0](LICENSE)
