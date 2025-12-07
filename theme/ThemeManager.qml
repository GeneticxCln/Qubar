import QtQuick
import Quickshell.Io
import "themes"

QtObject {
    id: themeManager
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal themeChanged()
    
    //═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property string currentThemeName: "dark"
    property var currentTheme: darkTheme
    
    // Theme instances
    property var darkTheme: DarkTheme {}
    property var lightTheme: LightTheme {}
    
    // State file
    property string stateFile: Quickshell.env("HOME") + "/.config/quickshell/theme_state.json"
    
    // ═══════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function setTheme(themeName) {
        console.log("[ThemeManager] Switching to theme:", themeName)
        
        if (themeName === "dark") {
            currentTheme = darkTheme
            currentThemeName = "dark"
        } else if (themeName === "light") {
            currentTheme = lightTheme
            currentThemeName = "light"
        } else {
            console.warn("[ThemeManager] Unknown theme:", themeName)
            return
        }
        
        saveState()
        themeChanged()
    }
    
    function toggleTheme() {
        setTheme(currentThemeName === "dark" ? "light" : "dark")
    }
    
    function saveState() {
        var state = {
            theme: currentThemeName
        }
        
        try {
            var file = Quickshell.writeFile(stateFile, JSON.stringify(state, null, 2))
            console.log("[ThemeManager] State saved")
        } catch (e) {
            console.error("[ThemeManager] Failed to save state:", e)
        }
    }
    
    function loadState() {
        try {
            var content = Quickshell.readFile(stateFile)
            var state = JSON.parse(content)
            
            if (state.theme) {
                setTheme(state.theme)
                console.log("[ThemeManager] State loaded:", state.theme)
            }
        } catch (e) {
            console.log("[ThemeManager] No saved state, using default (dark)")
            setTheme("dark")
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    Component.onCompleted: {
        console.log("[ThemeManager] Module loaded")
        loadState()
    }
}
