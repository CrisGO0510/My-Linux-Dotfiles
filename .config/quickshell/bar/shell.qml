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
        // volcado para depurar la resolución de ventana/workspace
        function dump(): string { return JSON.stringify(Notifs.meta) }
    }

    // IPC del pomodoro (mod+P)
    IpcHandler {
        target: "pomo"
        function primary(): void { Pomo.primary() }
        function reset(): void { Pomo.reset() }
        function skip(): void { Pomo.skip() }
        function stop(): void { Pomo.stop() }
    }

    // IPC del volumen por workspace (Scripts/hypr/workspace-volume.sh)
    IpcHandler {
        target: "wsvol"
        // state: on | mute | none (sin audio en ese workspace)
        function osd(ws: string, pct: int, state: string): void { WsAudio.osdRequested(ws, pct, state) }
        // volcado para depurar el emparejamiento
        function dump(): string { return JSON.stringify(WsAudio.groups) }
    }
}
