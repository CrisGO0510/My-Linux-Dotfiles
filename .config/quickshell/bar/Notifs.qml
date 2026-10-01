pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications

// Servidor de notificaciones nativo (reemplaza swaync).
// Mantiene el historial (trackedNotifications), emite toast() para los popups
// y asocia cada notificación a la ventana de Hyprland que la originó.
Singleton {
    id: root
    property bool dnd: false
    readonly property var model: server.trackedNotifications   // ObjectModel<Notification>
    signal toast(var notif)
    signal removed(int nid)   // la notificación se cerró (app, usuario o caducidad del servidor)
    signal panelRequested()   // emitida por IPC (bind mod+N) para abrir el panel

    // nid -> { time, address, cls, ws }  (reasignar el objeto para notificar cambios)
    property var meta: ({})
    // nid -> Notification, para que los toasts guarden solo el id
    property var registry: ({})

    // reloj para el "hace X" de las tarjetas
    property double now: Date.now()
    Timer { interval: 30000; running: true; repeat: true; onTriggered: root.now = Date.now() }

    NotificationServer {
        id: server
        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: false
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        persistenceSupported: true
        onNotification: (notif) => {
            notif.tracked = true;          // conservar en el historial
            const nid = notif.id;
            root.registry[nid] = notif;
            root.setMeta(nid, { time: Date.now() });
            notif.closed.connect(() => root.forget(nid));
            root.resolve(notif);
            if (!root.dnd) root.toast(notif);
        }
    }

    function get(nid) { return root.registry[nid] || null; }
    function metaOf(n) { return n ? (root.meta[n.id] || {}) : {}; }

    function setMeta(nid, patch) {
        const m = Object.assign({}, root.meta);
        m[nid] = Object.assign({}, m[nid] || {}, patch);
        root.meta = m;
    }

    function forget(nid) {
        delete root.registry[nid];
        const m = Object.assign({}, root.meta);
        delete m[nid];
        root.meta = m;
        root.removed(nid);
    }

    // ---- ventana de origen ----
    // "Firefox Nightly" -> "firefox-nightly"; ".desktop" fuera
    function norm(s) { return (s || "").toLowerCase().replace(/\.desktop$/, "").trim().replace(/\s+/g, "-"); }

    // cola de resoluciones: un único Process de hyprctl reutilizado
    property var pending: []
    function resolve(notif) {
        const keys = [norm(notif.desktopEntry), norm(notif.appName)].filter(k => k !== "");
        if (keys.length === 0) return;
        root.pending.push({ nid: notif.id, keys: keys });
        if (!clients.running) clients.running = true;
    }

    Process {
        id: clients
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let list = [];
                try { list = JSON.parse(this.text); } catch (e) { list = []; }
                const jobs = root.pending;
                root.pending = [];
                for (const job of jobs) {
                    // coincidencia por class/initialClass; entre varias, la usada más recientemente
                    const hits = list.filter(c => {
                        const cls = [norm(c.class), norm(c.initialClass)];
                        return job.keys.some(k => cls.includes(k));
                    }).sort((a, b) => a.focusHistoryID - b.focusHistoryID);
                    if (hits.length === 0 || !root.registry[job.nid]) continue;
                    const c = hits[0];
                    root.setMeta(job.nid, { address: c.address, cls: c.class, ws: c.workspace.name });
                }
                // llegaron más notificaciones mientras corría
                if (root.pending.length > 0) clients.running = true;
            }
        }
    }

    // etiqueta de la píldora: "3", o "S" para workspaces especiales
    function wsLabel(n) {
        const ws = metaOf(n).ws;
        if (ws === undefined || ws === null || ws === "") return "";
        return String(ws).startsWith("special") ? "S" : String(ws);
    }

    function focusWindow(n) {
        const m = metaOf(n);
        if (!m.address) return;
        const alive = Hyprland.toplevels.values.some(t => "0x" + t.address === m.address || t.address === m.address);
        const target = alive ? "address:" + m.address : "class:^(" + m.cls + ")$";
        Hyprland.dispatch('hl.dsp.focus({ window = "' + target + '" })');
    }

    // ---- acciones ----
    function defaultAction(n) {
        return n ? (Array.from(n.actions).find(a => a.identifier === "default") || null) : null;
    }
    function buttons(n) {
        return n ? Array.from(n.actions).filter(a => a.identifier !== "default") : [];
    }

    // clic en el cuerpo: acción por defecto + ir a la ventana + descartar
    function activate(n) {
        if (!n) return;
        const nid = n.id, resident = n.resident;
        const def = defaultAction(n);
        focusWindow(n);
        if (def) def.invoke();
        // invoke() puede cerrar la notificación; solo descartar si sigue viva
        if (!resident && root.registry[nid]) n.dismiss();
    }

    // clic en un botón
    function invoke(n, action) {
        if (!n || !action) return;
        const nid = n.id, resident = n.resident;
        action.invoke();
        if (!resident && root.registry[nid]) n.dismiss();
    }

    function dismiss(n) { if (n) n.dismiss(); }
    function clearAll() {
        var arr = server.trackedNotifications.values.slice();
        for (var i = 0; i < arr.length; i++) arr[i].dismiss();
    }
    function toggleDnd() { root.dnd = !root.dnd; }

    // "ahora", "hace 3 min", "hace 2 h"
    function ago(n) {
        const t = metaOf(n).time;
        if (!t) return "";
        const s = Math.max(0, (root.now - t) / 1000);
        if (s < 60) return "ahora";
        if (s < 3600) return "hace " + Math.floor(s / 60) + " min";
        return "hace " + Math.floor(s / 3600) + " h";
    }
}
