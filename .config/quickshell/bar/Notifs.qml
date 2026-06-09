pragma Singleton
import Quickshell
import Quickshell.Services.Notifications

// Servidor de notificaciones nativo (reemplaza swaync).
// Mantiene el historial (trackedNotifications) y emite toast() para los popups.
Singleton {
    id: root
    property bool dnd: false
    readonly property var model: server.trackedNotifications   // ObjectModel<Notification>
    signal toast(var notif)
    signal panelRequested()   // emitida por IPC (bind mod+N) para abrir el panel

    NotificationServer {
        id: server
        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        onNotification: (notif) => {
            notif.tracked = true;          // conservar en el historial
            if (!root.dnd) root.toast(notif);
        }
    }

    function dismiss(n) { if (n) n.tracked = false; }
    function clearAll() {
        var arr = server.trackedNotifications.values.slice();
        for (var i = 0; i < arr.length; i++) arr[i].tracked = false;
    }
    function toggleDnd() { root.dnd = !root.dnd; }
}
