# Enable Powerlevel10k instant prompt (keep this at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh-my-zsh path
export ZSH="/usr/share/oh-my-zsh"

# Use plugins if needed (currently empty)
plugins=()

# Use oh-my-zsh if installed
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# --- Command not found handler (safe + optimized) ---
function command_not_found_handler {
  local cmd="$1"
  echo "zsh: command not found: $cmd" >&2

  # Use absolute path to avoid recursion
  if command -v /usr/bin/pacman &>/dev/null; then
    local entries=("${(@f)$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$cmd")}")
    if (( ${#entries[@]} )); then
      echo "$cmd may be found in the following packages:"
      local pkg=""
      for entry in "${entries[@]}"; do
        local fields=("${(@s: :)entry}")
        if [[ "$pkg" != "${fields[2]}" ]]; then
          printf "  %s/%s %s\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
        fi
        echo "    /${fields[4]}"
        pkg="${fields[2]}"
      done
    fi
  fi
  return 127
}

# --- Detect AUR helper ---
if command -v yay &>/dev/null; then
  aurhelper="yay"
elif command -v paru &>/dev/null; then
  aurhelper="paru"
else
  aurhelper=""
fi

# --- AUR/package installer helper ---
function in {
  local -a arch=() aur=()
  for pkg in "$@"; do
    if pacman -Si "$pkg" &>/dev/null; then
      arch+=("$pkg")
    else
      aur+=("$pkg")
    fi
  done

  (( ${#arch[@]} )) && sudo pacman -S "${arch[@]}"
  if [[ -n "$aurhelper" && ${#aur[@]} -gt 0 ]]; then
    "$aurhelper" -S "${aur[@]}"
  fi
}

# --- Aliases ---
alias c='clear'
alias ls='eza -1 --icons=auto'
alias l='eza -lh --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'
alias mkdir='/usr/bin/mkdir -p'

# Pacman/AUR helpers
alias un='$aurhelper -Rns'
alias up='$aurhelper -Syu'
alias pl='$aurhelper -Qs'
alias pa='$aurhelper -Ss'
alias pc='$aurhelper -Sc'
alias po='$aurhelper -Qtdq | $aurhelper -Rns -'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# --- Prompt config ---
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# --- Nice visual touch ---
if command -v pokemon-colorscripts &>/dev/null; then
  pokemon-colorscripts --no-title -r 3,4
fi

# --- Themes ---
[[ -f ~/.powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/.powerlevel10k/powerlevel10k.zsh-theme

# --- Paths and Env ---
export PATH="$PATH:$HOME/.spicetify"

# Direnv
eval "$(direnv hook zsh)"

# Angular CLI autocompletion
command -v ng &>/dev/null && source <(ng completion script)

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Node
export NVM_DIR="$HOME/.config/nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
