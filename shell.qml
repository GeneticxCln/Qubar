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
import "./panel/" as panel

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
    
    // ═══════════════════════════════════════════════════════════
    // TOP BAR UI
    // ═══════════════════════════════════════════════════════════
    
    Loader {
        active: enableQubar
        source: "./topbar/TopBar.qml"
        onLoaded: {
            console.log("[Qubar] TopBar loaded")
            item.backend = qubarBackend
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // FLOATING PANELS
    // ═══════════════════════════════════════════════════════════
    
    // Wallpaper Picker
    Loader {
        id: wallpaperPickerLoader
        active: GlobalStates.wallpaperPickerVisible
        source: "./panel/wallpaper/WallpaperPicker.qml"
        
        onLoaded: {
            item.backend = qubarBackend
            item.visible = Qt.binding(() => GlobalStates.wallpaperPickerVisible)
        }
        
        Connections {
            target: wallpaperPickerLoader.item
            function onVisibleChanged() {
                if (wallpaperPickerLoader.item && !wallpaperPickerLoader.item.visible) {
                    GlobalStates.wallpaperPickerVisible = false
                }
            }
        }
    }
    
    // Emoji Picker
    Loader {
        id: emojiPickerLoader
        active: GlobalStates.emojiPickerVisible
        source: "./panel/EmojiPicker.qml"
        
        onLoaded: {
            item.backend = qubarBackend
            item.visible = Qt.binding(() => GlobalStates.emojiPickerVisible)
        }
        
        Connections {
            target: emojiPickerLoader.item
            function onVisibleChanged() {
                if (emojiPickerLoader.item && !emojiPickerLoader.item.visible) {
                    GlobalStates.emojiPickerVisible = false
                }
            }
        }
    }
    
    // Clipboard Manager
    Loader {
        id: clipboardPanelLoader
        active: GlobalStates.clipboardPanelVisible
        source: "./panel/ClipboardPanel.qml"
        
        onLoaded: {
            item.backend = qubarBackend
            item.visible = Qt.binding(() => GlobalStates.clipboardPanelVisible)
        }
        
        Connections {
            target: clipboardPanelLoader.item
            function onVisibleChanged() {
                if (clipboardPanelLoader.item && !clipboardPanelLoader.item.visible) {
                    GlobalStates.clipboardPanelVisible = false
                }
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // OVERVIEW
    // ═══════════════════════════════════════════════════════════
    
    Loader {
        active: enableOverview
        source: "./overview/OverviewPanel.qml"
        onLoaded: {
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
}