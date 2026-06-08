#!/usr/bin/env bash
#
# Lanza el lockscreen en Quickshell (capa viva con blur del compositor).
# Evita instancias duplicadas: si ya hay un lock corriendo, no abre otro
# (importante porque hypridle llama esto en idle Y antes de suspender).
#
# Config del lock: ~/.config/quickshell/lock/ (shell.qml + LockContent.qml)
# Blur: layerrule sobre el namespace "quickshell-lock" en windowrules.conf
#
set -euo pipefail

if pgrep -f "qs -c lock" >/dev/null 2>&1; then
    exit 0
fi

exec qs -c lock
