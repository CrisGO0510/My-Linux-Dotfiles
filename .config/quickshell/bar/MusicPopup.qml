import QtQuick
import Quickshell
import Quickshell.Services.Mpris

PopupWindow {
    id: root
    property var anchorItem
    readonly property var player: Mpris.players && Mpris.players.values.length > 0
                                  ? Mpris.players.values[0] : null

    implicitWidth: 330
    implicitHeight: 132
    color: "transparent"
    grabFocus: true

    anchor.window: anchorItem ? anchorItem.QsWindow.window : null
    anchor.rect.x: anchorItem ? anchorItem.x : 0
    anchor.rect.y: Theme.barHeight + 4

    property bool entered: false
    Timer { id: closeTimer; interval: 250; onTriggered: if (!hover.hovered) root.visible = false }
    onVisibleChanged: root.entered = false

    Rectangle {
        id: panel
        anchors.fill: parent; anchors.margins: 6
        radius: 14; color: Theme.islandBg; border.color: Theme.purple; border.width: 1

        opacity: 0
        transform: Translate { id: slide; y: -10 }
        states: State { name: "open"; when: root.visible
            PropertyChanges { target: panel; opacity: 1 }
            PropertyChanges { target: slide; y: 0 } }
        transitions: Transition {
            NumberAnimation { target: panel; property: "opacity"; duration: 150; easing.type: Easing.OutCubic }
            NumberAnimation { target: slide; property: "y"; duration: 150; easing.type: Easing.OutCubic } }

        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered) { root.entered = true; closeTimer.stop(); }
                else if (root.entered) closeTimer.restart();
            }
        }

        Row {
            anchors.fill: parent; anchors.margins: 12; spacing: 12

            // carátula
            Rectangle {
                width: 84; height: 84; radius: 10; color: Theme.dim; clip: true
                border.color: Theme.purple; border.width: 1
                Image {
                    anchors.fill: parent
                    source: root.player ? (root.player.trackArtUrl || "") : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }
                Text {
                    anchors.centerIn: parent
                    visible: !root.player || (root.player.trackArtUrl || "") === ""
                    text: "♪"; color: Theme.cyan
                    font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx + 6
                }
            }

            // info + controles
            Column {
                width: parent.width - 84 - 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                Text {
                    width: parent.width
                    text: root.player ? (root.player.trackTitle || "—") : "Sin reproductor"
                    color: Theme.clockText; elide: Text.ElideRight
                    font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx
                }
                Text {
                    width: parent.width
                    visible: root.player !== null
                    text: root.player ? (root.player.trackArtist || "") : ""
                    color: Theme.muted; elide: Text.ElideRight
                    font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 2
                }

                // barra de progreso
                Item {
                    width: parent.width; height: 4; visible: root.player !== null
                    Rectangle { anchors.fill: parent; radius: 2; color: Theme.dim }
                    Rectangle {
                        height: parent.height; radius: 2; color: Theme.cyan
                        width: (root.player && root.player.length > 0)
                               ? parent.width * (root.player.position / root.player.length) : 0
                    }
                }

                // controles
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 22
                    Text {
                        text: "󰒮"; color: Theme.cyan
                        font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx + 2
                        MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
                                    onClicked: if (root.player && root.player.canGoPrevious) root.player.previous() }
                    }
                    Text {
                        text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"; color: Theme.cyan
                        font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx + 4
                        MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
                                    onClicked: if (root.player) root.player.isPlaying = !root.player.isPlaying }
                    }
                    Text {
                        text: "󰒭"; color: Theme.cyan
                        font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx + 2
                        MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
                                    onClicked: if (root.player && root.player.canGoNext) root.player.next() }
                    }
                }
            }
        }
    }
}
