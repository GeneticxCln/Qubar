import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../theme"
import "widgets"

PopupWindow {
    id: notificationPanel
    
    // Dependencies
    required property var backend
    
    // Positioning (slide from top-right)
    anchor {
        right: true
        top: true
    }
    
    margins {
        right: 10
        top: 50 // Below top bar
    }
    
    width: 400
    height: Math.min(600, contentColumn.implicitHeight + 40)
    
    visible: false
    
    // ═══════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function toggle() {
        visible = !visible
    }
    
    function show() {
        visible = true
    }
    
    function hide() {
        visible = false
    }
    
    // ═══════════════════════════════════════════════════════════
    // CONTENT
    // ═══════════════════════════════════════════════════════════
    
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.1, 0.1, 0.1, 0.95)
        radius: 12
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            // HEADER
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "Notifications"
                    color: Theme.textPrimary
                    font.pixelSize: 18
                    font.bold: true
                }
                
                // Unread badge
                Rectangle {
                    visible: backend.notifications.unreadCount > 0
                    width: 24
                    height: 20
                    radius: 10
                    color: Theme.accent
                    
                    Text {
                        anchors.centerIn: parent
                        text: backend.notifications.unreadCount
                        color: "#000"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Clear All button
                Rectangle {
                    visible: backend.notifications.notifications.length > 0
                    width: clearText.width + 16
                    height: 28
                    radius: 6
                    color: clearHover.hovered ? Qt.rgba(1, 0, 0, 0.2) : Qt.rgba(0.3, 0.3, 0.3, 0.5)
                    
                    Text {
                        id: clearText
                        anchors.centerIn: parent
                        text: "Clear All"
                        color: Theme.textPrimary
                        font.pixelSize: 11
                    }
                    
                    HoverHandler {
                        id: clearHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    
                    TapHandler {
                        onTapped: backend.notifications.dismissAll()
                    }
                }
            }
            
            // DND Toggle
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "🌙 Do Not Disturb"
                    color: Theme.textSecondary
                    font.pixelSize: 13
                }
                
                Item { Layout.fillWidth: true }
                
                Rectangle {
                    width: 44
                    height: 24
                    radius: 12
                    color: backend.notifications.doNotDisturb ? Theme.accent : Qt.rgba(0.3, 0.3, 0.3, 0.5)
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        x: backend.notifications.doNotDisturb ? parent.width - width - 2 : 2
                        y: 2
                        color: "#fff"
                        
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                    
                    TapHandler {
                        onTapped: backend.notifications.toggleDoNotDisturb()
                    }
                    
                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
            
            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
            }
            
            // NOTIFICATION LIST
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 200
                spacing: 10
                clip: true
                
                model: backend.notifications.notifications
                
                delegate: NotificationItem {
                    notification: modelData
                    
                    onDismissed: backend.notifications.dismiss(modelData.id)
                }
                
                // Scrollbar
                ScrollBar.vertical: ScrollBar {
                    width: 6
                    policy: ScrollBar.AsNeeded
                    
                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: 3
                        color: Theme.textDim
                        opacity: 0.5
                    }
                }
            }
            
            // EMPTY STATE
            ColumnLayout {
                visible: backend.notifications.notifications.length === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                spacing: 8
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "🔔"
                    font.pixelSize: 48
                    opacity: 0.3
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No notifications"
                    color: Theme.textDim
                    font.pixelSize: 14
                }
            }
        }
    }
}
