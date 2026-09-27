# ==============================================================================
# Variables de entorno — zsh lee este archivo en TODA invocacion, incluida la
# shell de login con la que greetd arranca Hyprland, asi que las heredan
# tambien las apps graficas. Conviene mantenerlo barato: sin comandos externos.
#
# Sirve para sacar de $HOME las carpetas de herramientas que no respetan XDG
# por su cuenta. Config -> .config, datos -> .local/share, cache -> .cache.
# ==============================================================================

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# --- Toolchains de desarrollo ---
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export GOPATH="$XDG_DATA_HOME/go"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export ARDUINO_DIRECTORIES_DATA="$XDG_DATA_HOME/arduino15"

# --- Herramientas ---
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export AZURE_CONFIG_DIR="$XDG_CONFIG_HOME/azure"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export SCREENDIR="$XDG_STATE_HOME/screen"

# --- zsh: historial y cache de completado fuera de ~ ---
HISTFILE="$XDG_STATE_HOME/zsh/history"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${HOST}-${ZSH_VERSION}"
[[ -d ${HISTFILE:h} ]]      || mkdir -p ${HISTFILE:h}
[[ -d ${ZSH_COMPDUMP:h} ]]  || mkdir -p ${ZSH_COMPDUMP:h}
