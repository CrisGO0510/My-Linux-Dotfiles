import QtQuick
import Quickshell.Hyprland

Row {
    id: root
    spacing: Math.round(Theme.barHeight * 0.18)

    readonly property int activeId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property int total: Hyprland.workspaces ? Hyprland.workspaces.values.length : 1

    Text {
        text: root.activeId
        font.family: Theme.monoFamily
        font.pixelSize: Theme.clockPx
        font.bold: true
        color: Theme.cyan
    }
    Text {
        text: "/ " + root.total
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.monoFamily
        font.pixelSize: Theme.fontPx
        color: Theme.muted
    }
}
