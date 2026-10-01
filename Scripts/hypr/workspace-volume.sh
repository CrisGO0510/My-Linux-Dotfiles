#!/usr/bin/env bash
# Volumen por workspace: empareja cada stream de audio con su ventana de Hyprland y la
# ventana con su workspace, para ajustar solo lo que suena en un escritorio.
#
# Uso:
#   workspace-volume.sh up [paso]     # sube el workspace activo (def. 5 %)
#   workspace-volume.sh down [paso]   # baja el workspace activo
#   workspace-volume.sh mute          # silencia / activa el workspace activo
#   workspace-volume.sh menu          # menú rofi con los workspaces que suenan
#   workspace-volume.sh list          # volcado TSV (depuración)
#
# Emparejamiento (el mismo que usa la barra, WsAudio.qml):
#   Firefox comparte PID entre ventanas, así que se compara el título: `media.name` del
#   stream contra el título de la ventana, ambos normalizados (sin " — Firefox…" ni el
#   contador "(8) " de Teams/Meet/YouTube). Si no hay título que case, se prueba por PID
#   cuando ese PID tiene una sola ventana. Último intento: `application.name` contra la
#   class de la ventana, si es única (Spotify: sin PID en el nodo y el título es la
#   canción). Si nada casa se usa la última ventana conocida del stream (memoria en
#   $XDG_RUNTIME_DIR/wsvol-memo.tsv, compartida con la barra): una pestaña de Firefox
#   en segundo plano sigue sonando pero ya no es el título de su ventana. Lo que ni así
#   casa queda "sin ubicar" (?).
#
# Se usa pw-dump y no `pactl -f json`: pactl devuelve (null) con títulos no ASCII (ñ, tildes).

shopt -s extglob
scrDir=$(dirname "$(realpath "$0")")

memo=${XDG_RUNTIME_DIR:-/tmp}/wsvol-memo.tsv

