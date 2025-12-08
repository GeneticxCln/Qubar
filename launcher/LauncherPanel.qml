import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../theme"
import "widgets"

PopupWindow {
    id: launcherPanel
    
    // Positioning - centered on screen
    anchor.window: topBar
    anchor.on: Anchor.Center
    anchor.rect: AnchorRect.Window
    
    width: 640
    height: 400
    
    // Visuals
    color: "transparent"
    
    // Dependencies
    required property var backend
    
    // Active category
    property string activeCategory: "all"
    
    // Categories
    readonly property var categories: [
        { id: "all", icon: "🏠", label: "All" },
        { id: "favorites", icon: "⭐", label: "Favorites" },
        { id: "terminal", icon: "💻", label: "Terminal" },
        { id: "files", icon: "📁", label: "Files" },
        { id: "settings", icon: "⚙️", label: "Settings" }
    ]
    
    // Reset on open
    onVisibleChanged: {
        if (visible) {
            searchInput.text = ""
            searchInput.forceActiveFocus()
            activeCategory = "all"
        }
    }
    
    // Close on Escape
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            launcherPanel.visible = false
            event.accepted = true
        }
    }
    
    // Main container
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: 12
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.15)
        
        // Gradient overlay
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0
            
            // ═══════════════════════════════════════════════════════════
            // TOP BAR - Category tabs + Search
            // ═══════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: Qt.rgba(0, 0, 0, 0.3)
                
                // Top radius only
                radius: 12
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.radius
                    color: parent.color
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 12
                    spacing: 0
                    
                    // Category tabs
                    Repeater {
                        model: launcherPanel.categories
                        
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 36
                            radius: 6
                            
                            property bool isActive: launcherPanel.activeCategory === modelData.id
                            
                            color: isActive ? Theme.selection : (tabHover.containsMouse ? Theme.hoverLight : "transparent")
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.pixelSize: 16
                            }
                            
                            MouseArea {
                                id: tabHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    launcherPanel.activeCategory = modelData.id
                                    backend.launcher.filterByCategory(modelData.id)
                                }
                            }
                            
                            ToolTip.visible: tabHover.containsMouse
                            ToolTip.text: modelData.label
                            ToolTip.delay: 500
                        }
                    }
                    
                    // Separator
                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 24
                        Layout.leftMargin: 8
                        color: Qt.rgba(1, 1, 1, 0.2)
                    }
                    
                    // Search icon
                    Text {
                        Layout.leftMargin: 12
                        text: "🔍"
                        font.pixelSize: 14
                        opacity: 0.7
                    }
                    
                    // Search input
                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        color: Theme.textPrimary
                        font.pixelSize: 14
                        font.family: Theme.fontFamily
                        selectByMouse: true
                        
                        Text {
                            anchors.fill: parent
                            text: "Search"
                            color: Theme.textDim
                            visible: !searchInput.text && !searchInput.activeFocus
                        }
                        
                        onTextChanged: backend.launcher.search(text)
                        
                        Keys.onDownPressed: appList.incrementCurrentIndex()
                        Keys.onUpPressed: appList.decrementCurrentIndex()
                        Keys.onReturnPressed: {
                            if (appList.currentIndex >= 0) {
                                var app = backend.launcher.filteredApps[appList.currentIndex]
                                if (app) {
                                    backend.launcher.launch(app)
                                    launcherPanel.visible = false
                                }
                            }
                        }
                    }
                }
            }
            
            // ═══════════════════════════════════════════════════════════
            // APP LIST - 2 columns
            // ═══════════════════════════════════════════════════════════
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 8
                
                // Two-column layout
                RowLayout {
                    anchors.fill: parent
                    spacing: 4
                    
                    // Left column
                    ListView {
                        id: appList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        model: backend.launcher.filteredApps
                        currentIndex: 0
                        keyNavigationEnabled: true
                        
                        delegate: AppListItem {
                            width: appList.width
                            index: model.index
                            appData: modelData
                            backend: launcherPanel.backend
                            isSelected: appList.currentIndex === model.index
                            
                            onClicked: {
                                appList.currentIndex = model.index
                            }
                            
                            onLaunched: {
                                backend.launcher.launch(modelData)
                                launcherPanel.visible = false
                            }
                        }
                        
                        // Smooth scrolling
                        ScrollBar.vertical: ScrollBar {
                            width: 4
                            policy: ScrollBar.AsNeeded
                            
                            contentItem: Rectangle {
                                implicitWidth: 4
                                radius: 2
                                color: Theme.textDim
                                opacity: 0.4
                            }
                        }
                        
                        // Loading state
                        Text {
                            anchors.centerIn: parent
                            visible: backend.launcher.loading
                            text: "Loading apps..."
                            color: Theme.accent
                            font.pixelSize: 14
                        }
                        
                        // Empty state
                        Text {
                            anchors.centerIn: parent
                            visible: !backend.launcher.loading && appList.count === 0
                            text: searchInput.text ? "No apps match \"" + searchInput.text + "\"" : "No apps found"
                            color: Theme.textDim
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }
    
    Component.onCompleted: console.log("[LauncherPanel] Loaded (rofi-style)")
}
