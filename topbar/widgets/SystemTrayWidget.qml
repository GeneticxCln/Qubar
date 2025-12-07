import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

RowLayout {
    id: systemTrayWidget
    spacing: 8
    
    // Dependencies
    required property var backend
    property var sysInfo: backend.systemInfoData
    
    signal settingsClicked()
    
    // Interaction for whole tray
    TapHandler {
        onTapped: systemTrayWidget.settingsClicked()
    }
    
    // ═══════════════════════════════════════════════════════════
    
    // ═══════════════════════════════════════════════════════════
    // NETWORK
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        color: networkHover.hovered ? Theme.tabHover : "transparent"
        radius: 4
        implicitWidth: networkRow.implicitWidth + 16
        implicitHeight: Theme.barHeight - 12
        Layout.alignment: Qt.AlignVCenter
        
        Behavior on color { ColorAnimation { duration: 150 } }
        HoverHandler { id: networkHover }
        
        RowLayout {
            id: networkRow
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: sysInfo.networkType === "wifi" ? "📶" : (sysInfo.networkType === "ethernet" ? "🔌" : "⚠️")
                color: sysInfo.networkConnected ? Theme.textPrimary : Theme.urgent
                font.pixelSize: Theme.fontSizeNormal
            }
            
            Text {
                text: sysInfo.networkConnected ? (sysInfo.networkName || "Connected") : "Offline"
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // BATTERY (Only if battery exists)
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        visible: sysInfo.hasBattery
        color: batteryHover.hovered ? Theme.tabHover : "transparent"
        radius: 4
        implicitWidth: batteryRow.implicitWidth + 16
        implicitHeight: Theme.barHeight - 12
        Layout.alignment: Qt.AlignVCenter
        
        Behavior on color { ColorAnimation { duration: 150 } }
        HoverHandler { id: batteryHover }
        
        RowLayout {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: sysInfo.charging ? "⚡" : (sysInfo.batteryPercent > 20 ? "🔋" : "🪫")
                color: sysInfo.batteryPercent <= 20 && !sysInfo.charging ? Theme.urgent : Theme.textPrimary
                font.pixelSize: Theme.fontSizeNormal
            }
            
            Text {
                text: sysInfo.batteryPercent + "%"
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // CLOCK
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        color: clockHover.hovered ? Theme.tabHover : "transparent"
        radius: 4
        implicitWidth: clockRow.implicitWidth + 16
        implicitHeight: Theme.barHeight - 12
        Layout.alignment: Qt.AlignVCenter
        
        Behavior on color { ColorAnimation { duration: 150 } }
        HoverHandler { id: clockHover }
        
        RowLayout {
            id: clockRow
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: sysInfo.date
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }
            
            Text {
                text: sysInfo.time
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeNormal
                font.family: Theme.fontFamily
                font.bold: true
            }
        }
    }
}
