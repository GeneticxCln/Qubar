import QtQuick
import Quickshell
import Quickshell.Services

QtObject {
    id: shortcutManager
    
    // Dependencies
    required property var backend
    
    // ═══════════════════════════════════════════════════════════
    // GLOBAL SHORTCUTS
    // ═══════════════════════════════════════════════════════════
    
    // Toggle Launcher: Super (on release)
    // Note: Bind 'catchall' via Hyprland/WM to MOD if using 'onReleased' for Super
    // Or just use a specific key like Super+Space
    GlobalShortcut {
        name: "ToggleLauncher"
        onPressed: backend.requestToggleLauncher()
    }
    
    // We need to implement toggle() on launcher or expose visible property
    // Currently launcher is in TopBar, which is frontend.
    // The BackendController doesn't have direct access to frontend windows visibility unless we expose it.
    
    // Actually, backend should signal toggle requests, and frontend listens.
    // BackendController already has 'ActionDispatcher'.
    // Or we add 'requestToggleLauncher()' signal to BackendController.
    
    // Let's rely on signals in BackendController.
    
    GlobalShortcut {
        name: "ToggleOverview" // Super+Tab
        onPressed: {
            if (backend.overview) backend.overview.toggle()
        }
    }
    
    Component.onCompleted: console.log("[ShortcutManager] Initialized")
}
