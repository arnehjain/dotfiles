# ~/.zshrc — unified shell configuration
# Machine-specific config (secrets, PATH additions) goes in ~/.zshrc_local

# =============================================================================
# 1. Core Settings
# =============================================================================

# Enable colors
autoload -Uz colors && colors

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Completion system
autoload -Uz compinit
# Only check compinit cache once per day for faster startup
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Docker CLI completions (guarded)
if [[ -d "$HOME/.docker/completions" ]]; then
    fpath=($HOME/.docker/completions $fpath)
fi

# =============================================================================
# 2. Tool Initialization
# =============================================================================

# zoxide — fast directory jumping with 'z'
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# fzf — fuzzy finder shell integration
if command -v fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi

# fzf configuration — use fd for faster, .gitignore-aware listing
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# =============================================================================
# 3. Modern Tool Aliases
# =============================================================================

if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
fi

if command -v eza &>/dev/null; then
    alias ls='eza'
    alias ll='eza -la --git'
    alias la='eza -a'
    alias lt='eza --tree --level=2'
fi

# =============================================================================
# 4. Git Aliases
# =============================================================================

alias gs='git status'
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color=always"
alias gd='git diff'
alias gc='git commit'
alias gdc='git diff --cached'
alias gcm='git commit -m '
alias g=git
alias ga='git add'
alias grh='git reset HEAD'

# =============================================================================
# 5. Git Worktree Aliases & Functions
# =============================================================================

alias wtls='git worktree list'
alias wtprune='git worktree prune'

# Returns 0 if any argument is a help flag (-h, --help, -?, help, ?).
function _wt_help_requested() {
    local arg
    for arg in "$@"; do
        if [[ "$arg" == "-h" || "$arg" == "--help" || "$arg" == "-?" || "$arg" == "help" || "$arg" == "?" ]]; then
            return 0
        fi
    done
    return 1
}

function wtrm() {
    local target
    if _wt_help_requested "$@"; then
        echo "Usage: wtrm [path]   Remove worktree at path, or fzf to pick one"
        return 0
    fi
    if [[ -n "$1" ]]; then
        target="$1"
    else
        target=$(git worktree list | awk '{print $1}' | fzf)
    fi
    [[ -n "$target" ]] && git worktree remove "$target"
}

function wtadd() {
    local _path branch
    if _wt_help_requested "$@"; then
        echo "Usage:"
        echo "  wtadd <path> [branch]           Add worktree; use existing branch or create new one"
        echo "  wtadd -b <new-branch> <path> [start-point]   New branch (optionally from start-point)"
        echo ""
        echo "Examples:"
        echo "  wtadd ../my-feature             New worktree at ../my-feature, new branch 'my-feature'"
        echo "  wtadd ../issue-649 issue/649    Checkout existing branch issue/649 at ../issue-649"
        echo "  wtadd -b feature/foo ../foo     New branch feature/foo at ../foo (from current HEAD)"
        echo "  wtadd -b hotfix ../hotfix main  New branch hotfix at ../hotfix from main"
        return 0
    fi
    if [[ "$1" == "-b" ]]; then
        shift
        branch="$1"
        _path="$2"
        shift 2
        git worktree add -b "$branch" "$_path" "$@"
        return
    fi
    _path="$1"
    branch="${2:-}"
    if [[ -z "$_path" ]]; then
        echo "Usage: wtadd <path> [branch]"
        echo "       wtadd -b <new-branch> <path> [start-point]"
        return 1
    fi
    if [[ -z "$branch" ]]; then
        git worktree add "$_path"
    else
        if git show-ref -q refs/heads/"$branch" 2>/dev/null; then
            git worktree add "$_path" "$branch"
        else
            git worktree add -b "$branch" "$_path"
        fi
    fi
}

function wtcd() {
    if _wt_help_requested "$@"; then
        echo "Usage: wtcd   fzf-pick a worktree and cd into it"
        return 0
    fi
    local dir
    dir=$(git worktree list | awk '{print $1}' | fzf)
    if [[ -n "$dir" ]]; then
        cd "$dir"
    fi
}

function wtpr() {
    if _wt_help_requested "$@"; then
        echo "Usage: wtpr <pr-number>   Checkout PR via gh (e.g. wtpr 123)"
        return 0
    fi
    gh pr checkout "$1"
}

# =============================================================================
# 6. Other Aliases
# =============================================================================

# tmux
alias tmxls='tmux list-session'
alias tmxas='tmux attach'
alias tmxns='tmux new -s'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# tools
alias k='kubectl'
alias sumo='sudo'

# =============================================================================
# 7. Helper Functions
# =============================================================================

# Extract archives
# Usage: x <archive-file>
function x() {
    if [[ -z "$1" ]]; then
        echo "Usage: x <archive-file>"
        return 1
    fi
    if [[ ! -f "$1" ]]; then
        echo "Error: '$1' is not a valid file"
        return 1
    fi
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz|*.txz)   tar xJf "$1" ;;
        *.tar)            tar xf  "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.gz)             gunzip  "$1" ;;
        *.zip)            unzip   "$1" ;;
        *.Z)              uncompress "$1" ;;
        *.7z)             7z x    "$1" ;;
        *.rar)            unrar x "$1" ;;
        *)                echo "Error: '$1' - unknown archive format" && return 1 ;;
    esac
}

# mkdir + cd
function take() {
    mkdir -p "$1" && cd "$1"
}

# Filter stdin: keep only valid JSON lines, then run an optional jq filter.
# Usage:
#   ... | jl                  pass through valid JSON lines
#   ... | jl '.level'         apply a jq filter
#   ... | jl -p '. | {ts}'   pretty (multi-line) output
function jl() {
    local mode='-c'
    if [[ "${1:-}" == "-p" ]]; then
        mode=''
        shift
    fi
    local filter="${1:-.}"
    shift || true
    jq -R ${mode} 'fromjson? // empty | '"$filter" "$@"
}

# Clean merged branches
function gprune() {
    set -e
    git switch main
    git pull --ff-only
    git fetch --prune
    git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -d
}

# Source a .env file, exporting all non-comment, non-empty lines
function load_env() {
    local env_file="${1:-.env}"
    if [[ ! -f "$env_file" ]]; then
        echo "Error: env file not found: $env_file"
        return 1
    fi
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        export "$line"
    done < "$env_file"
}

# =============================================================================
# 8. Environment
# =============================================================================

export EDITOR=nvim
export VISUAL=nvim
export FCEDIT=nvim

export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export PATH="$PATH:$HOME/bin:$HOME/.local/bin"

# =============================================================================
# 9. Local Config (secrets, machine-specific settings)
# =============================================================================

if [[ -f "$HOME/.zshrc_local" ]]; then
    source "$HOME/.zshrc_local"
fi
