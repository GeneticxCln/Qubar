pragma Singleton
import QtQuick

QtObject {
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    
    // Bar Dimensions
    readonly property int barHeight: 40
    readonly property int cornerRadius: 10
    readonly property int spacing: 4
    
    // ═══════════════════════════════════════════════════════════
    // COLORS (Dracula-inspired / Slate Dark)
    // ═══════════════════════════════════════════════════════════
    
    // Backgrounds
    readonly property color background: Qt.rgba(0.05, 0.05, 0.08, 0.85) // Dark slate, semi-transparent
    readonly property color backgroundBlur: Qt.rgba(0.1, 0.1, 0.15, 0.4) // For blur effects
    
    // Tabs / Interactive Elements
    readonly property color tabActive: Qt.rgba(0.2, 0.22, 0.28, 1.0)
    readonly property color tabInactive: Qt.rgba(0.12, 0.12, 0.15, 0.6)
    readonly property color tabHover: Qt.rgba(0.18, 0.18, 0.22, 0.8)
    
    // Workspaces
    readonly property color workspaceActive: Qt.rgba(0.5, 0.4, 0.9, 1.0) // Violet/Purple accent
    readonly property color workspaceOccupied: Qt.rgba(0.8, 0.8, 0.8, 0.6)
    readonly property color workspaceEmpty: Qt.rgba(0.5, 0.5, 0.5, 0.3)
    
    // Text
    readonly property color textPrimary: "#eceff4"
    readonly property color textSecondary: "#d8dee9"
    readonly property color textDim: "#4c566a"
    
    // Accents
    readonly property color accent: "#81a1c1" // Blue-ish
    readonly property color urgent: "#bf616a" // Red
    readonly property color success: "#a3be8c" // Green
    
    // ═══════════════════════════════════════════════════════════
    // FONTS
    // ═══════════════════════════════════════════════════════════
    readonly property string fontFamily: "Inter, Roboto, Segoe UI, sans-serif"
    readonly property int fontSizeSmall: 10
    readonly property int fontSizeNormal: 12
    readonly property int fontSizeLarge: 14
}
