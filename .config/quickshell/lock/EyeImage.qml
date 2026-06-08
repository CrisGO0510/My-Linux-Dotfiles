import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: field
    property real eyesOpacity: 1.0
    property bool active: true
    property bool reduceMotion: false
    property real baseOpacity: 0.22
    property int  fillMode: Image.PreserveAspectCrop

    visible: active
    clip: true

    Item {
        id: drifter
        anchors.fill: parent
        transform: [
            Translate { id: driftT },
            Scale {
                id: breath; xScale: 1; yScale: 1
                origin.x: field.width / 2; origin.y: field.height / 2
            }
        ]

        Image {
            id: img
            anchors.centerIn: parent
            width: field.width * 1.12
            height: field.height * 1.12
            source: "file:///home/cris/dotfiles/assets/fx/eyes.png"
            fillMode: field.fillMode
            opacity: Math.min(0.40, field.baseOpacity * field.eyesOpacity)
            smooth: true
            asynchronous: true
            layer.enabled: true
            layer.effect: GaussianBlur { radius: 5; samples: 11 }
        }
    }

    SequentialAnimation {
        running: field.active && !field.reduceMotion
        loops: Animation.Infinite
        ParallelAnimation {
            NumberAnimation { target: driftT; property: "x"; from: -18; to: 18;  duration: 22000; easing.type: Easing.InOutSine }
            NumberAnimation { target: driftT; property: "y"; from: 10;  to: -10; duration: 18000; easing.type: Easing.InOutSine }
        }
        ParallelAnimation {
            NumberAnimation { target: driftT; property: "x"; from: 18;  to: -18; duration: 22000; easing.type: Easing.InOutSine }
            NumberAnimation { target: driftT; property: "y"; from: -10; to: 10;  duration: 18000; easing.type: Easing.InOutSine }
        }
    }
    SequentialAnimation {
        running: field.active && !field.reduceMotion
        loops: Animation.Infinite
        NumberAnimation { target: breath; properties: "xScale,yScale"; from: 1.0;  to: 1.04; duration: 9000; easing.type: Easing.InOutSine }
        NumberAnimation { target: breath; properties: "xScale,yScale"; from: 1.04; to: 1.0;  duration: 9000; easing.type: Easing.InOutSine }
    }
}
