import QtQuick
import Quickshell

PopupWindow {
    id: root
    property var anchorItem

    readonly property int cellW: 30
    implicitWidth: cellW * 7 + 28
    implicitHeight: calCol.implicitHeight + 40
    color: "transparent"
    grabFocus: true

    // anclado bajo la isla central (Rectangle), centrado horizontalmente
    anchor.window: anchorItem ? anchorItem.QsWindow.window : null
    anchor.rect.x: anchorItem ? (anchorItem.x + anchorItem.width / 2 - root.implicitWidth / 2) : 0
    anchor.rect.y: Theme.barHeight + 4

    property int viewYear: 2026
    property int viewMonth: 0   // 0-11
    readonly property var today: new Date()
    readonly property var monthNames: ["Enero","Febrero","Marzo","Abril","Mayo","Junio",
                                       "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]

    function resetView() { var d = new Date(); viewYear = d.getFullYear(); viewMonth = d.getMonth(); }
    function prev() { if (viewMonth === 0) { viewMonth = 11; viewYear--; } else viewMonth--; }
    function next() { if (viewMonth === 11) { viewMonth = 0; viewYear++; } else viewMonth++; }
    function daysGrid(y, m) {
        var first = new Date(y, m, 1);
        var startDow = (first.getDay() + 6) % 7;          // lunes = 0
        var nDays = new Date(y, m + 1, 0).getDate();
        var cells = [];
        for (var i = 0; i < startDow; i++) cells.push(0);
        for (var d = 1; d <= nDays; d++) cells.push(d);
        while (cells.length % 7 !== 0) cells.push(0);
        return cells;
    }

    Component.onCompleted: resetView()
    property bool entered: false
    Timer { id: closeTimer; interval: 250; onTriggered: if (!hover.hovered) root.visible = false }
    onVisibleChanged: { if (visible) resetView(); root.entered = false; }

    Rectangle {
        id: panel
        anchors.fill: parent; anchors.margins: 6
        radius: 14; color: Theme.islandBg; border.color: Theme.purple; border.width: 1

        opacity: 0
        transform: Translate { id: slide; y: -10 }
        states: State { name: "open"; when: root.visible
            PropertyChanges { target: panel; opacity: 1 }
            PropertyChanges { target: slide; y: 0 } }
        transitions: Transition {
            NumberAnimation { target: panel; property: "opacity"; duration: 150; easing.type: Easing.OutCubic }
            NumberAnimation { target: slide; property: "y"; duration: 150; easing.type: Easing.OutCubic } }

        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered) { root.entered = true; closeTimer.stop(); }
                else if (root.entered) closeTimer.restart();
            }
        }

        Column {
            id: calCol
            anchors.fill: parent; anchors.margins: 14; spacing: 8

            Item {
                width: parent.width; height: Theme.clockPx + 4
                Text {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    text: "‹"; color: Theme.cyan; font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx
                    MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: root.prev() }
                }
                Text {
                    anchors.centerIn: parent
                    text: root.monthNames[root.viewMonth] + " " + root.viewYear
                    color: Theme.clockText; font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx
                }
                Text {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    text: "›"; color: Theme.cyan; font.family: Theme.monoFamily; font.pixelSize: Theme.clockPx
                    MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: root.next() }
                }
            }
            Rectangle { width: parent.width; height: 1; color: Theme.purple; opacity: 0.4 }

            Row {
                Repeater {
                    model: ["L","M","X","J","V","S","D"]
                    delegate: Text {
                        required property var modelData
                        width: root.cellW; horizontalAlignment: Text.AlignHCenter
                        text: modelData; color: Theme.muted
                        font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 3
                    }
                }
            }

            Grid {
                columns: 7
                Repeater {
                    model: root.daysGrid(root.viewYear, root.viewMonth)
                    delegate: Item {
                        required property var modelData
                        width: root.cellW; height: root.cellW
                        readonly property bool isToday: modelData === root.today.getDate()
                                                        && root.viewMonth === root.today.getMonth()
                                                        && root.viewYear === root.today.getFullYear()
                        Rectangle {
                            anchors.centerIn: parent
                            width: root.cellW - 4; height: width; radius: width / 2
                            visible: parent.isToday
                            color: Qt.rgba(34/255, 211/255, 238/255, 0.18)
                            border.color: Theme.cyan; border.width: 1
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: modelData > 0
                            text: modelData
                            color: parent.isToday ? Theme.cyan : Theme.textBase
                            font.family: Theme.monoFamily; font.pixelSize: Theme.fontPx - 1
                        }
                    }
                }
            }
        }
    }
}
