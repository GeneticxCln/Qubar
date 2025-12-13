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
    model: (backend.windowList || []).filter(w => w.workspaceId === backend.activeWorkspaceId || w.pinned)
    
    delegate: Item {
        // Tab dimensions
        width: Math.min(200, windowTabsWidget.width / Math.max(1, windowTabsWidget.count))
        height: Theme.barHeight - 8
        
        // Data from modelData
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
            
            border.width: isActive ? 1 : 0
            border.color: Theme.hoverLight
            
            Behavior on color { ColorAnimation { duration: 100 } }
            
            // Content Layout
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                // Window Icon (real icon from icon backend)
                Item {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    
                    Image {
                        id: windowIcon
                        anchors.fill: parent
                        source: backend.icons ? backend.icons.getIcon(window.appId, 18) : ""
                        visible: status === Image.Ready && source != ""
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                    }
                    
                    // Fallback icon
                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: Theme.accent
                        visible: windowIcon.status !== Image.Ready || windowIcon.source == ""
                        
                        Text {
                            anchors.centerIn: parent
                            text: window.appId ? window.appId.charAt(0).toUpperCase() : "?"
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.background
                        }
                    }
                }
                
                // Title
                Text {
                    Layout.fillWidth: true
                    text: window.title || window.appId || "Window"
                    elide: Text.ElideRight
                    color: isActive ? Theme.textPrimary : Theme.textSecondary
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                    font.bold: isActive
                }
                
                // Close Button
                Rectangle {
                    visible: hoverHandler.hovered || isActive
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    radius: 9
                    color: closeHover.hovered ? Theme.urgent : Theme.hover
                    
                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: closeHover.hovered ? "#ffffff" : Theme.textPrimary
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    HoverHandler { 
                        id: closeHover
                        cursorShape: Qt.PointingHandCursor 
                    }
                    
                    TapHandler {
                        onTapped: backend.closeWindow(window.address)
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
            onTapped: backend.focusWindow(window.address)
        }
    }
    
    // Empty state
    Text {
        anchors.centerIn: parent
        visible: windowTabsWidget.count === 0
        text: "No windows"
        color: Theme.textDim
        font.pixelSize: Theme.fontSizeSmall
        font.family: Theme.fontFamily
    }
    
    // Smooth scrolling
    Behavior on contentX { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
}
