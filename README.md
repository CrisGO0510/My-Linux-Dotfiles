# 🍙 Cris Dotfiles

Bienvenido a mi configuración personal para **Arch Linux**. Este repositorio gestiona un entorno gráfico completo basado en **Hyprland**, diseñado para ser estético, funcional y controlado mayormente por teclado.

## 📂 Estructura del Repositorio

| Directorio | Descripción |
| :--- | :--- |
| **`.config/`** | Configuraciones de aplicaciones (Hyprland, Nvim, Eww, Lf, Kitty, etc.). |
| **`assets/`** | Recursos gráficos (Wallpapers, iconos, imágenes para Rofi/Eww). |
| **`Scripts/`** | Scripts de automatización, utilidades del sistema e instaladores. |
| **`.zshrc`** | Configuración del shell ZSH. |
| **`.gitignore`** | Archivos excluidos del control de versiones. |

---

## 🛠️ Instalación y Despliegue

Este sistema utiliza **GNU Stow** para gestionar los enlaces simbólicos (symlinks).

### 1. Requisitos Previos
Asegúrate de tener instaladas las herramientas base:
```bash
sudo pacman -S git stow
```

### 2. Clonar el Repositorio
Descarga tus dotfiles en la carpeta de usuario (es importante que sea en `~/dotfiles` para que stow funcione correctamente con la ruta relativa):

```bash
git clone https://github.com/CrisGO0510/My-Linux-Dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Ejecutar Instaladores (Opcional)
He incluido scripts para preparar el sistema desde una instalación limpia. Estos se encuentran en `Scripts/installer/`.

```bash
# Dar permisos de ejecución
chmod +x Scripts/installer/*.sh

# Orden sugerido de ejecución:
./Scripts/installer/chaotic_aur.sh   # Configura repositorios extra
./Scripts/installer/teminal-utils.sh # Herramientas de CLI (zsh, fzf, etc.)
./Scripts/installer/hyprland-apps.sh # Entorno gráfico base
./Scripts/installer/coding-needs.sh  # Lenguajes y herramientas dev
```

### 4. Aplicar Configuraciones (Stow)
Este comando creará los enlaces simbólicos desde esta carpeta hacia tu directorio `$HOME`.

```bash
stow .
```
> **⚠️ Nota:** Si ya tienes archivos de configuración puedes hacer:

```bash
stow . --adopt
git reset --hard
```
Esto hace que se queden las configuraciones del dotfiles y se vincule sin necesidad de borrar archivo por archivo

---

## 🎨 Detalles del Entorno (Hyprland)

La configuración de Hyprland (`.config/hypr/`) es modular y personalizada:

Desde Hyprland 0.55 la configuración se escribe en **Lua** (hyprlang está deprecado).

*   **Configuración Base:** `hyprland.lua` es el punto de entrada y carga el resto con `require()`: `keybindings.lua`, `windowrules.lua`, `monitors.lua`.
*   **Animaciones:** `animations.lua`.
*   **Temas:** Colores en `themes/theme.lua` y `themes/common.lua`; reglas de ventana en `windowrules.lua`.
*   **Bloqueo:** la pantalla de bloqueo es una capa viva de Quickshell (`Scripts/hypr/lock.sh`).

Hyprland elige el gestor de configuración **una sola vez al arrancar**: si tocas `hyprland.lua`
basta con guardarlo (recarga sola), pero crearlo o quitarlo exige reiniciar la sesión.

---

## ⌨️ Herramientas Principales

### Neovim (`.config/nvim`)
Un IDE completo basado en Lua y gestionado con **Lazy.nvim**.
*   Modularizado en `lua/plugins/` (Categorías: UI, Coding, Editor).
*   Incluye LSP, Autocompletado, Treesitter y soporte para depuración.

### Quickshell — barra (`.config/quickshell/bar`)
Barra de estado en QML/Qt (reemplaza a Eww). Idéntica en todos los monitores e independiente de resolución.
*   Datos por servicios nativos reactivos (Pipewire, UPower, MPRIS, SystemTray, Hyprland) y lecturas de `/proc`/`/sys`; sin polling de scripts.
*   Incluye el **servidor de notificaciones** nativo (reemplaza a swaync): toasts en pantalla + historial en el panel de stats.
*   Se lanza con `qs -c bar`. El lockscreen vive aparte en `.config/quickshell/lock`.

### Rofi (`.config/rofi`)
Lanzador de aplicaciones y menús.
*   Incluye múltiples estilos en `styles/`.

### Lf (`.config/lf`)
Gestor de archivos de terminal.
*   Configurado con iconos y previsualización de imágenes.
*   Scripts `cleaner` y `previewer` incluidos para gestionar la vista previa.

### Scripts Personalizados (`~/Scripts`)
Scrips de uso diario ubicados en `$HOME/Scripts`:
---

## 🖼️ Atajos de Teclado Importantes

*Para ver los atajos pulse:*

*   **SUPER + /**
