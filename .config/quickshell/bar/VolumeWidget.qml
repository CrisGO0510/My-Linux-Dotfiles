import QtQuick
import Quickshell.Services.Pipewire

MouseArea {
    id: root
    // necesario para que volume/muted sean válidos
    PwObjectTracker { objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : [] }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int pct: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton
    onClicked: if (sink && sink.audio) sink.audio.muted = !sink.audio.muted
    onWheel: (wheel) => {
        if (!sink || !sink.audio) return;
        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
        sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + step));
    }

    function volIcon(p, m) {
        if (m || p === 0) return "󰝟";   // silencio
        if (p < 34) return "󰕿";          // bajo
        if (p < 67) return "󰖀";          // medio
        return "󰕾";                       // alto
    }

    Text {
        id: icon
        text: root.volIcon(root.pct, root.muted)
        color: root.muted ? Theme.muted : Theme.textBase
        font.family: Theme.monoFamily
        font.pixelSize: Theme.clockPx
    }

    HoverHandler { id: hh }

    NeonTooltip {
        visible: hh.hovered
        text: root.muted ? "silenciado" : "volumen " + root.pct + "%"
    }
}
