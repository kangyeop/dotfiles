# dotfiles

개인용 Claude Code, Codex, zsh 설정. 여러 기기 간에 동기화해서 사용.

## 사전 준비

`install.sh`를 실행하기 전에 아래 항목들은 직접 설치해야 함 — 이 레포는 설정 파일을 심링크하고, Claude/Codex 기본 설정만 최초 1회 복사할 뿐, 툴 자체를 설치하지는 않음:

- [Homebrew](https://brew.sh)
- [oh-my-zsh](https://ohmyz.sh) + [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [nvm](https://github.com/nvm-sh/nvm), rbenv, [bun](https://bun.sh)
- `fzf`, `zsh-syntax-highlighting`, `zsh-autosuggestions` (`.zshrc`에서 참조하는 zsh 플러그인)
- [Claude Code](https://claude.com/claude-code) CLI
- [Codex CLI](https://developers.openai.com/codex/cli), 그리고 [`openai/codex-plugin-cc`](https://github.com/openai/codex-plugin-cc) Claude Code 플러그인 (Claude Code 안에서 `/plugin marketplace add`, `/plugin install`로 설치 — `claude/settings.json`에 이미 등록돼 있어서 재시작 시 자동 동기화됨)
- `oh-my-codex` (`~/.codex/prompts` 관리)

`install.sh`가 자동으로 설치해주는 것:

- `agent-browser` npm 패키지 (설치되면서 `~/.claude/skills/agent-browser` 심링크를 자체적으로 등록함)

## 사용법

```sh
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh`는 idempotent함. 심링크 대상 파일이 이미 존재하면(그리고 올바른 심링크가 아니면) 심링크를 걸기 전에 `~/.dotfiles-backup/<timestamp>/`로 옮겨둠. 단, `claude/settings.json`과 `codex/config.toml`은 개인 상태가 자동 기록되는 것을 막기 위해 심링크하지 않는 초기 템플릿이다. 대상 파일이 없을 때만 복사하며, 이미 있으면 보존한다.

반대 방향으로 — 즉 로컬 변경사항을 레포에 반영하고 싶을 때는(예: 에디터의 atomic-save가 추적 중인 심링크를 일반 파일로 덮어썼거나, 이 기기에서 설정을 직접 손으로 고친 경우) `./sync.sh`를 실행. 드리프트된 대상 파일의 내용을 레포 파일로 복사한 뒤 다시 심링크로 되돌림. 두 스크립트는 `mappings.sh`에 정의된 동일한 파일 목록을 공유한다. Claude/Codex 설정은 개인 파일이므로 `sync.sh` 대상이 아니다. 이 두 개인 설정을 기본 템플릿으로 의도적으로 가져오려면 `./sync-templates.sh`를 실행한다. 스크립트가 먼저 차이를 출력한 뒤 템플릿을 갱신하므로, 실행 후 `git diff`로 검토한다.

## 추적 대상

`skills/`는 에이전트별로 디렉토리를 분리한다 — `skills/common`(claude/codex 공용), `skills/claude`(claude 전용), `skills/codex`(codex 전용, 아직은 README만 있고 codex 전용 스킬이 생기면 여기에 추가). 실제 심링크 목적지는 에이전트 구분과 무관하게 전부 `~/.claude/skills/<name>` 평면 구조다.

| 레포 파일 | 심링크 위치 |
|---|---|
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/p10k.zsh` | `~/.p10k.zsh` |
| `claude/settings.json` | `~/.claude/settings.json`에 최초 1회 복사하는 기본 템플릿 |
| `claude/mcp.json` | `~/.claude/.mcp.json` |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` |
| `skills/common/commit` | `~/.claude/skills/commit` |
| `skills/common/pr` | `~/.claude/skills/pr` |
| `skills/claude/codex-delegate` | `~/.claude/skills/codex-delegate` |
| `codex/config.toml` | `~/.codex/config.toml`에 최초 1회 복사하는 기본 템플릿 |

## 알려진 예외사항 (기기별로 수동 수정 필요)

- `claude/mcp.json`의 `filesystem` MCP 서버는 `/Users/yeop/dev`를 인자로 하드코딩하고 있음. JSON은 셸 변수 확장을 지원하지 않으므로, 기기마다 사용자명이나 dev 폴더 경로가 다르면 클론 후 직접 수정해야 함.
- `codex/config.toml`의 `notify` 훅은 특정 nvm Node 버전을 거치는 절대 경로를 포함함. 이건 `oh-my-codex`의 자체 setup으로 재생성되는 값이라, 값이 stale하면 손으로 고치기보다 그 툴의 setup을 재실행할 것.
