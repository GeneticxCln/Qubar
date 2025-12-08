import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

RowLayout {
    id: systemTrayWidget
    spacing: 6
    
    // Dependencies
    required property var backend
    property var sysInfo: backend.systemInfo
    
    signal settingsClicked()
    signal notificationClicked()
    
    // ═══════════════════════════════════════════════════════════
    // RESOURCE MONITOR
    // ═══════════════════════════════════════════════════════════
    ResourceWidget {
        backend: systemTrayWidget.backend
    }
    
    // Separator
    Rectangle { width: 1; height: 16; color: Theme.textDim; opacity: 0.3 }
    
    // ═══════════════════════════════════════════════════════════
    // NOTIFICATION BELL
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        color: bellHover.containsMouse ? Theme.tabHover : "transparent"
        radius: 6
        implicitWidth: 36
        implicitHeight: Theme.barHeight - 10
        Layout.alignment: Qt.AlignVCenter
        
        Behavior on color { ColorAnimation { duration: 100 } }
        
        Item {
            anchors.centerIn: parent
            width: 20
            height: 20
            
            Text {
                anchors.centerIn: parent
                text: "󰂚" // nf-md-bell
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                color: backend.notifications.unreadCount > 0 ? Theme.accent : Theme.textSecondary
            }
            
            // Unread badge
            Rectangle {
                visible: backend.notifications.unreadCount > 0
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -6
                anchors.topMargin: -4
                width: Math.max(14, badgeText.width + 4)
                height: 14
                radius: 7
                color: Theme.urgent
                
                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: backend.notifications.unreadCount > 99 ? "99+" : backend.notifications.unreadCount
                    color: "#ffffff"
                    font.pixelSize: 8
                    font.bold: true
                }
            }
        }
        
        MouseArea {
            id: bellHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: systemTrayWidget.notificationClicked()
        }
        
        ToolTip.visible: bellHover.containsMouse
        ToolTip.text: "Notifications"
        ToolTip.delay: 500
    }
    
    // ═══════════════════════════════════════════════════════════
    // NETWORK
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        color: networkHover.containsMouse ? Theme.tabHover : "transparent"
        radius: 6
        implicitWidth: networkRow.implicitWidth + 12
        implicitHeight: Theme.barHeight - 10
        Layout.alignment: Qt.AlignVCenter
        
        Behavior on color { ColorAnimation { duration: 100 } }
        
        RowLayout {
            id: networkRow
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                text: {
                    if (!sysInfo || !sysInfo.networkConnected) return "󰤭" // wifi-off
                    if (sysInfo.networkType === "wifi") return "󰤨" // wifi
                    if (sysInfo.networkType === "ethernet") return "󰈀" // ethernet
                    return "󰤫" // wifi-strength-4
                }
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                color: sysInfo && sysInfo.networkConnected ? Theme.textSecondary : Theme.urgent
            }
            
            Text {
                visible: sysInfo && sysInfo.networkConnected
                text: sysInfo ? (sysInfo.networkName || "Connected") : ""
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }
        }
        
        MouseArea {
            id: networkHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // BATTERY (Only if exists)
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        visible: sysInfo && sysInfo.hasBattery
        color: batteryHover.containsMouse ? Theme.tabHover : "transparent"
        radius: 6
        implicitWidth: batteryRow.implicitWidth + 12
        implicitHeight: Theme.barHeight - 10
        Layout.alignment: Qt.AlignVCenter
        
        Behavior on color { ColorAnimation { duration: 100 } }
        
        RowLayout {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                text: {
                    if (!sysInfo) return "󰁹"
                    if (sysInfo.charging) return "󰂄" // charging
                    if (sysInfo.batteryPercent > 90) return "󰁹"
                    if (sysInfo.batteryPercent > 70) return "󰂀"
                    if (sysInfo.batteryPercent > 50) return "󰁾"
                    if (sysInfo.batteryPercent > 30) return "󰁼"
                    if (sysInfo.batteryPercent > 10) return "󰁻"
                    return "󰂃" // alert
                }
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                color: {
                    if (!sysInfo) return Theme.textSecondary
                    if (sysInfo.batteryPercent <= 20 && !sysInfo.charging) return Theme.urgent
                    if (sysInfo.charging) return Theme.success
                    return Theme.textSecondary
                }
            }
            
            Text {
                text: sysInfo ? sysInfo.batteryPercent + "%" : ""
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }
        }
        
        MouseArea {
            id: batteryHover
            anchors.fill: parent
            hoverEnabled: true
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // CLOCK
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        color: clockHover.containsMouse ? Theme.tabHover : "transparent"
        radius: 6
        implicitWidth: clockRow.implicitWidth + 12
        implicitHeight: Theme.barHeight - 10
        Layout.alignment: Qt.AlignVCenter
        
        Behavior on color { ColorAnimation { duration: 100 } }
        
        RowLayout {
            id: clockRow
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: sysInfo ? sysInfo.date : ""
                color: Theme.textDim
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }
            
            Text {
                text: sysInfo ? sysInfo.time : "--:--"
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeNormal
                font.family: Theme.fontFamily
                font.bold: true
            }
        }
        
        MouseArea {
            id: clockHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: systemTrayWidget.settingsClicked()
        }
        
        ToolTip.visible: clockHover.containsMouse
        ToolTip.text: "Settings"
        ToolTip.delay: 500
    }
}
