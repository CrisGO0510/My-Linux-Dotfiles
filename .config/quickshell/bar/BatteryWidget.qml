import QtQuick
import Quickshell.Services.UPower

Item {
    id: root
    readonly property var dev: UPower.displayDevice

    // En el desktop no hay bateria: UPower igual expone un displayDevice, asi
    // que sin este chequeo el widget se queda con el icono de bateria vacia.
    // Si la version de Quickshell no trae isLaptopBattery caemos al porcentaje,
    // que en una maquina sin bateria es 0.
    readonly property bool present: {
        if (!dev) return false;
        if (dev.isLaptopBattery !== undefined) return dev.isLaptopBattery;
        return dev.percentage > 0;
    }

    readonly property int pct: dev ? Math.round(dev.percentage * 100) : 0
    readonly property bool charging: dev ? (dev.state === UPowerDeviceState.Charging) : false

    // tiempo estimado (s): primero UPower; si reporta 0, lo calculo de energy/changeRate
    readonly property real secs: {
        if (!dev) return 0;
        var t = charging ? dev.timeToFull : dev.timeToEmpty;
        if (t > 0) return t;
        if (dev.changeRate && Math.abs(dev.changeRate) > 0.01)
            return dev.energy / Math.abs(dev.changeRate) * 3600;
        return 0;
    }

    visible: root.present
    implicitWidth: root.present ? icon.implicitWidth : 0
    implicitHeight: icon.implicitHeight

    function batIcon(p, ch) {
        if (ch) return "󰂄";
        if (p >= 95) return "󰁹";
        if (p >= 85) return "󰂂";
        if (p >= 75) return "󰂁";
        if (p >= 65) return "󰂀";
        if (p >= 55) return "󰁿";
        if (p >= 45) return "󰁾";
        if (p >= 35) return "󰁽";
        if (p >= 25) return "󰁼";
        if (p >= 15) return "󰁻";
        return "󰁺";
    }
    function fmtTime(s) {
        if (!s || s <= 0) return "";
        const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60);
        return (h > 0 ? h + "h " : "") + m + "m";
    }

    Text {
        id: icon
        anchors.centerIn: parent
        text: root.batIcon(root.pct, root.charging)
        color: root.pct <= 15 && !root.charging ? Theme.alert : Theme.textBase
        font.family: Theme.monoFamily
        font.pixelSize: Theme.clockPx
    }

    HoverHandler { id: hh }

    NeonTooltip {
        visible: hh.hovered
        text: root.pct + "%"
              + (root.fmtTime(root.secs)
                 ? "  ·  " + (root.charging ? "llena en " : "") + root.fmtTime(root.secs) + (root.charging ? "" : " restante")
                 : (root.charging ? "  ·  cargando" : ""))
    }
}
