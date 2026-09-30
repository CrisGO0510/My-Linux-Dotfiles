import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

// Popup de audio (hover sobre el icono de volumen): volumen global arriba y debajo una
// fila por ventana que suena, agrupadas por workspace como en el menu rofi (mod+O).
// Solo lectura: se ajusta con las teclas de volumen, mod + teclas o el menu.
// Mismo aspecto y anclaje que NeonTooltipPopup.
PopupWindow {
    id: root
    property Item anchorItem

    readonly property int gap: 6
    readonly property int pad: 11
    readonly property int activeWs: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int masterPct: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool masterMuted: sink && sink.audio ? sink.audio.muted : false

    implicitWidth: body.implicitWidth + pad * 2
    implicitHeight: body.implicitHeight + pad * 2 + gap
    color: "transparent"

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    onVisibleChanged: bubble.opacity = visible ? 1 : 0

    function volIcon(p, m) {
        if (m || p === 0) return "󰝟";
        if (p < 34) return "󰕿";
        if (p < 67) return "󰖀";
        return "󰕾";
    }

    // Una fila: etiqueta · conector · icono · titulo + barra · porcentaje
    component AudioRow: Row {
        id: row
        property string label
        property string conn
        property string title
        property int pct
        property bool muted
        property bool cur: false
        property bool master: false
        readonly property color tone: muted ? Theme.muted : cur ? Theme.cyan : Theme.textBase
        spacing: 8

        Text {
            width: Theme.fontPx * 4.2
            text: row.label
            color: row.label === "?" ? Theme.hot : row.tone
            font.family: Theme.monoFamily
            font.pixelSize: Theme.fontPx
            font.bold: row.cur || row.master
        }
        Text {
            width: Theme.fontPx * 0.7
            text: row.conn
            color: Theme.muted
            font.family: Theme.monoFamily
            font.pixelSize: Theme.fontPx
        }
        Text {
            text: root.volIcon(row.pct, row.muted)
            color: row.tone
            font.family: Theme.monoFamily
            font.pixelSize: Theme.fontPx
        }
        Column {
            spacing: 3
            anchors.verticalCenter: parent.verticalCenter
            Text {
                width: 260
                elide: Text.ElideRight
                text: row.title
                color: row.muted || row.master ? Theme.muted : Theme.clockText
                font.family: Theme.monoFamily
                font.pixelSize: Theme.fontPx - 1
            }
            Rectangle {
                width: 260; height: 3; radius: 2
                color: Theme.dim
                Rectangle {
                    width: parent.width * (row.muted ? 0 : Math.min(1, row.pct / 100))
                    height: parent.height; radius: 2
                    color: row.cur || row.master ? Theme.cyan : Theme.purple
                }
            }
        }
        Text {
            width: Theme.fontPx * 3
            horizontalAlignment: Text.AlignRight
            text: row.muted ? "mudo" : row.pct + "%"
            color: row.tone
            font.family: Theme.monoFamily
            font.pixelSize: Theme.fontPx
        }
    }

    Rectangle {
        id: bubble
        anchors.fill: parent
        anchors.topMargin: root.gap
        color: Theme.islandBg
        radius: 10
        border.color: Theme.purple
        border.width: 1
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

        Column {
            id: body
            x: root.pad
            y: root.pad
            spacing: 5

            AudioRow {
                master: true
                label: "Master"
                title: root.sink ? (root.sink.nickname || root.sink.description) : "sin salida"
                pct: root.masterPct
                muted: root.masterMuted
            }

            Rectangle {
                width: parent.width; height: 1
                color: Theme.dim
            }

            Text {
                visible: WsAudio.rows.length === 0
                text: "ninguna ventana suena"
                color: Theme.muted
                font.family: Theme.monoFamily
                font.pixelSize: Theme.fontPx
            }

            Repeater {
                model: WsAudio.rows
                AudioRow {
                    required property var modelData
                    label: modelData.label
                    conn: modelData.conn
                    title: modelData.title
                    pct: modelData.pct
                    muted: modelData.muted
                    cur: modelData.ws === root.activeWs
                }
            }
        }
    }
}
