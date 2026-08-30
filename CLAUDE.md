# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal Arch Linux dotfiles for a keyboard-driven **Hyprland** (Wayland) desktop. This repo is the canonical source; files are deployed to `$HOME` as symlinks via **GNU Stow**. The repo root mirrors `$HOME`, so a file at `.config/hypr/hyprland.lua` here symlinks to `~/.config/hypr/hyprland.lua`.

The repo **must** live at `~/dotfiles` — many configs and scripts hardcode `$HOME/dotfiles/Scripts/...` paths (e.g. `SCR_PATH` in `hyprland.lua`). Cloning elsewhere breaks Hyprland's `exec-once` startup scripts.

The current checked-out branch is `laptop` (a machine-specific branch); `default` is the main branch. Machine-specific divergence (e.g. `monitors.conf`) is expected.

## Deploying changes

```bash
stow .                       # create/refresh symlinks from repo into $HOME
stow . --adopt && git reset --hard   # adopt pre-existing $HOME files, then discard their content (keep repo version)
```

Editing a deployed config and editing the repo file are the same action (it's a symlink) — no copy step needed. New files require a re-`stow` to link them.

## Installation (fresh system)

`Scripts/installer/install.sh` is the orchestrator. It runs the other installers in order (terminal utils → zsh → Hyprland apps → coding tools) then runs `stow`. Individual installers in `Scripts/installer/` are also runnable standalone. All assume Arch + `pacman`/`yay`.

## Architecture / layout

- **`.config/`** — per-app configs, the bulk of the repo. Each subdir is one app (hypr, nvim, eww, rofi, kitty, lf, swaync, wlogout, fastfetch, systemd).
- **`Scripts/`** — runtime automation. `Scripts/hypr/*.sh` are invoked by Hyprland keybinds and `exec-once` (wallpaper, screenshot, volume, clipboard, etc.). `Scripts/installer/` is setup-time only.
- **`assets/`** — wallpapers, lockscreen images, icons referenced by configs.

### Hyprland (`.config/hypr/`)

Since Hyprland 0.55 the config language is **Lua**, not hyprlang — the entrypoint is `hyprland.lua` and the old `.conf` syntax is deprecated upstream. Modular config pulled in with `require()` from `hyprland.lua`: `keybindings.lua`, `windowrules.lua`, `monitors.lua`, `animations.lua`, `themes/common.lua`, `themes/theme.lua`. Each `require()` is an isolated scope, so an error in one module doesn't kill the rest.

Autostart is a `hl.on("hyprland.start", ...)` handler in `hyprland.lua` (the old `exec-once`); it wires up the desktop daemons and the `Scripts/hypr/` helpers. Animation style lives directly in `animations.lua` — there is no longer a catalogue to switch between.

`hypridle.conf` stays in hyprlang: the `hypr*` companion binaries were not migrated upstream, and it is read by the `hypridle` daemon, not by Hyprland. The lockscreen is a Quickshell live layer (`Scripts/hypr/lock.sh` → `qs -c lock`), not hyprlock — there is no `hyprlock.conf` in this repo.

Two gotchas:

- Hyprland picks its config manager **once at startup**. Creating or removing `hyprland.lua` needs a full session restart; `hyprctl reload` won't switch.
- Under Lua, `hyprctl dispatch` is a shorthand for `hl.dispatch(...)` and expects a **Lua expression** — the old `hyprctl dispatch movefocus l` form no longer parses. Query subcommands (`hyprctl clients -j`, `monitors -j`, `binds -j`, `getoption`) are unchanged.

`/usr/share/hypr/stubs/hl.meta.lua` ships the full `hl.*` API as LSP stubs; `.config/hypr/.luarc.json` points `lua_ls` at it for autocompletion.

### Neovim (`.config/nvim/`)

Lua config, Lazy.nvim plugin manager. `init.lua` sets leader then loads `config.options` → `config.lazy` → `config.keymaps` → `config.autocmds`. Plugins are organized into spec groups imported in `lua/config/lazy.lua`: `core`, `ui`, `editing`, `languages`, `code_intelligence`, `navigation`, `colorschemes`.

**Language stacks** (`lua/plugins/stacks/`: vue, angular, typescript, rust) are mutually-exclusive LSP bundles. Each stack *owns its LSP entirely* — you enable a stack by uncommenting its `{ import = "plugins.stacks.<name>" }` line in `lua/config/lazy.lua`; a commented stack means that LSP never loads. Only enable the stack(s) you need to avoid LSP conflicts (notably the Vue/ts_ls hybrid setup, which has delicate `dynamicRegistration` workarounds — see comments in `stacks/vue.lua`).

`lua/config/component-navigation.lua` is a custom framework-aware navigation system (detects Vue/Angular projects by marker files) — not a plugin.

After install on a new machine: open nvim (Lazy auto-installs), then `:Mason` to install LSP binaries (e.g. `vue-language-server`, `typescript-language-server`), then `:Copilot setup`.

### Shell (`.zshrc`)

Oh My Zsh + Powerlevel10k. Includes a custom `command_not_found_handler` that queries `pacman -F` and AUR-helper detection (yay/paru).

## Git

- **Nunca hagas commits.** Solo el usuario hace commits (y push). Puedes hacer staging, mostrar diffs y redactar mensajes propuestos, pero no ejecutes `git commit` / `git push` salvo que el usuario lo pida explícitamente.

## Conventions

- Comments and docs in this repo are in **Spanish** — match that when editing.
- `lazy-lock.json` is gitignored (see `.gitignore`), so nvim plugin versions are not pinned across machines.
- `Scripts/.env` and `Scripts/globalProtect.sh` are gitignored — don't expect them committed.
