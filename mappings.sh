# Repo-relative path -> target path. Shared by install.sh and sync.sh.
MAPPINGS=(
  "zsh/zshrc:$HOME/.zshrc"
  "zsh/p10k.zsh:$HOME/.p10k.zsh"
  "claude/mcp.json:$HOME/.claude/.mcp.json"
  "claude/statusline-command.sh:$HOME/.claude/statusline-command.sh"
  "skills/common/commit:$HOME/.claude/skills/commit"
  "skills/common/pr:$HOME/.claude/skills/pr"
  "skills/claude/codex-delegate:$HOME/.claude/skills/codex-delegate"
)

# Repo defaults that become independent personal files after their first install.
TEMPLATE_MAPPINGS=(
  "claude/settings.json:$HOME/.claude/settings.json"
  "codex/config.toml:$HOME/.codex/config.toml"
)
