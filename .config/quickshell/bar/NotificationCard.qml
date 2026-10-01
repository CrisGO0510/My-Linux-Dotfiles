import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications

// Tarjeta de notificación (estilo neón). La usan los toasts y el historial.
//  - clic en el cuerpo: acción por defecto + ir a la ventana de origen
//  - botones: acciones de la app (confirmar emparejamiento, etc.)
//  - píldora 󰖯 N: workspace de la ventana que la originó
Item {
    id: card
    required property var notif
    property bool compact: false        // true en el historial
    property real progress: -1          // 0..1 cuenta atrás del toast; <0 = sin barra
    readonly property bool hovered: hover.hovered
    // se emiten antes de actuar: cerrar la notificación destruye la tarjeta
    signal done()                       // la tarjeta se usó (clic, botón o ✕)
    signal activated()                  // clic en el cuerpo o en un botón

    readonly property bool critical: notif && notif.urgency === NotificationUrgency.Critical
    readonly property color accent: critical ? Theme.alert : Theme.purple
    readonly property string ws: Notifs.wsLabel(notif)   // lee Notifs.meta => reactivo
    readonly property var actions: notif ? Notifs.buttons(notif) : []

    implicitHeight: body.implicitHeight + (compact ? 16 : 22)

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: compact ? 10 : 14
        color: Theme.islandBg
        border.color: card.compact ? Qt.rgba(card.accent.r, card.accent.g, card.accent.b, 0.45) : card.accent
        border.width: 1
        clip: true

        // glow difuso del acento (solo en toasts). El blur de Hyprland usa
        // ignore_alpha para no difuminar este halo semitransparente.
        layer.enabled: !card.compact
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: card.accent
            shadowBlur: 0.8
            blurMax: 20
            shadowOpacity: hover.hovered ? 0.55 : 0.35
            shadowHorizontalOffset: 0; shadowVerticalOffset: 0
        }

        // clic en el cuerpo (los botones y la ✕ van encima y lo tapan)
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: { const n = card.notif; card.activated(); card.done(); Notifs.activate(n); }
        }

        // cuenta atrás
        Rectangle {
            visible: card.progress >= 0
            // dentro del borde y sin tocar las esquinas redondeadas
            anchors.left: parent.left; anchors.bottom: parent.bottom
            anchors.leftMargin: bg.radius; anchors.bottomMargin: 1
            height: 2; radius: 1
            width: (parent.width - 2 * bg.radius) * Math.max(0, card.progress)
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: card.accent }
                GradientStop { position: 1; color: card.critical ? Theme.hot : Theme.cyan }
            }
        }
    }

    HoverHandler { id: hover }

    Row {
        id: body
        anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
        anchors.margins: card.compact ? 8 : 11
        anchors.rightMargin: 26
        spacing: 10

        // icono: imagen de la notificación > icono de la app > glifo
        Rectangle {
            id: iconBox
            width: card.compact ? 28 : 34; height: width
            radius: card.compact ? 7 : 9
            color: Theme.dim
            border.color: Qt.rgba(34/255, 211/255, 238/255, 0.4); border.width: 1

            // Resuelve un icono evitando el placeholder magenta (como TrayWidget):
            // "image://icon/<nombre>" o nombre de tema inexistente => "".
            function resolve(ic) {
                ic = ic || "";
                const m = ic.match(/^image:\/\/icon\/([^?]+)$/);
                if (m) ic = decodeURIComponent(m[1]);
                if (ic.startsWith("~/")) ic = Quickshell.env("HOME") + ic.slice(1);
                if (ic.startsWith("/")) return "file://" + ic;
                if (ic.startsWith("file://") || ic.startsWith("image://")) return ic;
                // nombre de icono del tema; una ruta relativa no es resoluble
                return ic && !ic.includes("/") ? Quickshell.iconPath(ic, true) : "";
            }
            readonly property string src: {
                const n = card.notif;
                if (!n) return "";
                return resolve(n.image) || resolve(n.appIcon);
            }

            Image {
                id: img
                anchors.fill: parent; anchors.margins: 4
                source: iconBox.src
                fillMode: Image.PreserveAspectFit
                sourceSize.width: 64; sourceSize.height: 64
                asynchronous: true
                visible: status === Image.Ready
            }
            Text {
                anchors.centerIn: parent
                visible: !img.visible
                text: {
                    const a = ((card.notif && (card.notif.appName + " " + card.notif.desktopEntry)) || "").toLowerCase();
                    if (a.includes("blue")) return "󰂯";
                    if (a.includes("teclado") || a.includes("keyboard")) return "󰌌";
                    if (a.includes("firefox")) return "󰈹";
                    if (a.includes("calendar")) return "󰃭";
                    return "󰂚";
                }
                color: Theme.cyan
                font.family: Theme.monoFamily; font.pixelSize: card.compact ? 14 : 17
            }
        }

        Column {
            width: body.width - iconBox.width - body.spacing
            spacing: 3

            // meta: app · hace X · 󰖯 N
            Row {
                spacing: 6
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        const app = card.notif ? card.notif.appName : "";
                        const t = Notifs.ago(card.notif);   // depende de Notifs.now
                        return app ? app + " · " + t : t;
                    }
                    color: Theme.muted
                    font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 3
                }
                Rectangle {
                    visible: card.ws !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    width: wsText.implicitWidth + 12; height: wsText.implicitHeight + 2
                    radius: height / 2
                    color: Qt.rgba(34/255, 211/255, 238/255, 0.12)
                    border.color: Qt.rgba(34/255, 211/255, 238/255, 0.4); border.width: 1
                    Text {
                        id: wsText
                        anchors.centerIn: parent
                        text: "󰖯 " + card.ws
                        color: Theme.cyan
                        font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 4
                    }
                }
            }

            Text {
                width: parent.width
                text: card.notif ? card.notif.summary : ""
                color: Theme.textBright; font.bold: true
                elide: Text.ElideRight
                font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - (card.compact ? 2 : 0)
            }
            Text {
                width: parent.width
                visible: text !== ""
                text: card.notif ? card.notif.body : ""
                textFormat: Text.StyledText
                color: Theme.textBase; linkColor: Theme.cyan
                wrapMode: Text.WordWrap; maximumLineCount: card.compact ? 2 : 4; elide: Text.ElideRight
                font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - (card.compact ? 3 : 2)
                onLinkActivated: (link) => Qt.openUrlExternally(link)
            }

            // botones de acción; el primero relleno
            Row {
                visible: card.actions.length > 0
                width: parent.width
                topPadding: 6
                spacing: 6
                Repeater {
                    model: card.actions
                    Rectangle {
                        id: btn
                        required property var modelData
                        required property int index
                        readonly property bool primary: index === 0
                        width: (parent.width - (card.actions.length - 1) * 6) / card.actions.length
                        height: btnText.implicitHeight + (card.compact ? 8 : 12)
                        radius: 8
                        color: primary ? (btnHover.hovered ? Qt.lighter(card.accent, 1.15) : card.accent)
                                       : Qt.rgba(139/255, 92/255, 246/255, btnHover.hovered ? 0.25 : 0.12)
                        border.color: primary ? card.accent : Qt.rgba(139/255, 92/255, 246/255, 0.6)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text {
                            id: btnText
                            anchors.centerIn: parent
                            width: parent.width - 8
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            text: btn.modelData.text
                            color: btn.primary ? Theme.deepBg : Theme.clockText
                            font.bold: btn.primary
                            font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - (card.compact ? 3 : 2)
                        }
                        HoverHandler { id: btnHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { const n = card.notif, a = btn.modelData; card.activated(); card.done(); Notifs.invoke(n, a); }
                        }
                    }
                }
            }
        }
    }

    // ✕ descarta del todo (toast + historial)
    Text {
        anchors.top: parent.top; anchors.right: parent.right
        anchors.topMargin: card.compact ? 6 : 9; anchors.rightMargin: 10
        text: "✕"; color: xHover.hovered ? Theme.alert : Theme.muted
        font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 2
        HoverHandler { id: xHover }
        MouseArea {
            anchors.fill: parent; anchors.margins: -5
            cursorShape: Qt.PointingHandCursor
            onClicked: { const n = card.notif; card.done(); Notifs.dismiss(n); }
        }
    }
}
