import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    spacing: Math.round(Theme.barHeight * 0.18)

    readonly property int activeId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property int total: Hyprland.workspaces ? Hyprland.workspaces.values.length : 1

    // audio del workspace activo (null si no suena nada)
    readonly property var audio: WsAudio.forWs(root.activeId)

    // Numero con arco de volumen alrededor: se llena en cian segun el volumen del
    // workspace, gris si esta silenciado, sin arco si no suena.
    Item {
        id: ring
        readonly property int size: Math.round(Theme.barHeight * 0.68)
        width: size
        height: size
        anchors.verticalCenter: parent.verticalCenter

        readonly property real frac: root.audio && !root.audio.muted ? Math.min(1, root.audio.pct / 100) : 0
        readonly property bool muted: root.audio ? root.audio.muted : false
        onFracChanged: arc.requestPaint()
        onMutedChanged: arc.requestPaint()

        Canvas {
            id: arc
            anchors.fill: parent
            visible: root.audio !== null
            onVisibleChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const c = width / 2, r = c - 1.5;
                ctx.lineWidth = 2;
                ctx.lineCap = "round";
                // pista
                ctx.strokeStyle = ring.muted ? Theme.muted : Theme.dim;
                ctx.beginPath();
                ctx.arc(c, c, r, 0, Math.PI * 2);
                ctx.stroke();
                // nivel, desde arriba en sentido horario
                if (ring.frac > 0) {
                    ctx.strokeStyle = Theme.cyan;
                    ctx.beginPath();
                    ctx.arc(c, c, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * ring.frac);
                    ctx.stroke();
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.activeId
            font.family: Theme.monoFamily
            font.pixelSize: root.audio ? Theme.fontPx : Theme.clockPx
            font.bold: true
            color: Theme.cyan
        }
    }
    Text {
        text: "/ " + root.total
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.monoFamily
        font.pixelSize: Theme.fontPx
        color: Theme.muted
    }
}
