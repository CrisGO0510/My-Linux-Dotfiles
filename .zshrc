# Enable Powerlevel10k instant prompt (keep this at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh path (corrected)
export ZSH="$HOME/.oh-my-zsh"

# --- Prompt config ---
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable common plugins
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-256color
)

# Load Oh My Zsh
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Command not found handler ---
function command_not_found_handler {
  local cmd="$1"
  echo "zsh: command not found: $cmd" >&2
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

# --- Silenciar advertencia de instant prompt ---
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# --- Nice visual touch ---
if command -v pokemon-colorscripts &>/dev/null; then
  pokemon-colorscripts --no-title -r 3,4
fi

# --- Paths and Env ---
export PATH="$PATH:$HOME/.spicetify"
export LD_LIBRARY_PATH=/opt/oracle/instantclient_23_8:$LD_LIBRARY_PATH

# Direnv
eval "$(direnv hook zsh)"

# --- Angular CLI autocompletion (safe) ---
if command -v ng &>/dev/null; then
  source <(ng completion script)
fi

# --- Rust (safe) ---
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env" || echo "Error loading Rust environment"
fi

export ORACLE_HOME=/opt/oracle/instantclient_23_9
export LD_LIBRARY_PATH=/opt/oracle/instantclient_23_9:$LD_LIBRARY_PATH
export PATH=/opt/oracle/instantclient_23_9:$PATH
