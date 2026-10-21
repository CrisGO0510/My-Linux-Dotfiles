#!/usr/bin/env bash
# Pruebas de avisos: vault temporal, envío en seco y az_* simulados.

# shellcheck source=../.local/bin/avisos disable=SC1091
source "$(dirname "$(realpath "$0")")/../.local/bin/avisos"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
export AVISOS_SECO=1 AVISOS_HOST=pc AZURE_ORG=https://dev.azure.com/Org

pasadas=0
falladas=0

setup() {
    rm -rf "${TMP:?}"/*
    export AVISOS_VAULT=$TMP/vault XDG_STATE_HOME=$TMP/state
    mkdir -p "$AVISOS_VAULT"
    BUGS=""
    RUN=""
}

az_bugs() { printf '%s' "$BUGS"; }
az_run() { printf '%s' "$RUN"; }

verificar() {
    local nombre=$1 esperado=$2 real=$3
    if [[ $real == "$esperado" ]]; then
        pasadas=$((pasadas + 1))
    else
        falladas=$((falladas + 1))
        printf 'FALLO %s\n  esperado: %q\n  real:     %q\n' "$nombre" "$esperado" "$real"
    fi
}

aviso() { printf '%s/.avisos/%s.aviso' "$AVISOS_VAULT" "$1"; }

test_crear_pausar_reanudar_mover_borrar() {
    # Arrange
    setup
    # Act
    cmd_crear tarea obsidian
    local creado estado1 estado2 estado3 maq
    creado=$(leer "$(aviso tarea)" maquina)
    cmd_pausar tarea
    estado1=$(leer "$(aviso tarea)" estado)
    cmd_reanudar tarea
    estado2=$(leer "$(aviso tarea)" estado)
    cmd_mover tarea laptop
    maq=$(leer "$(aviso tarea)" maquina)
    cmd_borrar tarea
    estado3=$([[ -e $(aviso tarea) ]] && echo existe || echo borrado)
    # Assert
    verificar crear-maquina pc "$creado"
    verificar pausar pausado "$estado1"
    verificar reanudar activo "$estado2"
    verificar mover laptop "$maq"
    verificar borrar borrado "$estado3"
}

test_evento_usa_todas() {
    # Arrange
    setup
    # Act
    cmd_crear pomodoro evento
    # Assert
    verificar evento-todas todas "$(leer "$(aviso pomodoro)" maquina)"
}

test_nombre_invalido() {
    # Arrange
    setup
    # Act
    (set -e; cmd_crear "Mal Nombre" evento) 2> /dev/null
    local estado=$?
    # Assert
    verificar nombre-invalido-sale-1 1 "$estado"
    verificar nombre-invalido-sin-archivo 0 "$(fd -t f . "$AVISOS_VAULT" 2> /dev/null | wc -l)"
}

test_errores_de_crear() {
    # Arrange
    setup
    cmd_crear uno evento
    # Act
    (set -e; cmd_crear uno evento) 2> /dev/null
    local duplicado=$?
    (set -e; cmd_crear dos inexistente) 2> /dev/null
    local tipo=$?
    (set -e; cmd_crear tres pipeline proyecto=P) 2> /dev/null
    local falta=$?
    (set -e; cmd_crear cuatro pid pid=999999) 2> /dev/null
    local sinproc=$?
    # Assert
    verificar duplicado 1 "$duplicado"
    verificar tipo-inexistente 1 "$tipo"
    verificar param-faltante 1 "$falta"
    verificar pid-inexistente 1 "$sinproc"
}

test_valor_peligroso_no_se_ejecuta() {
    # Arrange
    setup
    local marca=$TMP/pwned
    # Act
    cmd_crear sec azure-bugs "proyecto=\$(touch $marca) 'x\" \`touch $marca\`"
    local valor
    valor=$(leer "$(aviso sec)" proyecto)
    # Assert
    verificar no-ejecuta "no" "$([[ -e $marca ]] && echo si || echo no)"
    verificar valor-intacto "\$(touch $marca) 'x\" \`touch $marca\`" "$valor"
}

test_enviar_silencioso() {
    # Arrange
    setup
    cmd_crear claude evento
    # Act
    local activo pausado inexistente
    activo=$(cmd_enviar claude "T" "M" "http://u")
    cmd_pausar claude
    pausado=$(cmd_enviar claude "T" "M")
    inexistente=$(cmd_enviar nadie "T" "M")
    # Assert
    verificar enviar-activo "ENVIADO|T|M|http://u" "$activo"
    verificar enviar-pausado "" "$pausado"
    verificar enviar-inexistente "" "$inexistente"
}

test_revisar_otra_maquina_e_intervalo() {
    # Arrange
    setup
    BUGS=$'1\tuno\n'
    cmd_crear ajeno azure-bugs proyecto=P maquina=laptop
    cmd_crear propio azure-bugs proyecto=P
    BUGS=$'1\tuno\n2\tdos\n'
    # Act
    local primera segunda
    primera=$(cmd_revisar)
    BUGS=$'1\tuno\n2\tdos\n3\ttres\n'
    segunda=$(cmd_revisar)
    # Assert
    verificar otra-maquina-ignorada "ENVIADO|🐞 Bug #2|dos|https://dev.azure.com/Org/P/_workitems/edit/2" "$primera"
    verificar intervalo-respetado "" "$segunda"
}

test_azure_bugs() {
    # Arrange
    setup
    BUGS=$'10\ta\n11\tb\n'
    # Act
    cmd_crear bugs azure-bugs "proyecto=419 - X"
    local alcrear sinnuevos conuevo
    alcrear=$(cmd_revisar)
    BUGS=$'10\ta\n11\tb\n12\tc d\n'
    rm -f "$(ruta_ultima bugs)"
    conuevo=$(cmd_revisar)
    rm -f "$(ruta_ultima bugs)"
    sinnuevos=$(cmd_revisar)
    # Assert
    verificar bugs-no-avisa-al-crear "" "$alcrear"
    verificar bugs-solo-nuevos "ENVIADO|🐞 Bug #12|c d|https://dev.azure.com/Org/419%20-%20X/_workitems/edit/12" "$conuevo"
    verificar bugs-no-repite "" "$sinnuevos"
}

test_pipeline() {
    # Arrange
    setup
    cmd_crear build pipeline proyecto=P run=7 intervalo=0
    RUN=$'inProgress\t\tDeploy'
    # Act
    local enmarcha completo existe
    enmarcha=$(cmd_revisar)
    RUN=$'completed\tsucceeded\tDeploy'
    completo=$(cmd_revisar)
    existe=$([[ -e $(aviso build) ]] && echo existe || echo borrado)
    # Assert
    verificar pipeline-en-curso "" "$enmarcha"
    verificar pipeline-completo "ENVIADO|✅ Pipeline Deploy|Run #7: succeeded|https://dev.azure.com/Org/P/_build/results?buildId=7" "$completo"
    verificar pipeline-se-borra borrado "$existe"
}

test_pipeline_fallido() {
    # Arrange
    setup
    cmd_crear build pipeline proyecto=P run=8 intervalo=0
    RUN=$'completed\tfailed\tDeploy'
    # Act
    local salida
    salida=$(cmd_revisar)
    # Assert
    verificar pipeline-fallido "ENVIADO|❌ Pipeline Deploy (failed)|Run #8: failed|https://dev.azure.com/Org/P/_build/results?buildId=8" "$salida"
}

test_pid() {
    # Arrange
    setup
    sleep 0.3 &
    local p=$!
    cmd_crear espera pid pid=$p intervalo=0
    local vivo muerto existe
    # Act
    vivo=$(cmd_revisar)
    wait "$p"
    muerto=$(cmd_revisar)
    existe=$([[ -e $(aviso espera) ]] && echo existe || echo borrado)
    # Assert
    verificar pid-vivo "" "$vivo"
    verificar pid-muerto "ENVIADO|✔ Terminó sleep|El proceso $p terminó|" "$muerto"
    verificar pid-se-borra borrado "$existe"
}

test_obsidian() {
    # Arrange
    setup
    cat > "$AVISOS_VAULT/notas.md" <<'MD'
- [ ] Pagar recibo ⏰ 2020-01-01 08:00
- [ ] Futuro ⏰ 2999-01-01 08:00
- [x] Hecho ⏰ 2020-01-01 08:00
- [ ] Sin hora
MD
    mkdir -p "$AVISOS_VAULT/.obsidian"
    echo '- [ ] Oculto ⏰ 2020-01-01 08:00' > "$AVISOS_VAULT/.obsidian/x.md"
    cmd_crear recordatorios obsidian intervalo=0
    # Act
    local primera segunda archivo
    primera=$(cmd_revisar)
    segunda=$(cmd_revisar)
    archivo=$(<"$AVISOS_VAULT/notas.md")
    # Assert
    verificar obsidian-una-vez "ENVIADO|⏰ Recordatorio|Pagar recibo|" "$primera"
    verificar obsidian-no-repite "" "$segunda"
    verificar obsidian-marca $'- [ ] Pagar recibo 🔔 2020-01-01 08:00\n- [ ] Futuro ⏰ 2999-01-01 08:00\n- [x] Hecho ⏰ 2020-01-01 08:00\n- [ ] Sin hora' "$archivo"
}

test_sesion_vigilar_soltar_lista() {
    # Arrange
    setup
    # Act
    cmd_sesion vigilar abc-123
    local marcada lista
    marcada=$([[ -e $(dir_sesiones)/abc-123 ]] && echo si || echo no)
    lista=$(cmd_sesion lista)
    cmd_sesion soltar abc-123
    local soltada
    soltada=$([[ -e $(dir_sesiones)/abc-123 ]] && echo si || echo no)
    # Assert
    verificar sesion-vigilar si "$marcada"
    verificar sesion-lista "abc-123  $(date '+%F %H:%M')" "$lista"
    verificar sesion-soltar no "$soltada"
}

test_sesion_id_por_defecto_e_invalido() {
    # Arrange
    setup
    # Act
    CLAUDE_CODE_SESSION_ID=def-456 cmd_sesion vigilar
    local marcada
    marcada=$([[ -e $(dir_sesiones)/def-456 ]] && echo si || echo no)
    (set -e; cmd_sesion vigilar "../mal") 2> /dev/null
    local invalido=$?
    (set -e; unset CLAUDE_CODE_SESSION_ID; cmd_sesion vigilar) 2> /dev/null
    local sinid=$?
    # Assert
    verificar sesion-id-por-defecto si "$marcada"
    verificar sesion-id-invalido 1 "$invalido"
    verificar sesion-sin-id 1 "$sinid"
}

HOOK_STOP='{"session_id":"abc-123","transcript_path":"/x","cwd":"/home/u/proyecto","hook_event_name":"Stop","stop_hook_active":false}'
HOOK_NOTIF='{"session_id":"abc-123","cwd":"/home/u/proyecto","hook_event_name":"Notification","message":"Claude needs your permission to use \"Bash\""}'

test_claude_hook() {
    # Arrange
    setup
    cmd_crear claude evento
    # Act
    local sinmarca stop notif sinmensaje
    sinmarca=$(cmd_claude_hook Stop <<< "$HOOK_STOP")
    cmd_sesion vigilar abc-123
    stop=$(cmd_claude_hook Stop <<< "$HOOK_STOP")
    notif=$(cmd_claude_hook Notification <<< "$HOOK_NOTIF")
    sinmensaje=$(cmd_claude_hook Notification <<< "${HOOK_NOTIF/,\"message\"*\}/\}}")
    # Assert
    verificar hook-sin-marca "" "$sinmarca"
    verificar hook-stop "ENVIADO|Claude · proyecto|Terminó|" "$stop"
    verificar hook-notification 'ENVIADO|Claude · proyecto|Claude needs your permission to use "Bash"|' "$notif"
    verificar hook-notification-sin-mensaje "ENVIADO|Claude · proyecto|Necesita tu atención|" "$sinmensaje"
}

test_claude_hook_aviso_pausado() {
    # Arrange
    setup
    cmd_crear claude evento
    cmd_sesion vigilar abc-123
    cmd_pausar claude
    # Act
    local salida
    salida=$(cmd_claude_hook Stop <<< "$HOOK_STOP")
    # Assert
    verificar hook-pausado "" "$salida"
}

test_limpia_marcas_viejas() {
    # Arrange
    setup
    cmd_sesion vigilar vieja
    cmd_sesion vigilar reciente
    touch -d '8 days ago' "$(dir_sesiones)/vieja"
    # Act
    cmd_revisar
    # Assert
    verificar limpieza-borra-vieja no "$([[ -e $(dir_sesiones)/vieja ]] && echo si || echo no)"
    verificar limpieza-conserva-reciente si "$([[ -e $(dir_sesiones)/reciente ]] && echo si || echo no)"
}

for t in $(declare -F | cut -d' ' -f3 | rg '^test_'); do
    "$t"
done

printf '\n%d pasadas, %d falladas\n' "$pasadas" "$falladas"
[[ $falladas -eq 0 ]]
