import QtQuick

Item {
    id: root
    property string text: ""
    property string family: "JetBrainsMono Nerd Font"
    property int    pixelSize: 140
    property int    weight: Font.ExtraBold
    property color  baseColor: "#b496ff"
    property color  warmColor: "#ff3b6b"
    property color  coolColor: "#3bf0ff"
    property real   chromaOffset: 2
    property real   chromaOpacity: 0.45
    property bool   raised: false

    property bool glitchEnabled: true
    property int  minInterval: 6000
    property int  maxInterval: 15000
    property int  startDelay: 2500
    property bool reduceMotion: false

    property real chroma: chromaOffset
    property real jitter: 0

    implicitWidth: mainTxt.implicitWidth
    implicitHeight: mainTxt.implicitHeight

    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -root.chroma + root.jitter
        text: root.text
        color: root.warmColor
        opacity: root.reduceMotion ? root.chromaOpacity * 0.6 : root.chromaOpacity
        font.family: root.family; font.pixelSize: root.pixelSize; font.weight: root.weight
    }
    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.chroma + root.jitter
        text: root.text
        color: root.coolColor
        opacity: root.reduceMotion ? root.chromaOpacity * 0.6 : root.chromaOpacity
        font.family: root.family; font.pixelSize: root.pixelSize; font.weight: root.weight
    }
    Text {
        id: mainTxt
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.jitter
        text: root.text
        color: root.baseColor
        font.family: root.family; font.pixelSize: root.pixelSize; font.weight: root.weight
        style: root.raised ? Text.Raised : Text.Normal
        styleColor: Qt.rgba(0, 0, 0, 0.4)
    }

    SequentialAnimation {
        id: burst
        ParallelAnimation {
            NumberAnimation { target: root; property: "chroma"; to: root.chromaOffset + 5; duration: 50 }
            NumberAnimation { target: root; property: "jitter"; to: -6; duration: 35 }
        }
        NumberAnimation { target: root; property: "jitter"; to: 5; duration: 35 }
        NumberAnimation { target: root; property: "jitter"; to: -3; duration: 35 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "chroma"; to: root.chromaOffset; duration: 60 }
            NumberAnimation { target: root; property: "jitter"; to: 0; duration: 45 }
        }
    }

    Timer {
        id: glitchTimer
        running: root.glitchEnabled && !root.reduceMotion
        interval: root.startDelay
        repeat: true
        onTriggered: {
            if (!burst.running) burst.start()
            interval = root.minInterval + Math.floor(Math.random() * (root.maxInterval - root.minInterval))
        }
    }
}
