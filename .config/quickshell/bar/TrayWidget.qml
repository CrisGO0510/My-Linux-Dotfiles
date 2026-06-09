import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Row {
    id: root
    spacing: 6

    // Resuelve el icono evitando el placeholder magenta: si es un nombre de tema
    // inexistente, iconPath(..., true) devuelve "" => mostramos fallback.
    function traySource(ic) {
        if (!ic) return "";
        if (ic.includes("?path=")) return ic;          // tema con ruta embebida: resuelve solo
        var m = ic.match(/^image:\/\/icon\/([^?]+)$/);  // nombre de tema "pelado"
        if (m) return Quickshell.iconPath(decodeURIComponent(m[1]), true);
        if (!ic.includes("://") && !ic.startsWith("/")) // nombre suelto
            return Quickshell.iconPath(ic, true);
        return ic; // path o pixmap directo
    }

    Repeater {
        model: SystemTray.items
        delegate: Item {
            id: entry
            required property var modelData
            readonly property string resolvedSource: root.traySource(modelData.icon)
            width: Theme.fontPx + 4
            height: Theme.fontPx + 4

            // fallback SOLO cuando el icono no resuelve (evita superposición con iconos transparentes)
            Text {
                anchors.centerIn: parent
                visible: entry.resolvedSource === ""
                text: "󰐧"
                color: Theme.textBase
                font.family: Theme.monoFamily
                font.pixelSize: Theme.fontPx
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: Theme.fontPx + 4
                source: entry.resolvedSource
                visible: entry.resolvedSource !== ""
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) entry.modelData.activate();
                    else entry.modelData.display(entry, mouse.x, mouse.y);
                }
            }
        }
    }
}
