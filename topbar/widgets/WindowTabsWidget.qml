import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

ListView {
    id: windowTabsWidget
    
    // Dependencies
    required property var backend
    
    // Layout
    orientation: ListView.Horizontal
    spacing: 4
    clip: true
    
    // Filter windows for current workspace
    // Note: This relies on backend.windows and activeWorkspaceId notifying changes
    model: backend.windows.filter(w => w.workspaceId === backend.activeWorkspaceId || w.pinned)
    
    delegate: Item {
        // Tab dimensions
        width: 200
        height: Theme.barHeight - 8
        
        // Data from modelData (WindowModel object)
        property var window: modelData
        property bool isActive: window.focused
        
        // Tab Background
        Rectangle {
            anchors.fill: parent
            radius: 8
            
            color: {
                if (isActive) return Theme.tabActive
                if (hoverHandler.hovered) return Theme.tabHover
                return Theme.tabInactive
            }
            
            // Border for active tab
            border.width: isActive ? 1 : 0
            border.color: Qt.rgba(1, 1, 1, 0.1)
            
            // Animation
            Behavior on color { ColorAnimation { duration: 100 } }
            
            // Content Layout
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                // Icon (placeholder for now, using initial letter or color block if no icon)
                Rectangle {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    radius: 4
                    color: Theme.accent
                    
                    Text {
                        anchors.centerIn: parent
                        text: window.appId ? window.appId.charAt(0).toUpperCase() : "?"
                        font.pixelSize: 10
                        color: "#000"
                    }
                }
                
                // Title
                Text {
                    Layout.fillWidth: true
                    text: window.title
                    elide: Text.ElideRight
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                    opacity: isActive ? 1.0 : 0.8
                }
                
                // Close Button (visible on hover or active)
                Rectangle {
                    visible: hoverHandler.hovered || isActive
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    radius: 8
                    color: closeHover.hovered ? Theme.urgent : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: Theme.textPrimary
                        font.pixelSize: 14
                        lineHeight: 0.8
                    }
                    
                    HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                    
                    TapHandler {
                        onTapped: {
                            backend.closeWindow(window.address)
                        }
                    }
                }
            }
        }
        
        // Interactions
        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }
        
        TapHandler {
            onTapped: {
                backend.focusWindow(window.address)
            }
        }
    }
    
    // Smooth scrolling
    Behavior on contentX { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
}
