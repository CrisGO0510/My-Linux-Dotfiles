import QtQuick

Text {
    id: root
    signal clicked()

    font.family: Theme.monoFamily
    font.pixelSize: Theme.clockPx
    color: Theme.clockText
    // resplandor
    style: Text.Normal

    property var now: new Date()
    text: Qt.formatDateTime(now, "HH:mm")

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.now = new Date()
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
