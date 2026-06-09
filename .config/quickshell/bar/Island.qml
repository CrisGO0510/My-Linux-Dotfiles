import QtQuick

// Cápsula translúcida con borde + glow morado y scanlines sutiles.
// Uso: Island { Row { ... } }  -> el contenido se mide solo.
Rectangle {
    id: root
    default property alias content: inner.data

    implicitWidth: inner.implicitWidth + Theme.islandPadH * 2
    implicitHeight: Theme.barHeight - 8
    radius: Theme.radius
    color: Theme.islandBg
    border.color: Theme.purple
    border.width: 1

    // glow morado
    layer.enabled: true

    Row {
        id: inner
        anchors.centerIn: parent
        spacing: Theme.islandGap
    }

    // scanlines sutiles
    Canvas {
        anchors.fill: parent
        opacity: 0.06
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = "#ffffff";
            ctx.lineWidth = 1;
            for (let y = 0; y < height; y += 3) {
                ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
            }
        }
    }
}
