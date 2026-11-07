#!/usr/bin/env bash
# Status line de Claude Code: modelo │ esfuerzo │ ctx │ precio │ ponytail.
# Recibe por stdin el JSON documentado en https://code.claude.com/docs/en/statusline

cfg="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
input=$(cat)

IFS=$'\t' read -r model effort pct cost vim project_dir < <(
    jq -r '[
        (.model.display_name // .model.id // "?"),
        (.effort.level // "-"),
        ((.context_window.used_percentage // 0) | floor),
        (.cost.total_cost_usd // 0),
        (.vim.mode // "-"),
        (.workspace.project_dir // .cwd // "")
    ] | @tsv' <<<"$input"
)

[ "$vim" = "-" ] && vim=""
if [ -n "${CMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
    (
        [ "$(tmux display -p -t "$TMUX_PANE" '#{@vim}')" = "$vim" ] && exit
        if [ -n "$vim" ]; then tmux set -t "$TMUX_PANE" @vim "$vim"; else tmux set -u -t "$TMUX_PANE" @vim; fi
        "$CMUX_BIN" _refresh
    ) >/dev/null 2>&1 </dev/null &
fi

dim=$'\033[2m'
reset=$'\033[0m'
sep=" ${dim}│${reset} "
color() { printf '\033[38;5;%sm' "$1"; }

case "$effort" in
    low) ecol=245 ;;
    medium) ecol=108 ;;
    high) ecol=110 ;;
    xhigh) ecol=173 ;;
    max) ecol=167 ;;
    *) ecol=240 ;;
esac

width=10
filled=$(( (pct * width + 50) / 100 ))
(( filled > width )) && filled=$width
if (( pct >= 80 )); then bcol=167; elif (( pct >= 50 )); then bcol=179; else bcol=108; fi
bar=$(printf '%*s' "$filled" '' | sed 's/ /█/g')$(printf '%*s' $((width - filled)) '' | sed 's/ /░/g')

# El flag compartido queda obsoleto cuando el plugin está desactivado, así que
# primero se consulta enabledPlugins y luego el modo por proyecto que escribe ponytail.
ponytail_mode=""
if jq -e '.enabledPlugins["ponytail@ponytail"] == true' "$cfg/settings.json" >/dev/null 2>&1; then
    flag="$cfg/.ponytail-active"
    if [ -n "$project_dir" ]; then
        hash=$(printf '%s' "$(realpath -ms "$project_dir")" | sha256sum | cut -d' ' -f1)
        [ -f "$cfg/ponytail-modes/$hash" ] && flag="$cfg/ponytail-modes/$hash"
    fi
    [ -f "$flag" ] && ponytail_mode=$(head -n1 "$flag" | tr -d '[:space:]')
fi

if [ -z "$ponytail_mode" ]; then
    ponytail="${dim}ponytail off${reset}"
else
    pcol=108
    [ "$ponytail_mode" = "ultra" ] && pcol=173
    ponytail="$(color "$pcol")ponytail:${ponytail_mode}${reset}"
fi

printf '%s%s%s' "$(color 75)" "$model" "$reset"
printf '%s%s%s%s' "$sep" "$(color "$ecol")" "$effort" "$reset"
printf '%sctx %s%s%s %d%%' "$sep" "$(color "$bcol")" "$bar" "$reset" "$pct"
printf '%s$%.2f' "$sep" "$cost"
printf '%s%s\n' "$sep" "$ponytail"
