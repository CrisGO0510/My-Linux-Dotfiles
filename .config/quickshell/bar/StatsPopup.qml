import QtQuick
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root
    property var anchorItem

    implicitWidth: 320
    implicitHeight: col.implicitHeight + 12
    color: "transparent"
    grabFocus: true

    anchor.window: anchorItem ? anchorItem.QsWindow.window : null
    anchor.rect.x: anchorItem ? (anchorItem.x + anchorItem.width - root.implicitWidth) : 0
    anchor.rect.y: Theme.barHeight + 4

    function fmtUptime(s) {
        const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60);
        return h + "h " + m + "m";
    }

    // acciones de power
    Process { id: actionProc }
    function run(cmd) { actionProc.command = ["bash", "-c", cmd]; actionProc.running = true; root.visible = false; }

    // auto-cierre al salir el cursor
    property bool entered: false
    Timer { id: closeTimer; interval: 250; onTriggered: if (!hover.hovered) root.visible = false }
    onVisibleChanged: root.entered = false

    Item {
        id: wrapper
        anchors.fill: parent
        opacity: 0
        transform: Translate { id: slide; y: -10 }
        states: State { name: "open"; when: root.visible
            PropertyChanges { target: wrapper; opacity: 1 }
            PropertyChanges { target: slide; y: 0 } }
        transitions: Transition {
            NumberAnimation { target: wrapper; property: "opacity"; duration: 150; easing.type: Easing.OutCubic }
            NumberAnimation { target: slide; property: "y"; duration: 150; easing.type: Easing.OutCubic } }

        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered) { root.entered = true; closeTimer.stop(); }
                else if (root.entered) closeTimer.restart();
            }
        }

        Column {
            id: col
            x: 6; y: 6; width: parent.width - 12
            spacing: 8

            // ===== Card principal (sistema) =====
            Rectangle {
                width: parent.width
                implicitHeight: statsCol.implicitHeight + 28
                radius: 14; color: Theme.islandBg; border.color: Theme.purple; border.width: 1

                Column {
                    id: statsCol
                    anchors.fill: parent; anchors.margins: 14; spacing: 10

                    Row {
                        spacing: 10
                        Rectangle { width: 40; height: 40; radius: 20; color: Theme.dim
                                    border.color: Theme.cyan; border.width: 1 }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text { text: "CrisGO"; color: Theme.clockText
                                   font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx }
                            Text { text: "uptime " + root.fmtUptime(Sys.uptimeSec); color: Theme.muted
                                   font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 2 }
                        }
                    }
                    Rectangle { width: parent.width; height: 1; color: Theme.purple; opacity: 0.4 }

                    Text { text: "CORE DETAIL"; color: Theme.cyan; opacity: 0.85
                           font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 3 }
                    Row {
                        id: coreRow
                        width: parent.width; height: 52; spacing: 3
                        Repeater {
                            model: Sys.coresPct
                            delegate: Item {
                                required property var modelData
                                width: (coreRow.width - (Sys.coresPct.length - 1) * coreRow.spacing)
                                       / Math.max(1, Sys.coresPct.length)
                                height: coreRow.height
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: Math.max(2, coreRow.height * modelData / 100)
                                    radius: 2
                                    color: modelData > 75 ? Theme.hot
                                         : (modelData > 45 ? Theme.cyan : Theme.purple)
                                    Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                                }
                            }
                        }
                    }
                    Rectangle { width: parent.width; height: 1; color: Theme.purple; opacity: 0.4 }

                    Row {
                        width: parent.width
                        Text { width: parent.width / 3; horizontalAlignment: Text.AlignHCenter
                               text: "RAM " + Sys.ramPct + "%"; color: Theme.textBase
                               font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx }
                        Text { width: parent.width / 3; horizontalAlignment: Text.AlignHCenter
                               text: "CPU " + Sys.cpuPct + "%"; color: Theme.textBase
                               font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx }
                        Text { width: parent.width / 3; horizontalAlignment: Text.AlignHCenter
                               text: Sys.cpuTemp + "°"; color: Theme.textBase
                               font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx }
                    }
                    Rectangle { width: parent.width; height: 1; color: Theme.purple; opacity: 0.4 }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 22
                        Repeater {
                            model: [
                                { icon: "󰌾", cmd: "$HOME/dotfiles/Scripts/hypr/lock.sh" },
                                { icon: "󰒲", cmd: "systemctl suspend" },
                                { icon: "󰍃", cmd: "hyprctl dispatch exit" },
                                { icon: "󰜉", cmd: "systemctl reboot" },
                                { icon: "⏻",  cmd: "systemctl poweroff" }
                            ]
                            delegate: Text {
                                required property var modelData
                                text: modelData.icon
                                color: Theme.cyan
                                font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx + 3
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: root.run(modelData.cmd) }
                            }
                        }
                    }
                }
            }

            // ===== Card de notificaciones (lista real) =====
            Rectangle {
                width: parent.width
                implicitHeight: notifCol.implicitHeight + 24
                radius: 14; color: Theme.islandBg; border.color: Theme.purple; border.width: 1

                Column {
                    id: notifCol
                    anchors.fill: parent; anchors.margins: 12; spacing: 8

                    // cabecera: campana + contador + DND + borrar
                    Item {
                        width: parent.width; height: Theme.clockPx
                        Row {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Text { anchors.verticalCenter: parent.verticalCenter; text: "󰂚"; color: Theme.cyan
                                   font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx }
                            Text { anchors.verticalCenter: parent.verticalCenter
                                   text: "Notificaciones (" + Notifs.model.values.length + ")"
                                   color: Theme.clockText; font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 1 }
                        }
                        Row {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            spacing: 16
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: Notifs.dnd ? "󰂛" : "󰂚"
                                color: Notifs.dnd ? Theme.alert : Theme.textBase
                                font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx
                                MouseArea { anchors.fill: parent; anchors.margins: -6
                                            cursorShape: Qt.PointingHandCursor; onClicked: Notifs.toggleDnd() }
                                HoverHandler { id: dndHover }
                                NeonTooltip { visible: dndHover.hovered; text: Notifs.dnd ? "No molestar: ON" : "No molestar: OFF" }
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "󰩹"; color: Theme.textBase
                                font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx
                                MouseArea { anchors.fill: parent; anchors.margins: -6
                                            cursorShape: Qt.PointingHandCursor; onClicked: Notifs.clearAll() }
                                HoverHandler { id: clrHover }
                                NeonTooltip { visible: clrHover.hovered; text: "Borrar todo" }
                            }
                        }
                    }

                    // vacío
                    Text {
                        visible: Notifs.model.values.length === 0
                        text: "Sin notificaciones"; color: Theme.muted
                        font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 1
                    }

                    // lista (scroll si crece)
                    ListView {
                        visible: Notifs.model.values.length > 0
                        width: parent.width
                        height: Math.min(contentHeight, 200)
                        clip: true
                        spacing: 6
                        model: Notifs.model
                        delegate: Rectangle {
                            required property var modelData
                            width: ListView.view.width
                            implicitHeight: itemCol.implicitHeight + 14
                            radius: 8
                            color: Qt.rgba(139/255, 92/255, 246/255, 0.10)
                            border.color: Qt.rgba(139/255, 92/255, 246/255, 0.35); border.width: 1

                            Column {
                                id: itemCol
                                anchors.left: parent.left; anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 7
                                anchors.rightMargin: 22
                                spacing: 2
                                Text {
                                    width: parent.width
                                    text: (modelData.appName ? modelData.appName + " · " : "") + (modelData.summary || "")
                                    color: Theme.cyan; elide: Text.ElideRight
                                    font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 2; font.bold: true
                                }
                                Text {
                                    width: parent.width
                                    visible: (modelData.body || "") !== ""
                                    text: modelData.body || ""
                                    color: Theme.textBase; wrapMode: Text.WordWrap; maximumLineCount: 3; elide: Text.ElideRight
                                    font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 3
                                }
                            }
                            Text {
                                anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 6
                                text: "✕"; color: Theme.muted
                                font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 1
                                MouseArea { anchors.fill: parent; anchors.margins: -5
                                            cursorShape: Qt.PointingHandCursor; onClicked: Notifs.dismiss(modelData) }
                            }
                        }
                    }
                }
            }
        }
    }
}
