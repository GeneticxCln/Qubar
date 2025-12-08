import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"
import "widgets"

PanelWindow {
    id: topBar
    
    // Position
    anchors {
        top: true
        left: true
        right: true
    }
    height: Theme.barHeight
    
    // Background
    color: "transparent"
    
    // Reserve space
    exclusionMode: ExclusionMode.Normal
    
    // Dependencies
    required property var backend
    
    // Main Background
    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }
    
    // Main Layout
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8
        
        // ═══════════════════════════════════════════════════════════
        // LEFT SECTION
        // ═══════════════════════════════════════════════════════════
        
        StartButton {
            onStartClicked: launcherPanel.visible = !launcherPanel.visible
        }
        
        // Separator
        Rectangle { width: 1; height: 20; color: Theme.textDim; opacity: 0.2 }
        
        WorkspaceWidget {
            backend: topBar.backend
        }
        
        // Separator
        Rectangle { width: 1; height: 20; color: Theme.textDim; opacity: 0.2 }
        
        // ═══════════════════════════════════════════════════════════
        // CENTER SECTION - Window Tabs + Music
        // ═══════════════════════════════════════════════════════════
        
        WindowTabsWidget {
            Layout.fillWidth: true
            Layout.fillHeight: true
            backend: topBar.backend
        }
        
        // Music Widget (only shows when playing)
        MusicWidget {
            backend: topBar.backend
        }
        
        // Cava Audio Visualizer (only shows when playing)
        CavaWidget {
            backend: topBar.backend
        }
        
        // Separator
        Rectangle { width: 1; height: 20; color: Theme.textDim; opacity: 0.2 }
        
        // ═══════════════════════════════════════════════════════════
        // RIGHT SECTION - System Tray
        // ═══════════════════════════════════════════════════════════
        
        SystemTrayWidget {
            backend: topBar.backend
            onSettingsClicked: settingsPanel.visible = !settingsPanel.visible
            onNotificationClicked: notificationPanel.visible = !notificationPanel.visible
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // PANEL LOADERS
    // ═══════════════════════════════════════════════════════════
    
    // Settings Panel
    Loader {
        id: settingsLoader
        active: true
        source: "../panel/SettingsPanel.qml"
        onLoaded: {
            item.backend = topBar.backend
            item.anchor.window = topBar
            item.openWallpaperPicker.connect(function() {
                GlobalStates.wallpaperPickerVisible = true
            })
        }
    }
    property var settingsPanel: settingsLoader.item
    
    // Launcher Panel
    Loader {
        id: launcherLoader
        active: true
        source: "../launcher/LauncherPanel.qml"
        onLoaded: {
            item.backend = topBar.backend
            item.anchor.window = topBar
        }
    }
    property var launcherPanel: launcherLoader.item
    
    Connections {
        target: topBar.backend
        function onRequestToggleLauncher() {
            launcherPanel.visible = !launcherPanel.visible
        }
    }
    
    // Notification Panel
    Loader {
        id: notificationLoader
        active: true
        source: "../panel/NotificationPanel.qml"
        onLoaded: {
            item.backend = topBar.backend
        }
    }
    property var notificationPanel: notificationLoader.item
    
    Component.onCompleted: {
        console.log("[TopBar] Loaded with all widgets")
    }
}
