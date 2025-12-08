//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import "./modules/common/"
import "./modules/overview/"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "./services/"
import "./backend/" as Backend

ShellRoot {
    // Enable/disable modules here. False = not loaded at all, so rest assured
    // no unnecessary stuff will take up memory if you decide to only use, say, the overview.
    property bool enableOverview: true
    property bool enableQubar: true  // Qubar backend

    // ═══════════════════════════════════════════════════════════
    // QUBAR BACKEND CONTROLLER
    // ═══════════════════════════════════════════════════════════
    
    Backend.BackendController {
        id: qubarBackend
        testMode: false
        logLevel: 1  // 0=errors, 1=warnings, 2=info, 3=debug
        // Floating Windows
    panel.SettingsPanel {
        id: settingsPanel
        backend: backendController
    }
    
    panel.NotificationPanel {
        id: notificationPanel
        backend: backendController
    }
    
    // Import path needs to be resolved or aliases used
    // Assuming relative path from shell.qml (root of quickshell config) to panel/wallpaper/WallpaperPicker.qml
    Loader {
        id: wallpaperPickerLoader
        active: GlobalStates.wallpaperPickerVisible || false
        source: "panel/wallpaper/WallpaperPicker.qml"
        
        onLoaded: {
            item.backend = backendController
            item.visible = Qt.binding(() => GlobalStates.wallpaperPickerVisible)
            // When window closes itself, update state
            // Note: PanelWindow usually controls its own visibility. 
            // We might need bidirectional binding or signal.
        }
        
        Connections {
            target: wallpaperPickerLoader.item
            function onVisibleChanged() {
                if (!wallpaperPickerLoader.item.visible) {
                    GlobalStates.wallpaperPickerVisible = false
                }
            }
        }
    }
        
        onBackendReady: {
            console.log("[Qubar] Backend ready - Active workspace:", activeWorkspaceId)
        }
        
        onBackendError: (module, message) => {
            console.error("[Qubar] Error in", module + ":", message)
        }
        
        onIpcWarning: {
            console.warn("[Qubar] IPC connection lost")
        }
        
        onIpcRecovered: {
            console.log("[Qubar] IPC connection recovered")
        }
    }
    
    // Top Bar UI
    Loader {
        active: enableQubar
        source: "./topbar/TopBar.qml"
        onLoaded: {
            console.log("[Qubar] TopBar loaded")
            item.backend = qubarBackend
        }
    }
    
    // Expose backend globally for other components
    property alias qubar: qubarBackend

    // Force initialization of some singletons
    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        ConfigLoader.loadConfig()
    }

    Loader {
        active: enableOverview
        source: "./overview/OverviewPanel.qml"
        onLoaded: {
            item.backend = qubarBackend
        }
    }

}