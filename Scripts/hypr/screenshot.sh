#!/usr/bin/env sh

# -----------------------------------------------------
# Configuración de Slurp (Elimina el marco negro)
# -b: color de fondo (transparente)
# -c: color de borde (transparente)
# -w: ancho de borde (0)
# -d: muestra dimensiones (opcional)
# -----------------------------------------------------
export SLURP_ARGS="-d -b 00000000 -c 00000000 -w 0"

# Restaura el shader después de tomar la captura
restore_shader() {
	if [ -n "$shader" ]; then
		hyprshade on "$shader"
	fi
}

# Guarda el shader actual y lo apaga para la captura
save_shader() {
	shader=$(hyprshade current)
	hyprshade off
	trap restore_shader EXIT
}

save_shader # Ejecutar guardado de shader

# Configuración de directorios
if [ -z "$XDG_PICTURES_DIR" ]; then
	XDG_PICTURES_DIR="$HOME/Pictures"
fi

confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
swpy_dir="${confDir}/swappy"
save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
save_file=$(date +'%d%m%y_%Hh%Mm%Ss_screenshot.png')
temp_screenshot="/tmp/screenshot.png"

mkdir -p "$save_dir"
mkdir -p "$swpy_dir"

# Crear configuración temporal para Swappy
echo -e "[Default]\nsave_dir=$save_dir\nsave_filename_format=$save_file" > "$swpy_dir/config"

function print_error {
	cat <<"EOF"
    ./screenshot.sh <action>
    ...acciones válidas...
        p  : Capturar todas las pantallas
        s  : Capturar área (arrastrar) o ventana (clic)
        sf : Capturar área (congelar pantalla)
        m  : Capturar monitor enfocado
EOF
}

# Ejecución de captura
case $1 in
p) # Todas las pantallas
	grimblast copysave screen $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
s) # Área o ventana
	grimblast copysave area $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
sf) # Área congelada (Evita que el marco negro aparezca por retraso de renderizado)
	grimblast --freeze copysave area $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
m) # Monitor actual
	grimblast copysave output $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
*) # Opción inválida
	print_error ;;
esac

# Limpieza y Notificación
if [ -f "$temp_screenshot" ]; then
    rm "$temp_screenshot"
fi

if [ -f "${save_dir}/${save_file}" ]; then
	notify-send -a "Sistema" -i "${save_dir}/${save_file}" "Captura guardada" "Imagen guardada en ${save_dir}"
fi
