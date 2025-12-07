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
    
    // Background (Transparent/Blur)
    color: "transparent"
    
    // Exclusions (reserve space so maximized windows don't cover it)
    exclusionMode: ExclusionMode.Normal
    
    // Dependencies
    required property var backend
    
    // Main Background with Blur
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: 0 // Top bar usually rectangular, but could have bottom corners rounded
        
        // Blur effect (if QuickShell supports it via specific module, or pseudo-blur)
        // For now, semi-transparent background
    }
    
    // Main Layout
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 12
        
        // Left: Start & Workspaces
        StartButton {
            onStartClicked: launcherPanel.visible = !launcherPanel.visible
        }
        
        // Separator
        Rectangle { width: 1; height: 16; color: Theme.textDim; opacity: 0.3 }
        
        WorkspaceWidget {
            backend: topBar.backend
        }
        
        // Separator
        Rectangle { width: 1; height: 16; color: Theme.textDim; opacity: 0.3 }
        
        // Middle: Window Tabs (Takes available space)
        WindowTabsWidget {
            Layout.fillWidth: true
            Layout.fillHeight: true
            backend: topBar.backend
        }
        
        // Right: System Tray
        SystemTrayWidget {
            backend: topBar.backend
            onSettingsClicked: settingsPanel.visible = !settingsPanel.visible // Toggle
            onNotificationClicked: notificationPanel.visible = !notificationPanel.visible // Toggle
        }
    }
    
    // Settings Panel Popup
    Loader {
        id: settingsLoader
        active: true
        source: "../panel/SettingsPanel.qml"
        onLoaded: {
            item.backend = topBar.backend
            item.anchor.window = topBar
        }
    }
    
    // Convenient property to access the panel item
    property var settingsPanel: settingsLoader.item
    
    // Launcher Panel Popup
    Loader {
        id: launcherLoader
        active: true
        source: "../launcher/LauncherPanel.qml"
        onLoaded: {
            item.backend = topBar.backend
            item.anchor.window = topBar
        }
    }
    
    Connections {
        target: topBar.backend
        function onRequestToggleLauncher() {
            launcherPanel.visible = !launcherPanel.visible
        }
    }
    
    property var launcherPanel: launcherLoader.item
    
    // Notification Panel Popup
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
        console.log("[TopBar] Loaded")
    }
}
