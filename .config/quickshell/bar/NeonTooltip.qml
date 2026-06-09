import QtQuick
import QtQuick.Controls

// Tooltip con estilo de la barra (morado, redondeado, animado).
// Uso: NeonTooltip { visible: hover.hovered; text: "..." }
ToolTip {
    id: tip
    delay: 150
    // padding asimétrico: compensa el ascent de la fuente mono para centrar el texto
    leftPadding: 11
    rightPadding: 11
    topPadding: 7
    bottomPadding: 10

    background: Rectangle {
        color: Theme.islandBg
        radius: 10
        border.color: Theme.purple
        border.width: 1
    }
    contentItem: Text {
        text: tip.text
        color: Theme.textBase
        font.family: Theme.monoFamily
        font.pixelSize: Theme.fontPx
        verticalAlignment: Text.AlignVCenter
    }
    enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150; easing.type: Easing.OutCubic } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120 } }
}
