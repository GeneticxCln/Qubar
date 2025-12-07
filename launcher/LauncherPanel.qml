import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../theme"
import "widgets"

PopupWindow {
    id: launcherPanel
    
    // Positioning
    anchor.window: topBar // Must be set
    anchor.on: Anchor.BottomLeft
    anchor.rect: AnchorRect.Selection
    
    width: 680
    height: 500
    
    // Visuals
    color: "transparent"
    
    // Dependencies
    required property var backend
    
    // Reset search on open
    onVisibleChanged: {
        if (visible) {
            searchBar.text = ""
            searchBar.forceActiveFocus()
        }
    }
    
    // Background
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        
        // Shadow (if supported)
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16
        
        // Search
        SearchBar {
            id: searchBar
            Layout.fillWidth: true
            
            onTextChanged: (text) => {
                backend.launcher.search(text)
            }
        }
        
        // Content
        AppGrid {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            backend: launcherPanel.backend
            
            onAppLaunched: {
                launcherPanel.visible = false
            }
        }
    }
    
    Component.onCompleted: console.log("[LauncherPanel] Loaded")
}
