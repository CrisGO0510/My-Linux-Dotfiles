import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Services.Mpris

FocusScope {
    id: content
    focus: true

    signal authSucceeded()

    property bool preview: false

    Keys.onEscapePressed: if (content.preview) Qt.quit()

    property string avatar:     "/home/cris/dotfiles/assets/hoshino_ai.png"
    property color  accent:     "#b496ff"
    property color  accentSoft: "#c8aaff"
    property color  cardBg:     Qt.rgba(0.12, 0.04, 0.20, 0.55)
    property color  cardBorder: Qt.rgba(0.47, 0.31, 0.70, 0.55)
    property real   cornerSize:    380
    property real   cornerOpacity: 0.5

    property real intensity: 0.5
    property bool reduceMotion: false
    readonly property real fx: intensity / 0.5
    property real glowPulse: 0.28

    property string errorMsg: ""
    property string passwordBuffer: ""
    property var    now: new Date()

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: content.now = new Date()
    }

    PamContext {
        id: pam
        config: "login"
        onResponseRequiredChanged: if (responseRequired) respond(content.passwordBuffer)
        onCompleted: (result) => {
            if (result === PamResult.Success) {
                content.authSucceeded()
            } else {
                content.errorMsg = "Contraseña incorrecta"
                content.passwordBuffer = ""
                pwInput.text = ""
            }
        }
    }
    function submitPassword(pw) {
        if (pam.active || pw.length === 0) return
        content.errorMsg = ""
        content.passwordBuffer = pw
        pam.start()
    }

    property string wxIcon: ""
    property string wxTemp: ""
    property string wxCond: ""
    Process {
        id: wxProc
        command: ["bash", "-c", "/home/cris/dotfiles/Scripts/hypr/lock-weather.sh line"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("\t")
                if (parts.length >= 3) {
                    content.wxIcon = parts[0].trim()
                    content.wxTemp = parts[1].trim()
                    content.wxCond = parts[2].trim()
                }
            }
        }
    }
    Timer {
        interval: 900000; running: true; repeat: true
        onTriggered: wxProc.running = true
    }

    readonly property var activePlayer: {
        const list = Mpris.players ? Mpris.players.values : []
        for (let i = 0; i < list.length; i++)
            if (list[i].isPlaying) return list[i]
        return list.length ? list[0] : null
    }

    Rectangle {
        id: frame
        anchors.fill: parent
        color: Qt.rgba(0.10, 0.04, 0.18, 0.30)
        opacity: 0

        Vignette {
            anchors.fill: parent
            vignetteStrength: Math.min(0.70, 0.45 * content.fx)
        }

        EyeImage {
            id: eyeLayer
            anchors.fill: parent
            active: true
            eyesOpacity: content.fx
            reduceMotion: content.reduceMotion
            opacity: 0
        }

        Image {
            source: "file:///home/cris/dotfiles/assets/fx/corner.png"
            anchors.top: parent.top
            anchors.left: parent.left
            width: content.cornerSize
            height: width * 505 / 540
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
            opacity: content.cornerOpacity
            z: 5
        }
        Image {
            source: "file:///home/cris/dotfiles/assets/fx/corner.png"
            anchors.top: parent.top
            anchors.right: parent.right
            width: content.cornerSize
            height: width * 505 / 540
            fillMode: Image.PreserveAspectFit
            mirror: true
            smooth: true
            asynchronous: true
            opacity: content.cornerOpacity
            z: 5
        }

        Column {
            id: contentCol
            z: 10
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -40
            spacing: 6

            Item {
                id: clockBox
                anchors.horizontalCenter: parent.horizontalCenter
                width: clockGlitch.implicitWidth
                height: clockGlitch.implicitHeight

                RectangularGlow {
                    anchors.centerIn: parent
                    width: parent.width * 0.95
                    height: parent.height * 0.70
                    glowRadius: 46
                    spread: 0.18
                    cornerRadius: 40
                    color: Qt.rgba(0.706, 0.588, 1.0,
                                   content.reduceMotion ? 0.22 : content.glowPulse)
                }
                GlitchText {
                    id: clockGlitch
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(content.now, "HH:mm")
                    pixelSize: 140
                    weight: Font.ExtraBold
                    baseColor: content.accent
                    raised: true
                    chromaOffset: Math.min(5, 2 * content.fx)
                    reduceMotion: content.reduceMotion
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(content.now, "dddd, dd MMMM yyyy")
                color: content.accentSoft
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 22
                bottomPadding: 30
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Welcome back, " + Quickshell.env("USER")
                color: content.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                font.weight: Font.Bold
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: pam.active ? "Verificando…" : "Logging in to Hyprland"
                color: content.accentSoft
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                bottomPadding: 12
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 300; height: 52; radius: 24
                color: Qt.rgba(0.12, 0.04, 0.20, 0.55)
                border.width: 2
                border.color: pwInput.activeFocus ? content.accent : content.cardBorder

                TextInput {
                    id: pwInput
                    anchors.fill: parent
                    anchors.leftMargin: 22; anchors.rightMargin: 22
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    color: content.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    focus: true
                    enabled: !pam.active
                    onAccepted: content.submitPassword(text)
                }
                Text {
                    anchors.centerIn: parent
                    visible: pwInput.text.length === 0
                    text: "Contraseña…"
                    color: Qt.rgba(0.78, 0.67, 1.0, 0.5)
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    font.italic: true
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: content.errorMsg
                visible: content.errorMsg.length > 0
                color: "#ff8090"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                topPadding: 6
            }
        }

        Item {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: 300; height: 112

            EdgeCard {
                anchors.fill: parent
                corner: "bottomleft"
                fillColor: content.cardBg
                strokeColor: content.cardBorder
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -4
                spacing: 16
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: content.wxIcon
                    color: content.accentSoft
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 38
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: content.wxTemp
                        color: content.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                    }
                    Text {
                        text: content.wxCond
                        color: content.accentSoft
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                    }
                }
            }
        }

        Item {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 372; height: 116
            visible: content.activePlayer !== null

            EdgeCard {
                anchors.fill: parent
                corner: "bottomright"
                fillColor: content.cardBg
                strokeColor: content.cardBorder
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 26
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -4
                layoutDirection: Qt.RightToLeft
                spacing: 14

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 64; height: 64; radius: 32
                    color: "transparent"
                    border.width: 2; border.color: content.cardBorder
                    clip: true
                    Image {
                        id: artImg
                        anchors.fill: parent
                        anchors.margins: 2
                        fillMode: Image.PreserveAspectCrop
                        cache: false
                        source: {
                            const p = content.activePlayer
                            return (p && p.trackArtUrl && p.trackArtUrl.length > 0)
                                ? p.trackArtUrl
                                : "file://" + content.avatar
                        }
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 250
                    spacing: 3
                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                        text: content.activePlayer ? content.activePlayer.trackTitle : ""
                        color: content.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                    }
                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                        text: {
                            const p = content.activePlayer
                            if (!p) return ""
                            const glyph = p.isPlaying ? "󰐊" : "󰏤"
                            return glyph + "  " + (p.trackArtist || "")
                        }
                        color: content.accentSoft
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                }
            }
        }

        Scanlines {
            id: scanlines
            anchors.fill: parent
            z: 30
            active: true
            scanlineOpacity: Math.min(0.20, 0.12 * content.fx)
            grainStrength: 0.05 * content.fx
            grainFps: 14
            rollDuration: 7000
            reduceMotion: content.reduceMotion
            opacity: 0
        }
    }

    Component.onCompleted: {
        introAnim.start()
        eyesFade.start()
        scanFade.start()
        if (!content.reduceMotion) glowAnim.start()
        pwInput.forceActiveFocus()
    }
    NumberAnimation {
        id: introAnim
        target: frame; property: "opacity"
        from: 0; to: 1; duration: 450; easing.type: Easing.OutCubic
    }
    SequentialAnimation {
        id: eyesFade
        PauseAnimation { duration: 250 }
        NumberAnimation { target: eyeLayer; property: "opacity"; from: 0; to: 1; duration: 600; easing.type: Easing.OutCubic }
    }
    SequentialAnimation {
        id: scanFade
        PauseAnimation { duration: 400 }
        NumberAnimation { target: scanlines; property: "opacity"; from: 0; to: 1; duration: 500; easing.type: Easing.OutCubic }
    }
    SequentialAnimation {
        id: glowAnim
        loops: Animation.Infinite
        NumberAnimation { target: content; property: "glowPulse"; from: 0.22; to: 0.32; duration: 4000; easing.type: Easing.InOutSine }
        NumberAnimation { target: content; property: "glowPulse"; from: 0.32; to: 0.22; duration: 4000; easing.type: Easing.InOutSine }
    }
}
