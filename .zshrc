# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

PATH_DIRS=(
  "${HOME}/bin"
  "${KREW_ROOT:-${HOME}/.krew}/bin"
  "/opt/homebrew/bin/"
  "/usr/local/bin"
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/sbin"
  "${PATH}"
)
export PATH=${"${PATH_DIRS[*]}"// /:}

### Load aliases
for filename in ~/.dotfiles/*; do
  source $filename
done

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Terraform aliases
[ -f ~/.terraform_aliases ] && source ~/.terraform_aliases
function terraform() { echo "+ terraform $@"; command terraform $@; }
# Terragrunt alises
[ -f ~/.terragrunt_aliases ] && source ~/.terragrunt_aliases
function terragrunt() { echo "+ terragrunt $@"; command terragrunt $@; }

# direnv hook
eval "$(direnv hook zsh)"

# Awesome oneliners
b64d () {
  echo "$1" | base64 -d ; echo
}

b64e () {
  echo -n "$1" | base64
}

# KSOPS
export XDG_CONFIG_HOME=$HOME/.config

# KubeSwitch
INSTALLATION_PATH=$(brew --prefix switch) && source $INSTALLATION_PATH/switch.sh

# Autocompletion
rm -f ~/.zcompdump;

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
  fi

[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# Use this setting if you want to disable marking untracked files under VCS as dirty.
# This makes repository status checks for large repositories much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
SHOW_AWS_PROMPT=false
COMPLETION_WAITING_DOTS=true

# History
HISTFILE="$HOME/.zsh_history"
HISTIGNORE="&:exit:reset:clear:zh"
setopt append_history
setopt hist_ignore_space
setopt HIST_IGNORE_DUPS
setopt sharehistory
setopt INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS

# Options
setopt autocd
autoload -U add-zsh-hook

DISABLE_AUTO_TITLE="true"

# Override auto-title when static titles are desired ($ title My new title)
title() { export TITLE_OVERRIDDEN=1; echo -en "\e]0;$*\a"}
# Turn off static titles ($ autotitle)
autotitle() { export TITLE_OVERRIDDEN=0 }; autotitle
# Condition checking if title is overridden
overridden() { [[ $TITLE_OVERRIDDEN == 1 ]]; }

# Show cwd when shell prompts for input.
precmd() {
  if overridden; then return; fi
  pwd=$(pwd) # Store full path as variable
  cwd=${pwd##*/} # Extract current working dir only
  print -Pn "\e]0;$cwd\a" # Replace with $pwd to show full path
}

# Prepend command (w/o arguments) to cwd while waiting for command to complete.
preexec() {
  if overridden; then return; fi
  printf "\033]0;%s\a" "${1%% *} | $cwd" # Omit construct from $1 to show args
}
