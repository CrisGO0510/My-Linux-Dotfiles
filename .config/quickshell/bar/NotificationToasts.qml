import QtQuick
import Quickshell
import Quickshell.Wayland

// Popups de notificación en pantalla (esquina superior derecha).
PanelWindow {
    id: win
    anchors { top: true; right: true }
    margins.top: 10
    margins.right: 10
    implicitWidth: 360
    implicitHeight: Math.max(1, toastCol.implicitHeight)
    color: "transparent"
    WlrLayershell.namespace: "quickshell-notif"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    // solo los toasts capturan el ratón; el resto es click-through
    mask: Region { item: toastCol }

    Connections {
        target: Notifs
        function onToast(notif) {
            toastModel.append({
                summary: notif.summary || "",
                body: notif.body || "",
                appName: notif.appName || ""
            });
        }
    }

    Column {
        id: toastCol
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 8

        Repeater {
            model: ListModel { id: toastModel }
            delegate: Rectangle {
                id: toast
                required property int index
                required property string summary
                required property string body
                required property string appName

                width: 340
                implicitHeight: tc.implicitHeight + 20
                radius: 12
                color: Theme.islandBg
                border.color: Theme.purple; border.width: 1

                opacity: 0; x: 40
                Component.onCompleted: { opacity = 1; x = 0; }
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                // auto-cierre a los 5 s
                Timer { interval: 5000; running: true; onTriggered: toastModel.remove(toast.index) }

                Column {
                    id: tc
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                    anchors.margins: 10; anchors.rightMargin: 24
                    spacing: 3
                    Text {
                        width: parent.width
                        text: (toast.appName ? toast.appName + " · " : "") + toast.summary
                        color: Theme.cyan; font.bold: true; elide: Text.ElideRight
                        font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 1
                    }
                    Text {
                        width: parent.width
                        visible: toast.body !== ""
                        text: toast.body
                        color: Theme.textBase; wrapMode: Text.WordWrap; maximumLineCount: 4; elide: Text.ElideRight
                        font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 2
                    }
                }
                Text {
                    anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 8
                    text: "✕"; color: Theme.muted
                    font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 1
                    MouseArea { anchors.fill: parent; anchors.margins: -5
                                cursorShape: Qt.PointingHandCursor; onClicked: toastModel.remove(toast.index) }
                }
            }
        }
    }
}
