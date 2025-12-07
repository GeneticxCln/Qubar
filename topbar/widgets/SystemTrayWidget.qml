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
    signal notificationClicked()
    
    // Interaction for whole tray
    TapHandler {
        onTapped: systemTrayWidget.settingsClicked()
    }
    
    // ═══════════════════════════════════════════════════════════
    
    
    // ═══════════════════════════════════════════════════════════
    // NOTIFICATION BELL
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        color: bellHover.hovered ? Theme.tabHover : "transparent"
        radius: 4
        implicitWidth: 48
        implicitHeight: Theme.barHeight - 12
        Layout.alignment: Qt.AlignVCenter
        
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Item {
            anchors.centerIn: parent
            width: 24
            height: 24
            
            Text {
                anchors.centerIn: parent
                text: "🔔"
                font.pixelSize: 16
                opacity: backend.notifications.notifications.length > 0 ? 1.0 : 0.5
            }
            
            // Unread badge
            Rectangle {
                visible: backend.notifications.unreadCount > 0
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -4
                anchors.topMargin: -4
                width: Math.max(16, badgeText.width + 6)
                height: 16
                radius: 8
                color: Theme.accent
                
                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: backend.notifications.unreadCount > 99 ? "99+" : backend.notifications.unreadCount
                    color: "#000"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }
        
        HoverHandler { 
            id: bellHover
            cursorShape: Qt.PointingHandCursor 
        }
        
        TapHandler {
            onTapped: {
                systemTrayWidget.notificationClicked()
                mouse.accepted = true
            }
        }
    }
    
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
