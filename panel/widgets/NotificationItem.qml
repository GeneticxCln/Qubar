import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

Rectangle {
    id: notificationItem
    
    // Properties
    required property var notification // {id, app, summary, body, icon, time, read}
    
    signal dismissed()
    
    // Visuals
    width: parent.width
    height: contentLayout.height + 20
    color: notification.read ? Qt.rgba(0.15, 0.15, 0.15, 0.5) : Qt.rgba(0.2, 0.2, 0.2, 0.7)
    radius: 8
    border.width: hoverHandler.hovered ? 1 : 0
    border.color: Theme.accent
    
    Behavior on color { ColorAnimation { duration: 150 } }
    
    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12
        
        // Icon/Avatar
        Rectangle {
            Layout.alignment: Qt.AlignTop
            width: 40
            height: 40
            radius: 20
            color: Theme.accent
            
            Text {
                anchors.centerIn: parent
                text: notification.app ? notification.app.charAt(0).toUpperCase() : "?"
                color: "#000"
                font.pixelSize: 18
                font.bold: true
            }
        }
        
        // Content
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            
            // Header (App Name + Time)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: notification.app || "Unknown"
                    color: Theme.textPrimary
                    font.pixelSize: 11
                    font.bold: true
                }
                
                Text {
                    Layout.fillWidth: true
                    text: formatTime(notification.time)
                    color: Theme.textDim
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignRight
                }
            }
            
            // Summary
            Text {
                Layout.fillWidth: true
                text: notification.summary || ""
                color: Theme.textPrimary
                font.pixelSize: 13
                font.bold: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            
            // Body
            Text {
                visible: notification.body && notification.body.length > 0
                Layout.fillWidth: true
                text: notification.body || ""
                color: Theme.textSecondary
                font.pixelSize: 11
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }
        }
        
        // Dismiss Button
        Rectangle {
            Layout.alignment: Qt.AlignTop
            width: 24
            height: 24
            radius: 12
            color: dismissHover.hovered ? Qt.rgba(1, 0, 0, 0.3) : "transparent"
            
            Text {
                anchors.centerIn: parent
                text: "×"
                color: Theme.textPrimary
                font.pixelSize: 18
                font.bold: true
            }
            
            HoverHandler {
                id: dismissHover
                cursorShape: Qt.PointingHandCursor
            }
            
            TapHandler {
                onTapped: notificationItem.dismissed()
            }
        }
    }
    
    HoverHandler {
        id: hoverHandler
    }
    
    // Helper function
    function formatTime(timestamp) {
        var now = Date.now()
        var diff = now - timestamp
        
        // Less than a minute
        if (diff < 60000) return "now"
        
        // Minutes
        if (diff < 3600000) {
            var mins = Math.floor(diff / 60000)
            return mins + "m ago"
        }
        
        // Hours
        if (diff < 86400000) {
            var hours = Math.floor(diff / 3600000)
            return hours + "h ago"
        }
        
        // Days
        var days = Math.floor(diff / 86400000)
        return days + "d ago"
    }
}
