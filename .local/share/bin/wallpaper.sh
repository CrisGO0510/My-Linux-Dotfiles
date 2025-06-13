#!/usr/bin/env bash

# Configuración local
scrDir="$(dirname "$(realpath "$0")")"
wallSet="$scrDir/wall.set"
wallCur="$scrDir/wall.cur"
thmbDir="$scrDir/thumbs"
dcolDir="$scrDir/dcols"
ROFI_FONT="JetBrainsMono Nerd Font"
ROFI_SCALE=10

# Ruta de wallpapers
wallpaper_dir="$HOME/dotfiles/assets"

wallList=()
wallHash=()

print_log() {
    echo "[LOG] $*"
}

set_hash() {
    basename "$1"
}

get_hashmap() {
    local paths=("$@")
    wallList=()
    wallHash=()

    for path in "${paths[@]}"; do
        if [ -d "$path" ]; then
            while IFS= read -r -d '' file; do
                wallList+=("$file")
                wallHash+=("$(basename "$file" | md5sum | awk '{print $1}')")
            done < <(find "$path" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) -print0)
        fi
    done
}

show_help() {
    cat <<EOF
Usage: $(basename "$0") --[options|flags] [parameters]

Options:
    -j, --json                List wallpapers in JSON format to STDOUT
    -S, --select              Select wallpaper using rofi
    -n, --next                Set next wallpaper
    -p, --previous            Set previous wallpaper
    -r, --random              Set random wallpaper
    -s, --set <file>          Set specified wallpaper
    -o, --output <file>       Copy current wallpaper to specified file
    -h, --help                Display this help message
EOF
    exit 0
}

Wall_Apply() {
    local selected_wall="$1"

    # Iniciar swww si no está activo
    if ! swww query &>/dev/null; then
        swww-daemon --format xrgb &
        disown
        swww query && swww restore
    fi

    # Aplicar wallpaper
    echo "[INFO] Applying wallpaper: $(readlink -f "$selected_wall")"
    swww img "$(readlink -f "$selected_wall")" \
        --transition-bezier .43,1.19,1,.4 \
        --transition-type "grow" \
        --transition-duration "0.4" \
        --transition-fps "60" \
        --invert-y &
}

Wall_Cache() {
    ln -fs "${wallList[setIndex]}" "${wallSet}"
    ln -fs "${wallList[setIndex]}" "${wallCur}"
    Wall_Apply "${wallList[setIndex]}"
}

Wall_Change() {
    curWall="$(set_hash "${wallSet}")"
    for i in "${!wallHash[@]}"; do
        if [ "${curWall}" == "${wallHash[i]}" ]; then
            if [ "${1}" == "n" ]; then
                setIndex=$(((i + 1) % ${#wallList[@]}))
            elif [ "${1}" == "p" ]; then
                setIndex=$(( (i - 1 + ${#wallList[@]}) % ${#wallList[@]} ))
            fi
            break
        fi
    done
    Wall_Cache
}

Wall_Json() {
    wallPathArray=("$wallpaper_dir")
    get_hashmap "${wallPathArray[@]}"

    wallListJson=$(printf '%s\n' "${wallList[@]}" | jq -R . | jq -s .)
    wallHashJson=$(printf '%s\n' "${wallHash[@]}" | jq -R . | jq -s .)

    jq -n --argjson wallList "$wallListJson" --argjson wallHash "$wallHashJson" --arg cacheHome "$scrDir" '
        [range(0; $wallList | length) as $i | 
            {
                path: $wallList[$i], 
                hash: $wallHash[$i], 
                basename: ($wallList[$i] | split("/") | last)
            }
        ]
    '
}

Wall_Select() {
    font_scale=${ROFI_SCALE}
    font_name=${ROFI_FONT}
    font_override="* {font: \"${font_name} ${font_scale}\";}"

    elem_border=5
    r_override="window{width:100%;} listview{columns:5;spacing:5em;} element{border-radius:${elem_border}px; orientation:vertical;} element-icon{size:28em;} element-text{padding:1em;}"

    entry=$(Wall_Json | jq -r '.[] | "\(.basename):::\(.path)"' | rofi -dmenu \
        -display-column-separator ":::" \
        -display-columns 1 \
        -theme-str "${font_override}" \
        -theme-str "${r_override}" \
        -theme selector \
        -select "$(basename "$(readlink "$wallSet")")")

    selected_wallpaper="$(awk -F ':::' '{print $2}' <<< "${entry}")"
    if [ -z "${selected_wallpaper}" ]; then
        echo "No wallpaper selected"
        exit 0
    fi
    get_hashmap "$(dirname "$selected_wallpaper")"
    for i in "${!wallList[@]}"; do
        if [ "${wallList[i]}" == "${selected_wallpaper}" ]; then
            setIndex=$i
            break
        fi
    done
    Wall_Cache
}

Wall_Hash() {
    wallPathArray=("$wallpaper_dir")
    get_hashmap "${wallPathArray[@]}"
    [ ! -e "$(readlink -f "${wallSet}")" ] && echo "Fixing link: ${wallSet}" && ln -fs "${wallList[0]}" "${wallSet}"
}

main() {
    if [ -n "${wallpaper_setter_flag}" ]; then
        case "${wallpaper_setter_flag}" in
        n)
            Wall_Hash
            Wall_Change n
            ;;
        p)
            Wall_Hash
            Wall_Change p
            ;;
        r)
            Wall_Hash
            setIndex=$((RANDOM % ${#wallList[@]}))
            Wall_Cache
            ;;
        s)
            if [ -z "${wallpaper_path}" ] || [ ! -f "${wallpaper_path}" ]; then
                echo "Wallpaper not found: ${wallpaper_path}"
                exit 1
            fi
            wallList=("${wallpaper_path}")
            wallHash=("$(basename "${wallpaper_path}" | md5sum | awk '{print $1}')")
            setIndex=0
            Wall_Cache
            ;;
        o)
            if [ -n "${wallpaper_output}" ]; then
                echo "Current wallpaper copied to: ${wallpaper_output}"
                cp -f "${wallSet}" "${wallpaper_output}"
            fi
            ;;
        select)
            Wall_Select
            ;;
        esac
    fi
}

if [ -z "${*}" ]; then
    echo "No arguments provided"
    show_help
fi

PARSED=$(getopt --options Sjnpro:s:h --longoptions select,json,next,previous,random,set:,output:,help --name "$0" -- "$@")

eval set -- "$PARSED"
while true; do
    case "$1" in
    -j | --json)
        Wall_Json
        exit 0
        ;;
    -S | --select)
        wallpaper_setter_flag=select
        shift
        ;;
    -n | --next)
        wallpaper_setter_flag=n
        shift
        ;;
    -p | --previous)
        wallpaper_setter_flag=p
        shift
        ;;
    -r | --random)
        wallpaper_setter_flag=r
        shift
        ;;
    -s | --set)
        wallpaper_setter_flag=s
        wallpaper_path="${2}"
        shift 2
        ;;
    -o | --output)
        wallpaper_setter_flag=o
        wallpaper_output="${2}"
        shift 2
        ;;
    -h | --help)
        show_help
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Invalid option: $1"
        echo "Try '$(basename "$0") --help' for more information."
        exit 1
        ;;
    esac
done

main
