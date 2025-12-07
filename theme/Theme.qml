pragma Singleton
import QtQuick

QtObject {
    id: theme
    
    // ═══════════════════════════════════════════════════════════
    // THEME MANAGER
    // ═══════════════════════════════════════════════════════════
    
    property var manager: ThemeManager {}
    
    // Forward theme changed signal
    signal changed()
    
    Connections {
        target: manager
        function onThemeChanged() {
            theme.changed()
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // DELEGATED PROPERTIES (from current theme)
    // ═══════════════════════════════════════════════════════════
    
    // Dimensions
    readonly property int barHeight: manager.currentTheme.barHeight
    readonly property int cornerRadius: manager.currentTheme.cornerRadius
    readonly property int spacing: manager.currentTheme.spacing
    
    // Backgrounds
    readonly property color background: manager.currentTheme.background
    readonly property color backgroundBlur: manager.currentTheme.backgroundBlur
    
    // Tabs
    readonly property color tabActive: manager.currentTheme.tabActive
    readonly property color tabInactive: manager.currentTheme.tabInactive
    readonly property color tabHover: manager.currentTheme.tabHover
    
    // Workspaces
    readonly property color workspaceActive: manager.currentTheme.workspaceActive
    readonly property color workspaceOccupied: manager.currentTheme.workspaceOccupied
    readonly property color workspaceEmpty: manager.currentTheme.workspaceEmpty
    
    // Text
    readonly property color textPrimary: manager.currentTheme.textPrimary
    readonly property color textSecondary: manager.currentTheme.textSecondary
    readonly property color textDim: manager.currentTheme.textDim
    
    // Accents
    readonly property color accent: manager.currentTheme.accent
    readonly property color urgent: manager.currentTheme.urgent
    readonly property color success: manager.currentTheme.success
    
    // Fonts
    readonly property string fontFamily: manager.currentTheme.fontFamily
    readonly property int fontSizeSmall: manager.currentTheme.fontSizeSmall
    readonly property int fontSizeNormal: manager.currentTheme.fontSizeNormal
    readonly property int fontSizeLarge: manager.currentTheme.fontSizeLarge
    
    // ═══════════════════════════════════════════════════════════
    // THEME CONTROL
    // ═══════════════════════════════════════════════════════════
    
    function setTheme(themeName) {
        manager.setTheme(themeName)
    }
    
    function toggleTheme() {
        manager.toggleTheme()
    }
    
    readonly property string currentThemeName: manager.currentThemeName
}

