pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Paleta P2 — morado + cian
    readonly property color purple:   "#8b5cf6"
    readonly property color cyan:      "#22d3ee"
    readonly property color textBase:  "#b9a4ff"
    readonly property color clockText: "#c9bbff"
    readonly property color islandBg:  Qt.rgba(18/255, 16/255, 36/255, 0.85)
    readonly property color muted:     "#6b5e8f"   // texto atenuado
    readonly property color dim:       "#2a1f3d"   // fondo tenue (avatar, carátula)
    readonly property color hot:       "#ff2bd6"   // acento magenta (CPU alto)
    readonly property color alert:     "#ff5fd2"   // alerta (batería baja, DND)

    // Tamaño base: todo se deriva de barHeight => independiente de resolución
    readonly property int  barHeight: 38
    readonly property int  fontPx:    Math.round(barHeight * 0.34)   // ~13
    readonly property int  clockPx:   Math.round(barHeight * 0.40)   // ~15
    readonly property int  islandPadH: Math.round(barHeight * 0.34)
    readonly property int  islandGap:  Math.round(barHeight * 0.32)
    readonly property int  radius:     barHeight                     // pill

    // Fuente monoespaciada con nerd glyphs. Cambiar aquí si no está instalada.
    readonly property string monoFamily: "JetBrainsMono Nerd Font"
}
