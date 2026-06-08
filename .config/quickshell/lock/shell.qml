import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    readonly property bool preview: Quickshell.env("QS_LOCK_PREVIEW") === "1"

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            color: "transparent"
            WlrLayershell.namespace: "quickshell-lock"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.preview ? WlrKeyboardFocus.None
                                                      : WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore

            LockContent {
                anchors.fill: parent
                preview: root.preview
                onAuthSucceeded: Qt.quit()
            }
        }
    }
}
