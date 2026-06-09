import QtQuick

Text {
    id: root
    signal clicked()
    text: "󰓅"   // pulso
    font.family: Theme.monoFamily
    font.pixelSize: Theme.clockPx
    color: Theme.textBase

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