# Lista de streams: id \t ws \t volumen(0-1) \t mudo(0/1) \t título   (ws vacío = sin ubicar)
# De paso actualiza la memoria (serial del stream \t address de la ventana, sin "0x").
list_streams() {
    local clients mem
    clients=$(hyprctl clients -j) || return 1
    mem=$(jq -Rn '[inputs | split("\t") | select(length == 2) | {(.[0]): .[1]}] | add // {}' "$memo" 2>/dev/null) || mem='{}'
    pw-dump 2>/dev/null | jq -r --argjson cl "$clients" --argjson mem "$mem" '
        def norm: sub(" [—–-] (Mozilla )?Firefox.*$"; "") | sub("^\\(\\d+\\)\\s*"; "") | gsub("^\\s+|\\s+$"; "");
        .[]
        | select(.type == "PipeWire:Interface:Node" and .info.props["media.class"] == "Stream/Output/Audio")
        | .info.props as $p
        | ($p["media.name"] // "" | if . == "(null)" then "" else . end) as $mn
        | ($mn | norm) as $key
        | ([$cl[] | select($key != "" and (.title | norm) == $key)] | first) as $byTitle
        | ([$cl[] | select((.pid | tostring) == ($p["application.process.id"] // ""))]
            | if length == 1 then .[0] else null end) as $byPid
        | ([$cl[] | select(($p["application.name"] // "" | ascii_downcase) as $an
                             | $an != "" and (.class | ascii_downcase) == $an)]
            | if length == 1 then .[0] else null end) as $byClass
        | ($p["object.serial"] // .id | tostring) as $serial
        | ($byTitle // $byPid // $byClass) as $direct
        | ($direct // ([$cl[] | select((.address | ltrimstr("0x")) == $mem[$serial])] | first)) as $w
        | (.info.params.Props // [{}] | map(select(.channelVolumes)) | first // {}) as $pr
        | [ $serial,
            ($direct.address // "" | ltrimstr("0x")),
            .id,
            ($w.workspace.id // ""),
            # channelVolumes es lineal; wpctl y pavucontrol muestran la raíz cúbica
            (($pr.channelVolumes // [1]) | max | pow(.; 1/3) * 100 | round / 100),
            (if $pr.mute then 1 else 0 end),
            (if $mn == "" then ($p["application.name"] // "audio") else $mn end)
          ] | @tsv' |
    # las dos primeras columnas son para la memoria: se conserva lo que ya se sabía de
    # los streams vivos que ahora no casan y se poda lo de streams que ya no existen
    awk -F'\t' -v memo="$memo" '
        BEGIN { OFS = FS; while ((getline l < memo) > 0) { split(l, f, "\t"); old[f[1]] = f[2] } }
        { m[$1] = $2 != "" ? $2 : old[$1]; print $3, $4, $5, $6, $7 }
        END {
            tmp = memo ".tmp"; printf "" > tmp
            for (k in m) if (m[k] != "") print k, m[k] > tmp
            close(tmp); system("mv -f \"" tmp "\" \"" memo "\"")
        }'
}

# Workspace visible en el monitor enfocado (el especial gana si está abierto)
active_ws() {
    hyprctl monitors -j | jq -r '.[] | select(.focused)
        | if .specialWorkspace.id != 0 then .specialWorkspace.id else .activeWorkspace.id end'
}

# Aviso a la barra: osd <ws> <pct> <estado: on|mute|none>. Si la barra no corre, se ignora.
# Los workspaces especiales (id negativo) van como "esp": un "-98" lo leería qs como opción.
osd() {
    local ws=$1
    [[ $ws =~ ^[0-9]+$ ]] || ws=esp
    qs -c bar ipc call wsvol osd "$ws" "$2" "$3" >/dev/null 2>&1 || true
}

# Resume un grupo de líneas TSV: "pct mudo" (pct = máximo entre los no silenciados)
summary() {
    awk -F'\t' '{ n++; if ($4 == 0) { live++; v = int($3 * 100 + 0.5); if (v > max) max = v } }
        END { if (!n) print "-1 0"; else if (!live) print "0 1"; else print max+0, 0 }'
}

ws_label() {
    case "$1" in
        "") echo " ?" ;;
        -*) echo "Hidden" ;;
        *) echo "WS $1" ;;
    esac
}

vol_icon() {
    if [ "$2" = 1 ] || [ "$1" -eq 0 ]; then echo "󰝟"
    elif [ "$1" -lt 34 ]; then echo "󰕿"
    elif [ "$1" -lt 67 ]; then echo "󰖀"
    else echo "󰕾"; fi
}

# Aplica una acción de wpctl a los ids recibidos
apply() {
    local action=$1 step=$2 id
    shift 2
    for id in "$@"; do
        case $action in
            up)     wpctl set-mute "$id" 0; wpctl set-volume -l 1.0 "$id" "${step}%+" ;;
            down)   wpctl set-volume "$id" "${step}%-" ;;
            mute)   wpctl set-mute "$id" 1 ;;
            unmute) wpctl set-mute "$id" 0 ;;
        esac
    done 2>/dev/null
}

ws_ids()   { awk -F'\t' -v ws="$1" '$2 == ws { print $1 }'; }
live_any() { awk -F'\t' -v ws="$1" '$2 == ws && $4 == 0 { f = 1 } END { exit !f }'; }

# up / down / mute sobre el workspace activo
adjust_active() {
    local action=$1 step=${2:-5} ws streams ids
    ws=$(active_ws) || exit 1
    streams=$(list_streams) || exit 1
    mapfile -t ids < <(ws_ids "$ws" <<<"$streams")

    if [ ${#ids[@]} -eq 0 ]; then
        osd "$ws" 0 none
        exit 0
    fi

    if [ "$action" = mute ]; then
        live_any "$ws" <<<"$streams" && action=mute || action=unmute
    fi
    apply "$action" "$step" "${ids[@]}"

    read -r pct muted < <(list_streams | awk -F'\t' -v ws="$ws" '$2 == ws' | summary)
    osd "$ws" "$pct" "$([ "$muted" = 1 ] && echo mute || echo on)"
}

# ── menú rofi ────────────────────────────────────────────────────────────────
rofi_setup() {
    source "$scrDir/config.sh"
    roconf="${confDir}/rofi/config.rasi"
    [[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
    r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
    local wind_border=$((hypr_border * 3 / 2))
    local elem_border=$([ "$hypr_border" -eq 0 ] && echo "5" || echo "$hypr_border")
    r_override="window{location:center;anchor:center;border:${hypr_width}px;border-radius:${wind_border}px;} element{border-radius:${elem_border}px;}"
    # el menú de volumen no usa el panel de wallpaper del config: lista a lo ancho,
    # alto según las filas y la ayuda de teclas visible abajo
    r_menu="window{width:58em;} mainbox{orientation:vertical;children:[listbox,message];padding:0 0 1.2em 0;} listbox{children:[listview];padding:1.5em 1.5em 0.5em 1.5em;} listview{spacing:0.5em;} message{background-color:transparent;} textbox{horizontal-align:0.5;text-color:@main-fg;background-color:transparent;}"
}

vol_bar() {  # deslizador de 20 celdas en markup pango; atenuado entero si está en mudo
    local n=$(( ($1 + 2) / 5 )) i on="" off=""
    for ((i = 0; i < 20; i++)); do
        ((i < n)) && on+="━" || off+="─"
    done
    if [ "$2" = 1 ]; then
        echo "<span alpha='35%'>$on$off</span>"
    else
        echo "$on<span alpha='30%'>$off</span>"
    fi
}

# título para el menú: sin el contador "(8) ", recortado y escapado para pango
menu_title() {
    local t=${1#\(+([0-9])\) }
    ((${#t} > 42)) && t="${t:0:41}…"
    t=${t//&/&amp;}; t=${t//</&lt;}; t=${t//>/&gt;}
    echo "$t"
}

# Menú: rofi en modo script, así la ventana no se cierra al ajustar. rofi llama a este
# mismo script (`rofi-mode`) en cada tecla con ROFI_RETV (1 = Enter, 10+ = teclas
# custom) y ROFI_INFO (qué fila); el script aplica la acción y devuelve la lista nueva,
# que rofi redibuja en la misma fila. Solo Esc cierra.
#   j/k se mueven, h/l (o ←/→) bajan/suben 5 %, H/L 20 %, q o Esc cierran, Enter silencia/activa, F ("focus") deja solo ese workspace.
#   La primera fila es el volumen global (Master); F no hace nada sobre ella.
#   r deja todas las ventanas al 100 % y sin silencio; el Master queda como está.
#   Si un workspace tiene varias ventanas sonando, sale una fila por ventana agrupadas
#   con ┌ ├ └ (sin fila propia del workspace); F deja sonando solo esa ventana.
# Las flechas se quitan del cursor de texto (queda Ctrl+B/F) para poder usarlas aquí.
menu() {
    rofi_setup
    # el config fija el alto de la ventana: se calcula con las filas de ahora, más una
    # por el master y por si aparece "Quitar todos los silencios". Un workspace con varias
# ventanas sonando ocupa una fila por ventana.
    local rows
    rows=$(list_streams | awk -F'\t' '{ n[$2]++ } END { for (w in n) r += n[w]; print r + 0 }')
    # + master + la fila de silencios (o "ningún workspace suena")
    rows=$(( rows + 2 )); ((rows > 8)) && rows=8
    local r_height="window{height:$(( rows * 5 + 7 ))em;} listview{lines:$rows;}"

    rofi -show wsvol -modi "wsvol:$(realpath "$0") rofi-mode" \
        -theme-str "${r_scale}" -theme-str "${r_override}" \
        -theme-str "${r_menu}" -theme-str "${r_height}" -config "${roconf}" \
        -kb-move-char-back "Control+b" -kb-move-char-forward "Control+f" \
        -kb-custom-1 "h,Left" -kb-custom-2 "l,Right" -kb-custom-3 "f" \
        -kb-custom-4 "H,Shift+H,Shift+[43]" -kb-custom-5 "L,Shift+L,Shift+[46]" -kb-custom-6 "r" \
        -kb-row-up "k,Up,Control+p" -kb-row-down "j,Down,Control+n" \
        -kb-cancel "Escape,q,Control+g,Control+bracketleft"
}

# Una llamada de rofi: aplica la acción pendiente y escribe las filas
rofi_mode() {
    local streams g ids others pct muted titles
    local key=${ROFI_INFO#ws:}

    streams=$(list_streams) || exit 1
    # r: todas las ventanas al 100 % y sin silencio, desde cualquier fila; el master no se toca
    if [ "${ROFI_RETV:-0}" = 15 ]; then
        while read -r id; do
            wpctl set-mute "$id" 0; wpctl set-volume "$id" 1.0
        done < <(cut -f1 <<<"$streams") 2>/dev/null
    elif [[ $ROFI_INFO == ws:* ]]; then
        mapfile -t ids < <(ws_ids "$key" <<<"$streams")
        case ${ROFI_RETV:-0} in
            1)  live_any "$key" <<<"$streams" && apply mute 0 "${ids[@]}" || apply unmute 0 "${ids[@]}" ;;
            10) apply down 5 "${ids[@]}" ;;
            11) apply up 5 "${ids[@]}" ;;
            13) apply down 20 "${ids[@]}" ;;
            14) apply up 20 "${ids[@]}" ;;
            12) mapfile -t others < <(awk -F'\t' -v ws="$key" '$2 != ws { print $1 }' <<<"$streams")
                apply unmute 0 "${ids[@]}"; apply mute 0 "${others[@]}" ;;
        esac
    elif [[ $ROFI_INFO == id:* ]]; then
        local id=${ROFI_INFO#id:}
        case ${ROFI_RETV:-0} in
            1)  wpctl set-mute "$id" toggle ;;
            10) apply down 5 "$id" ;;
            11) apply up 5 "$id" ;;
            13) apply down 20 "$id" ;;
            14) apply up 20 "$id" ;;
            12) mapfile -t others < <(awk -F'\t' -v id="$id" '$1 != id { print $1 }' <<<"$streams")
                apply unmute 0 "$id"; apply mute 0 "${others[@]}" ;;
        esac
    elif [ "$ROFI_INFO" = master ]; then
        case ${ROFI_RETV:-0} in
            1)  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
            10) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
            11) wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
            13) wpctl set-volume @DEFAULT_AUDIO_SINK@ 20%- ;;
            14) wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 20%+ ;;
        esac
    elif [ "$ROFI_INFO" = all ] && [ "${ROFI_RETV:-0}" = 1 ]; then
        mapfile -t ids < <(cut -f1 <<<"$streams")
        apply unmute 0 "${ids[@]}"
    fi
    [ "${ROFI_RETV:-0}" = 0 ] || streams=$(list_streams)

    printf '\0prompt\x1fVolumen por workspace\n'
    printf '\0markup-rows\x1ftrue\n\0no-custom\x1ftrue\n\0use-hot-keys\x1ftrue\n\0keep-selection\x1ftrue\n'
    printf '\0message\x1f%s\n' "j k  moverse   ·   h l  ±5 %   ·   H L  ±20 %   ·   Enter  silenciar/activar   ·   F  focus   ·   r  reset   ·   q  salir"

    # volumen global (la salida por defecto), siempre arriba
    local mv
    mv=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    pct=$(awk '{ printf "%d", $2 * 100 + 0.5 }' <<<"$mv")
    [[ $mv == *MUTED* ]] && muted=1 || muted=0
    printf '<b>%-6s</b>   %s  %s  %4s   %s\0info\x1fmaster\n' "Master" "$(vol_icon "$pct" "$muted")" \
        "$(vol_bar "$pct" "$muted")" "$([ "$muted" = 1 ] && echo mudo || echo "$pct%")" \
        "<span alpha='60%'>$(menu_title "$(wpctl inspect @DEFAULT_AUDIO_SINK@ | sed -n 's/.*node.nick = "\(.*\)"/\1/p')")</span>"

    if [ -z "$streams" ]; then
        printf '%s\0info\x1fnone\n' "<span alpha='70%'>Ningún workspace está sonando</span>"
        return
    fi

    # workspaces numéricos en orden, luego especiales, luego sin ubicar
    local n id ws vol mu title v
    while IFS= read -r g; do
        n=$(awk -F'\t' -v ws="$g" '$2 == ws' <<<"$streams" | wc -l)

        # una sola ventana: la fila del workspace es la de la ventana
        if [ "$n" -eq 1 ]; then
            read -r pct muted < <(awk -F'\t' -v ws="$g" '$2 == ws' <<<"$streams" | summary)
            titles=$(awk -F'\t' -v ws="$g" '$2 == ws { print $5 }' <<<"$streams")
            printf '<b>%-6s</b>   %s  %s  %4s   %s\0info\x1fws:%s\n' "$(ws_label "$g")" "$(vol_icon "$pct" "$muted")" \
                "$(vol_bar "$pct" "$muted")" "$([ "$muted" = 1 ] && echo mudo || echo "$pct%")" \
                "$(menu_title "$titles")" "$g"
            continue
        fi

        # varias ventanas: una fila por ventana, que se ajusta sola. El nombre del
        # workspace va solo en la primera y un conector las agrupa (┌ ├ └); no hay fila
        # propia del workspace para que j/k no se detengan en ella.
        local i=0 label conn
        while IFS=$'\t' read -r id ws vol mu title; do
            ((i++))
            label=""; ((i == 1)) && label=$(ws_label "$g")
            if ((i == 1)); then conn="┌"; elif ((i == n)); then conn="└"; else conn="├"; fi
            v=$(awk -v x="$vol" 'BEGIN { printf "%d", x * 100 + 0.5 }')
            printf '<b>%-6s</b> <span alpha="50%%">%s</span> %s  %s  %4s   %s\0info\x1fid:%s\n' "$label" "$conn" \
                "$(vol_icon "$v" "$mu")" "$(vol_bar "$v" "$mu")" \
                "$([ "$mu" = 1 ] && echo mudo || echo "$v%")" "$(menu_title "$title")" "$id"
        done < <(awk -F'\t' -v ws="$g" '$2 == ws' <<<"$streams")
    done < <(cut -f2 <<<"$streams" | sort -u | sort -n -k1,1 |
        awk '$0 == "" { u = 1; next } { print } END { if (u) print "" }')

    # deshacer "focus" / silencios: solo si hay algo en mudo
    awk -F'\t' '$4 == 1 { f = 1 } END { exit !f }' <<<"$streams" &&
        printf '%s\0info\x1fall\n' "<span alpha='70%'>󰕾  Quitar todos los silencios</span>"
}

case $1 in
    up | down | mute) adjust_active "$1" "$2" ;;
    menu) menu ;;
    rofi-mode) rofi_mode ;;
    list) list_streams ;;
    *) sed -n '5,10p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
