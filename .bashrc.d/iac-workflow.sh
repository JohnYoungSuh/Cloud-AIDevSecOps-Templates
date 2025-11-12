# IaC workflow environment setup
# Source this from ~/.bashrc: [ -f /path/to/.bashrc.d/iac-workflow.sh ] && source /path/to/.bashrc.d/iac-workflow.sh

# Initialize starship prompt
if command -v starship &>/dev/null; then
  export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$(git rev-parse --show-toplevel 2>/dev/null)/.config/starship.toml}"
  eval "$(starship init bash)"
fi

# Auto-start tmux for IaC sessions
if command -v tmux &>/dev/null && [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ]; then
  tmux attach-session -t iac 2>/dev/null || tmux new-session -s iac
fi

# Aliases for workflow script
alias iac='bash scripts/git-iac-workflow.sh'
alias iac-init='make init-project PROJECT='
alias iac-sync='make sync-upstream PROJECT='
alias iac-push='make push-project PROJECT='
alias iac-list='make list-projects'
alias iac-validate='make ci-validate PROJECT='

# Project switcher with fzf (optional)
if command -v fzf &>/dev/null; then
  iac-switch() {
    local project=$(git branch -r | grep 'origin/project/' | sed 's|origin/project/||' | fzf --height=10 --reverse --prompt="Switch to project: ")
    [ -n "$project" ] && git checkout "project/$project"
  }
fi

# Environment variables
export IAC_WORKFLOW_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
export PROJECT_CURRENT="$(git rev-parse --abbrev-ref HEAD 2>/dev/null | sed 's|project/||')"
