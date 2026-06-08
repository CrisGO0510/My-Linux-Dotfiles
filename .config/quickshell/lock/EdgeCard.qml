import QtQuick
import QtQuick.Shapes

Item {
    id: card

    property string corner: "bottomleft"
    property real radius: 22
    property real flare: 26
    property color fillColor: Qt.rgba(0.12, 0.04, 0.20, 0.55)
    property color strokeColor: Qt.rgba(0.47, 0.31, 0.70, 0.55)
    property real strokeWidth: 2

    readonly property bool mirror: corner === "bottomright"

    Shape {
        anchors.fill: parent
        antialiasing: true
        transform: Scale { xScale: card.mirror ? -1 : 1; origin.x: card.width / 2 }

        ShapePath {
            fillColor: card.fillColor
            strokeColor: card.strokeColor
            strokeWidth: card.strokeWidth
            joinStyle: ShapePath.RoundJoin

            readonly property real w: card.width
            readonly property real h: card.height
            readonly property real r: card.radius
            readonly property real f: card.flare

            startX: 0; startY: h
            PathLine { x: 0; y: card.flare }
            PathArc {
                x: card.flare; y: 0
                radiusX: card.flare; radiusY: card.flare
                direction: PathArc.Counterclockwise
            }
            PathLine { x: card.width - card.radius; y: 0 }
            PathArc {
                x: card.width; y: card.radius
                radiusX: card.radius; radiusY: card.radius
                direction: PathArc.Clockwise
            }
            PathLine { x: card.width; y: card.height - card.flare }
            PathArc {
                x: card.width - card.flare; y: card.height
                radiusX: card.flare; radiusY: card.flare
                direction: PathArc.Counterclockwise
            }
            PathLine { x: 0; y: card.height }
        }
    }
}
