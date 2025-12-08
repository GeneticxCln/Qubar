import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../theme"

// Standalone window for the wallpaper picker
PanelWindow {
    id: wallpaperPickerWindow
    
    // Window properties - centered on screen
    width: 1200
    height: 800
    
    color: "transparent"
    visible: false
    
    property var backend
    
    // Main Container
    Rectangle {
        anchors.fill: parent
        color: Theme.currentTheme.background
        radius: Theme.currentTheme.cornerRadius
        border.width: 1
        border.color: Theme.currentTheme.accent
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                // Icon
                Text {
                    text: "🖼️"
                    font.pixelSize: 24
                }
                
                Text {
                    text: "Wallpaper Picker"
                    color: Theme.currentTheme.textPrimary
                    font.family: Theme.currentTheme.fontFamily
                    font.pixelSize: 24
                    font.bold: true
                    Layout.fillWidth: true
                }
                
                // Close Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: closeHover.hovered ? Theme.currentTheme.urgent : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: Theme.currentTheme.textPrimary
                    }
                    
                    HoverHandler { id: closeHover }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: wallpaperPickerWindow.visible = false
                    }
                }
            }
            
            // Search & Filter Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                // Search Box
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: Theme.currentTheme.backgroundAlt
                    radius: Theme.currentTheme.cornerRadius
                    border.width: 1
                    border.color: searchInput.activeFocus ? Theme.currentTheme.accent : "transparent"
                    
                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        verticalAlignment: TextInput.AlignVCenter
                        
                        text: backend && backend.wallpapers ? backend.wallpapers.searchQuery : ""
                        color: Theme.currentTheme.textPrimary
                        font.family: Theme.currentTheme.fontFamily
                        font.pixelSize: Theme.currentTheme.fontSizeNormal
                        
                        property string placeholderText: "Search wallpapers..."
                        
                        Text {
                            text: parent.placeholderText
                            color: Theme.currentTheme.textDim
                            visible: !parent.text && !parent.activeFocus
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onTextChanged: {
                            if (backend && backend.wallpapers) {
                                backend.wallpapers.filterWallpapers(text)
                            }
                        }
                    }
                }
                
                // Refresh Button
                Rectangle {
                    width: 40
                    height: 40
                    color: Theme.currentTheme.backgroundAlt
                    radius: Theme.currentTheme.cornerRadius
                    
                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        color: Theme.currentTheme.textPrimary
                        font.pixelSize: 18
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (backend && backend.wallpapers) {
                                backend.wallpapers.loadWallpapers()
                            }
                        }
                    }
                }
            }
            
            // Categories
            Flow {
                Layout.fillWidth: true
                spacing: 8
                
                Repeater {
                    model: backend && backend.wallpapers ? backend.wallpapers.categories : []
                    
                    Rectangle {
                        width: catText.contentWidth + 30
                        height: 32
                        radius: 16
                        
                        property bool isActive: backend && backend.wallpapers && 
                                               backend.wallpapers.activeCategory === modelData
                        
                        color: isActive ? Theme.currentTheme.accent : Theme.currentTheme.backgroundAlt
                        border.width: 1
                        border.color: isActive ? Theme.currentTheme.accent : "transparent"
                        
                        Text {
                            id: catText
                            anchors.centerIn: parent
                            text: modelData
                            color: parent.isActive ? "#ffffff" : Theme.currentTheme.textSecondary
                            font.family: Theme.currentTheme.fontFamily
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (backend && backend.wallpapers) {
                                    backend.wallpapers.setCategory(modelData)
                                }
                            }
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
            
            // Grid View
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                GridView {
                    id: grid
                    anchors.fill: parent
                    clip: true
                    
                    cellWidth: 290
                    cellHeight: 200
                    
                    model: backend && backend.wallpapers ? backend.wallpapers.filteredWallpapers : []
                    
                    delegate: WallpaperItem {
                        modelData: model.modelData !== undefined ? model.modelData : modelData
                        backend: wallpaperPickerWindow.backend
                        
                        onClicked: {
                            if (backend && backend.wallpapers) {
                                backend.wallpapers.applyWallpaper(modelData.path)
                            }
                        }
                    }
                    
                    ScrollBar.vertical: ScrollBar {
                        active: true
                        width: 10
                    }
                }
                
                // Loading State
                BusyIndicator {
                    anchors.centerIn: parent
                    running: backend && backend.wallpapers && backend.wallpapers.loading
                    visible: running
                }
                
                // Empty State
                Text {
                    anchors.centerIn: parent
                    text: "No wallpapers found"
                    color: Theme.currentTheme.textDim
                    visible: backend && backend.wallpapers && 
                             !backend.wallpapers.loading && grid.count === 0
                    font.pixelSize: 18
                }
            }
            
            // Footer
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: grid.count + " wallpapers"
                    color: Theme.currentTheme.textDim
                    font.pixelSize: Theme.currentTheme.fontSizeSmall
                }
                
                Item { Layout.fillWidth: true }
                
                // Random Button
                Rectangle {
                    width: 120
                    height: 36
                    color: Theme.currentTheme.backgroundAlt
                    radius: Theme.currentTheme.cornerRadius
                    border.width: 1
                    border.color: Theme.currentTheme.accent
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Random"
                        color: Theme.currentTheme.textPrimary
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (backend && backend.wallpapers && 
                                backend.wallpapers.filteredWallpapers.length > 0) {
                                var randomIndex = Math.floor(Math.random() * backend.wallpapers.filteredWallpapers.length)
                                var randomWp = backend.wallpapers.filteredWallpapers[randomIndex]
                                if (randomWp) {
                                    backend.wallpapers.applyWallpaper(randomWp.path)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
