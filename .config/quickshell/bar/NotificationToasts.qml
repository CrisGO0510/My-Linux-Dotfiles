import QtQuick
import Quickshell
import Quickshell.Wayland

// Popups de notificación en pantalla (esquina superior derecha).
// Todos caducan: al caducar solo se oculta el toast; la notificación sigue
// en el historial (mod+N) con sus botones operativos.
PanelWindow {
    id: win
    anchors { top: true; right: true }
    margins.top: 0
    margins.right: 0
    // margen interno para que el glow de las tarjetas no se recorte
    implicitWidth: 340 + 2 * 18
    implicitHeight: Math.max(1, toastCol.implicitHeight + 2 * 18)
    color: "transparent"
    WlrLayershell.namespace: "quickshell-notif"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    // solo los toasts capturan el ratón; el resto es click-through
    mask: Region { item: toastCol }

    readonly property int maxToasts: 4

    function removeToast(nid) {
        for (let i = 0; i < toastModel.count; i++)
            if (toastModel.get(i).nid === nid) { toastModel.remove(i); return; }
    }

    Connections {
        target: Notifs
        function onToast(notif) {
            win.removeToast(notif.id);   // reemplazo (mismo id): vuelve arriba
            toastModel.insert(0, { nid: notif.id });
            while (toastModel.count > win.maxToasts) toastModel.remove(toastModel.count - 1);
        }
        function onRemoved(nid) { win.removeToast(nid); }
    }

    Column {
        id: toastCol
        x: 18; y: 18
        width: 340
        spacing: 12

        move: Transition { NumberAnimation { properties: "y"; duration: 180; easing.type: Easing.OutCubic } }

        Repeater {
            model: ListModel { id: toastModel }
            delegate: NotificationCard {
                id: toast
                required property int nid
                notif: Notifs.get(nid)
                width: toastCol.width

                // expireTimeout (s) de la app; si no, 5 s (10 s con botones). Máximo 30 s.
                readonly property int duration: {
                    const t = notif ? notif.expireTimeout : 0;
                    if (t > 0) return Math.min(30000, Math.max(2000, t * 1000));
                    return Notifs.buttons(notif).length > 0 ? 10000 : 5000;
                }
                property int remaining: duration
                progress: remaining / duration

                // el hover pausa la cuenta atrás
                Timer {
                    interval: 50; repeat: true
                    running: !toast.hovered
                    onTriggered: {
                        toast.remaining -= interval;
                        if (toast.remaining <= 0) win.removeToast(toast.nid);
                    }
                }
                onDone: win.removeToast(nid)

                opacity: 0
                transform: Translate { id: slide; x: 40
                    Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } } }
                Component.onCompleted: { opacity = 1; slide.x = 0; }
                Behavior on opacity { NumberAnimation { duration: 180 } }
            }
        }
    }
}
