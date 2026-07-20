# Repo-relative path -> target path. Shared by install.sh and sync.sh.
MAPPINGS=(
  "zsh/zshrc:$HOME/.zshrc"
  "zsh/p10k.zsh:$HOME/.p10k.zsh"
  "claude/settings.json:$HOME/.claude/settings.json"
  "claude/mcp.json:$HOME/.claude/.mcp.json"
  "claude/statusline-command.sh:$HOME/.claude/statusline-command.sh"
  "claude/skills/commit:$HOME/.claude/skills/commit"
  "claude/skills/pr:$HOME/.claude/skills/pr"
  "claude/skills/codex-delegate:$HOME/.claude/skills/codex-delegate"
  "codex/config.toml:$HOME/.codex/config.toml"
)
