import QtQuick

Item {
    id: root
    property real scanlineOpacity: 0.12
    property real grainStrength: 0.05
    property int  grainFps: 14
    property int  rollDuration: 7000
    property bool active: true
    property bool reduceMotion: false

    visible: active

    Item {
        anchors.fill: parent
        clip: true
        Image {
            id: scan
            source: "file:///home/cris/dotfiles/assets/fx/scanlines.png"
            fillMode: Image.Tile
            width: parent.width
            height: parent.height + 3
            opacity: root.scanlineOpacity
            NumberAnimation on y {
                running: root.active && !root.reduceMotion && root.rollDuration > 0
                from: -3; to: 0; duration: root.rollDuration; loops: Animation.Infinite
            }
        }
    }

    Item {
        anchors.fill: parent
        clip: true
        Image {
            id: grain
            source: "file:///home/cris/dotfiles/assets/fx/noise.png"
            fillMode: Image.Tile
            width: parent.width + 256
            height: parent.height + 256
            opacity: Math.min(0.3, root.grainStrength * 2.4)
        }
        Timer {
            running: root.active && !root.reduceMotion && root.grainStrength > 0
            interval: Math.max(40, Math.round(1000 / Math.max(1, root.grainFps)))
            repeat: true
            onTriggered: {
                grain.x = -Math.floor(Math.random() * 256)
                grain.y = -Math.floor(Math.random() * 256)
            }
        }
    }
}
