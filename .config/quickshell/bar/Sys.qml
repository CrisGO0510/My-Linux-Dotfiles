pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int  ramPct: 0
    property int  cpuPct: 0
    property int  cpuTemp: 0
    property real netDown: 0   // KB/s
    property real netUp: 0     // KB/s
    property int  uptimeSec: 0

    // --- estado interno para deltas ---
    property var _prevCpu: null      // [idle, total]
    property var _prevNet: null      // [rx, tx]
    property double _prevNetT: 0

    property var coresPct: []        // [%, %, ...] uno por núcleo
    property var _prevCores: ({})    // idx -> [idle, total]

    // FileView estáticos con blockLoading: lectura síncrona sin subprocesos.
    // /proc y /sys son diminutos => el bloqueo es despreciable.
    FileView { id: memFile;  path: "/proc/meminfo"; blockLoading: true; printErrors: false }
    FileView { id: statFile; path: "/proc/stat";    blockLoading: true; printErrors: false }
    FileView { id: tempFile; path: "/sys/class/thermal/thermal_zone0/temp"; blockLoading: true; printErrors: false }
    FileView { id: netFile;  path: "/proc/net/dev"; blockLoading: true; printErrors: false }
    FileView { id: upFile;   path: "/proc/uptime";  blockLoading: true; printErrors: false }

    function refresh() {
        memFile.reload(); statFile.reload(); tempFile.reload(); upFile.reload();
        // RAM desde /proc/meminfo
        try {
            const mem = memFile.text();
            const total = parseInt(mem.match(/MemTotal:\s+(\d+)/)[1]);
            const avail = parseInt(mem.match(/MemAvailable:\s+(\d+)/)[1]);
            root.ramPct = Math.round((total - avail) / total * 100);
        } catch (e) {}

        // CPU% desde /proc/stat (línea agregada "cpu ...")
        try {
            const stat = statFile.text();
            const parts = stat.split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = parts[3] + (parts[4] || 0);
            const tot = parts.reduce((a, b) => a + b, 0);
            if (root._prevCpu) {
                const dIdle = idle - root._prevCpu[0];
                const dTot = tot - root._prevCpu[1];
                if (dTot > 0) root.cpuPct = Math.round((1 - dIdle / dTot) * 100);
            }
            root._prevCpu = [idle, tot];
        } catch (e) {}

        // CPU por núcleo: líneas cpu0, cpu1, ... de /proc/stat
        try {
            const cores = [];
            const next = {};
            for (const line of statFile.text().split("\n")) {
                const m = line.match(/^cpu(\d+)\s+(.*)/);
                if (!m) continue;
                const idx = parseInt(m[1]);
                const p = m[2].trim().split(/\s+/).map(Number);
                const idle = p[3] + (p[4] || 0);
                const tot = p.reduce((a, b) => a + b, 0);
                next[idx] = [idle, tot];
                if (root._prevCores[idx]) {
                    const di = idle - root._prevCores[idx][0];
                    const dt = tot - root._prevCores[idx][1];
                    cores[idx] = dt > 0 ? Math.round((1 - di / dt) * 100) : 0;
                } else cores[idx] = 0;
            }
            root._prevCores = next;
            root.coresPct = cores;
        } catch (e) {}

        // Temp CPU: primera zona térmica tipo x86_pkg_temp o la zona 0
        try {
            const tRaw = tempFile.text();
            root.cpuTemp = Math.round(parseInt(tRaw) / 1000);
        } catch (e) {}

        // uptime
        try {
            const up = upFile.text();
            root.uptimeSec = Math.round(parseFloat(up.split(" ")[0]));
        } catch (e) {}
    }

    function refreshNet() {
        netFile.reload();
        try {
            const dev = netFile.text();
            let rx = 0, tx = 0;
            for (const line of dev.split("\n")) {
                if (!line.includes(":")) continue;
                const name = line.split(":")[0].trim();
                if (name === "lo") continue;
                const cols = line.split(":")[1].trim().split(/\s+/).map(Number);
                rx += cols[0]; tx += cols[8];
            }
            const tNow = root.uptimeSec; // segundos monotónicos aprox.
            if (root._prevNet && tNow > root._prevNetT) {
                const dt = tNow - root._prevNetT;
                root.netDown = (rx - root._prevNet[0]) / 1024 / dt;
                root.netUp = (tx - root._prevNet[1]) / 1024 / dt;
            }
            root._prevNet = [rx, tx];
            root._prevNetT = tNow;
        } catch (e) {}
    }

    Timer { interval: 2000; running: true; repeat: true; onTriggered: root.refresh() }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: root.refreshNet() }
    Component.onCompleted: { refresh(); refreshNet(); }
}
