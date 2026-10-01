pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

// Audio por workspace: empareja cada stream de salida con su ventana y la ventana con
// su workspace. Misma regla que Scripts/hypr/workspace-volume.sh (que es quien ajusta;
// aqui solo se lee):
//   Firefox comparte PID entre ventanas, asi que se compara `media.name` del stream con
//   el titulo de la ventana, ambos sin " — Firefox…" ni el contador "(8) " del inicio.
//   Si no casa, se prueba por PID cuando ese PID tiene una sola ventana. Si tampoco,
//   Si no, se usa la ultima ventana conocida del stream (memoria, ver abajo). Si
//   tampoco, el stream queda sin ubicar (ws = null).
//
// Memoria: una pestaña de Firefox en segundo plano sigue sonando pero ya no es el
// titulo de su ventana, y si Firefox tiene varias ventanas el PID tampoco decide. Por
// eso se recuerda object.serial del stream -> address de la ventana cada vez que casa
// por titulo/PID/class, y se guarda en $XDG_RUNTIME_DIR/wsvol-memo.tsv, que tambien
// lee y escribe el script. Se guarda la ventana, no el workspace: si se mueve, sigue.
Singleton {
    id: root

    // Streams de reproduccion. Quickshell los marca isStream + isSink (reciben audio de
    // la app); media.class no sirve para filtrar porque `properties` llega vacio hasta
    // que el nodo esta trackeado.
    readonly property var outNodes: Pipewire.nodes.values.filter(n => n.isStream && n.isSink)

    // necesario para que properties, audio.volume y audio.muted sean validos
    PwObjectTracker { objects: root.outNodes }

    // el pid de las ventanas vive en lastIpcObject, que solo se llena al refrescar
    Component.onCompleted: Hyprland.refreshToplevels()
    onOutNodesChanged: Hyprland.refreshToplevels()

    readonly property string memoPath: Quickshell.env("XDG_RUNTIME_DIR") + "/wsvol-memo.tsv"
    // { serial: address } (address sin "0x"). Se muta dentro del binding de `streams`
    // sin notificar, para no reevaluarlo; solo se reasigna al cargar el archivo.
    property var memo: ({})
    property bool memoDirty: false

    FileView {
        id: memoFile
        path: root.memoPath
        printErrors: false
        atomicWrites: true
        onLoaded: {
            const m = {};
            for (const line of text().split("\n")) {
                const f = line.split("\t");
                if (f.length === 2 && f[0] !== "") m[f[0]] = f[1];
            }
            root.memo = m;
        }
    }

    // escritura diferida: el binding solo marca memoDirty
    Timer {
        id: memoSave
        interval: 500
        onTriggered: {
            // se podan los streams que ya no existen
            const live = root.outNodes.map(n => root.serialOf(n));
            const out = [];
            for (const k of Object.keys(root.memo))
                if (live.includes(k)) out.push(k + "\t" + root.memo[k]);
            memoFile.setText(out.join("\n") + (out.length ? "\n" : ""));
        }
    }
    onStreamsChanged: if (memoDirty) { memoDirty = false; memoSave.restart(); }

    function serialOf(n) {
        return String(n.properties["object.serial"] || n.id);
    }
    function addrOf(t) {
        return String(t.address || "").replace(/^0x/, "");
    }

    function norm(s) {
        return (s || "").replace(/ [—–-] (Mozilla )?Firefox.*$/, "")
                        .replace(/^\(\d+\)\s*/, "")
                        .trim();
    }

    // [{ ws, title, pct, muted }]
    readonly property var streams: {
        const tops = Hyprland.toplevels.values;
        const out = [];
        for (const n of root.outNodes) {
            const p = n.properties;
            let mn = p["media.name"] || "";
            if (mn === "(null)") mn = "";
            const key = norm(mn);

            let win = null;
            if (key !== "")
                win = tops.find(t => norm(t.title) === key) || null;
            if (!win) {
                const pid = p["application.process.id"];
                const same = tops.filter(t => t.lastIpcObject && String(t.lastIpcObject.pid) === pid);
                if (same.length === 1) win = same[0];
            }
            // Spotify y similares: el nodo no trae PID y el título es la canción;
            // se compara application.name con la class, si hay una sola ventana
            if (!win) {
                const an = (p["application.name"] || "").toLowerCase();
                const same = tops.filter(t => an !== "" && t.lastIpcObject
                                         && (t.lastIpcObject.class || "").toLowerCase() === an);
                if (same.length === 1) win = same[0];
            }

            const serial = serialOf(n);
            if (win) {
                if (root.memo[serial] !== addrOf(win)) {
                    root.memo[serial] = addrOf(win);
                    root.memoDirty = true;
                }
            } else if (root.memo[serial]) {
                const addr = root.memo[serial];
                win = tops.find(t => addrOf(t) === addr) || null;
            }

            const a = n.audio;
            out.push({
                ws: win && win.workspace ? win.workspace.id : null,
                title: mn !== "" ? mn : (p["application.name"] || "audio"),
                pct: a ? Math.round(a.volume * 100) : 0,
                muted: a ? a.muted : false
            });
        }
        return out;
    }

    // [{ ws, pct, muted, titles }] ordenado: workspaces por id, sin ubicar al final.
    // pct = maximo entre los streams no silenciados; muted = todos silenciados.
    readonly property var groups: {
        const m = {};
        for (const s of root.streams) {
            const k = s.ws === null ? "?" : String(s.ws);
            if (!m[k]) m[k] = { ws: s.ws, pct: 0, muted: true, titles: [] };
            const g = m[k];
            g.titles.push(s.title);
            if (!s.muted) { g.muted = false; g.pct = Math.max(g.pct, s.pct); }
        }
        return Object.values(m).sort((a, b) =>
            a.ws === null ? 1 : b.ws === null ? -1 : a.ws - b.ws);
    }

    function wsLabel(ws) {
        return ws === null ? "?" : ws < 0 ? "Hidden" : "WS " + ws;
    }

    // Filas por ventana para el popup de audio, como en el menu rofi (mod+O): el nombre
    // del workspace solo en la primera ventana y un conector (┌ ├ └) si hay varias.
    // [{ ws, label, conn, title, pct, muted }]
    readonly property var rows: {
        const out = [];
        for (const g of root.groups) {
            const items = root.streams.filter(s => s.ws === g.ws);
            items.forEach((s, i) => out.push({
                ws: s.ws,
                label: i === 0 ? wsLabel(s.ws) : "",
                conn: items.length === 1 ? "" : i === 0 ? "┌" : i === items.length - 1 ? "└" : "├",
                title: s.title.replace(/^\(\d+\)\s*/, ""),
                pct: s.pct,
                muted: s.muted
            }));
        }
        return out;
    }

    function forWs(id) {
        return root.groups.find(g => g.ws === id) || null;
    }

    // OSD pedido por el script (bind mod + teclas de volumen)
    signal osdRequested(string ws, int pct, string state)
}
