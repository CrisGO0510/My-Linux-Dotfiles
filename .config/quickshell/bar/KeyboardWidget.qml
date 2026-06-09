import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Text {
    id: root
    property string layout: "??"
    font.family: Theme.monoFamily
    font.pixelSize: Theme.fontPx
    color: Theme.textBase
    text: root.layout

    function shortName(full) {
        if (!full) return "??";
        const f = full.toLowerCase();
        if (f.includes("spanish") || f.includes("español")) return "ES";
        if (f.includes("english") || f.includes("us")) return "EN";
        return full.slice(0, 2).toUpperCase();
    }

    // estado inicial vía hyprctl
    Process {
        running: true
        command: ["bash", "-c", "hyprctl devices -j | jq -r '.keyboards[] | select(.main==true) | .active_keymap'"]
        stdout: StdioCollector { onStreamFinished: root.layout = root.shortName(this.text.trim()) }
    }

    // cambios en vivo: evento activelayout = "teclado,Layout Name"
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                const parts = event.data.split(",");
                root.layout = root.shortName(parts[parts.length - 1]);
            }
        }
    }
}
