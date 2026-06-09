import QtQuick
import Quickshell.Services.Mpris

Text {
    id: root
    signal clicked()

    readonly property var player: Mpris.players && Mpris.players.values.length > 0
                                  ? Mpris.players.values[0] : null
    visible: player !== null

    font.family: Theme.monoFamily
    font.pixelSize: Theme.fontPx
    color: Theme.cyan
    elide: Text.ElideRight
    width: Math.min(implicitWidth, Theme.barHeight * 4)
    text: player ? "♪ " + (player.trackTitle || "—") : ""

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.MiddleButton && root.player) root.player.isPlaying = !root.player.isPlaying;
            else root.clicked();
        }
    }
}
