import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../theme"
import "widgets"

PanelWindow {
    id: overviewPanel
    
    // Full Screen Overlay
    anchors.fill: true
    color: "transparent"
    
    // Exclusion mode: Ignore, so it overlays everything
    exclusionMode: ExclusionMode.Ignore
    
    // Layering: Top
    layer: Layer.Overlay
    
    // Visibility
    visible: backend.overview.visible
    
    // Dependencies
    required property var backend
    
    // Close on click outside (background)
    TapHandler {
        onTapped: backend.overview.hide()
    }
    
    // ═══════════════════════════════════════════════════════════
    // BACKGROUND & BLUR
    // ═══════════════════════════════════════════════════════════
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.85) // Dark overlay
        
        // Prevent clicks from passing through
        TapHandler {} 
    }
    
    // ═══════════════════════════════════════════════════════════
    // CONTENT
    // ═══════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 40
        
        // 1. SEARCH BAR (Top Center)
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            
            Rectangle {
                anchors.centerIn: parent
                width: 400
                height: 50
                radius: 25
                color: Qt.rgba(0.2, 0.2, 0.2, 0.5)
                border.width: 1
                border.color: input.activeFocus ? Theme.accent : "transparent"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 12
                    
                    Text { text: "🔍"; color: Theme.textSecondary; font.pixelSize: 16 }
                    
                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        text: backend.overview.searchQuery
                        color: Theme.textPrimary
                        font.pixelSize: 16
                        // Placeholder
                        Text { visible: !parent.text; text: "Search apps or windows..."; color: Theme.textDim }
                        
                        onTextChanged: backend.overview.search(text)
                        
                        // Focus handling
                        Keys.onEscapePressed: backend.overview.hide()
                    }
                }
            }
        }
        
        // 2. WORKSPACE GRID (5x2)
        // Only visible if not searching
        GridLayout {
            visible: !input.text
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 1600
            Layout.maximumHeight: 700
            
            columns: 5
            rowSpacing: 20
            columnSpacing: 20
            
            Repeater {
                model: 10 // 10 workspaces
                
                WorkspaceTile {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    backend: overviewPanel.backend // Pass backend down
                    property int wsId: index + 1
                    workspaceId: wsId
                    windows: backend.overview.workspaceWindows[wsId] || []
                    active: backend.activeWorkspaceId === wsId
                    
                    onClicked: backend.overview.switchToWorkspace(wsId)
                }
            }
        }
        
        // 3. SEARCH RESULTS (List)
        // Visible when searching
        ListView {
            visible: !!input.text
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 800
            clip: true
            spacing: 8
            
            model: backend.overview.searchResults
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 60
                color: hoverHandler.hovered ? Theme.tabHover : Qt.rgba(0.2, 0.2, 0.2, 0.5)
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 16
                    
                    // Icon
                    Rectangle {
                        width: 32; height: 32; radius: 16; color: Theme.accent
                        Text { anchors.centerIn: parent; text: modelData.icon ? modelData.icon.charAt(0).toUpperCase() : "?" }
                    }
                    
                    ColumnLayout {
                        spacing: 2
                        Text { text: modelData.name; color: Theme.textPrimary; font.bold: true }
                        Text { text: modelData.type === "window" ? "Window" : "Application"; color: Theme.textSecondary; font.pixelSize: 10 }
                    }
                }
                
                HoverHandler { id: hoverHandler; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: backend.overview.activateResult(modelData)
                }
            }
        }
    }
    
    // Focus hooks
    onVisibleChanged: {
        if (visible) {
            input.forceActiveFocus()
        }
    }
}
