#!/bin/bash
# github-installer-trigger.sh
# Detects "安装" + GitHub URL in user prompt and injects a reminder to invoke the Skill.
# 检测用户说"安装" + GitHub URL 时，注入提示调用 github-installer 技能。

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

if echo "$PROMPT" | grep -qi "安装" && echo "$PROMPT" | grep -qi "github\.com"; then
    echo '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"检测到安装 GitHub 项目的意图。请立即使用 Skill 工具调用 github-installer 技能执行完整安装流程（分类→克隆→安装依赖→检查配置→分析触发词→更新README→确认汇报）。"}}'
    exit 0
fi

exit 0
