import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property real vignetteStrength: 0.45
    property color vignetteColor: Qt.rgba(0.02, 0.0, 0.06, 1.0)
    property color tintColor: Qt.rgba(0.45, 0.20, 0.65, 1.0)
    property real tintStrength: 0.05

    layer.enabled: true

    RadialGradient {
        anchors.fill: parent
        horizontalRadius: width * 0.60
        verticalRadius: height * 0.60
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(root.tintColor.r, root.tintColor.g, root.tintColor.b, root.tintStrength) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    RadialGradient {
        anchors.fill: parent
        horizontalRadius: width * 0.72
        verticalRadius: height * 0.72
        gradient: Gradient {
            GradientStop { position: 0.00; color: "transparent" }
            GradientStop { position: 0.55; color: "transparent" }
            GradientStop { position: 1.00; color: Qt.rgba(root.vignetteColor.r, root.vignetteColor.g, root.vignetteColor.b, root.vignetteStrength) }
        }
    }
}
