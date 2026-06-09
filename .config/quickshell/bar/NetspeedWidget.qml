import QtQuick

Text {
    function fmt(kb) {
        if (kb >= 1024) return (kb / 1024).toFixed(1) + " MB/s";
        return Math.round(kb) + " KB/s";
    }
    text: "↓ " + fmt(Sys.netDown) + "  ↑ " + fmt(Sys.netUp)
    font.family: Theme.monoFamily
    font.pixelSize: Theme.fontPx
    color: Theme.textBase
}
