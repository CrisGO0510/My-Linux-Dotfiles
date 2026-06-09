import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Component { Bar {} }
    }

    // popups de notificación en pantalla (servidor de notificaciones nativo)
    NotificationToasts {}

    // IPC para los binds de Hyprland (mod+N / mod+Shift+N)
    IpcHandler {
        target: "notifs"
        function toggleDnd(): void { Notifs.toggleDnd() }
        function panel(): void { Notifs.panelRequested() }
    }
}
