import QtQuick

QtObject {
    id: lightTheme
    
    // Theme metadata
    readonly property string name: "Light"
    readonly property string description: "Light mode variant"
    
    // Bar Dimensions
    readonly property int barHeight: 40
    readonly property int cornerRadius: 10
    readonly property int spacing: 4
    
    // Backgrounds
    readonly property color background: Qt.rgba(0.95, 0.95, 0.98, 0.95)
    readonly property color backgroundAlt: Qt.rgba(0.88, 0.88, 0.92, 0.95)
    readonly property color backgroundBlur: Qt.rgba(0.9, 0.9, 0.95, 0.7)
    
    // Tabs / Interactive Elements
    readonly property color tabActive: Qt.rgba(0.85, 0.87, 0.92, 1.0)
    readonly property color tabInactive: Qt.rgba(0.92,0.92, 0.95, 0.6)
    readonly property color tabHover: Qt.rgba(0.88, 0.88, 0.93, 0.8)
    
    // Workspaces
    readonly property color workspaceActive: Qt.rgba(0.4, 0.3, 0.8, 1.0)
    readonly property color workspaceOccupied: Qt.rgba(0.3, 0.3, 0.3, 0.7)
    readonly property color workspaceEmpty: Qt.rgba(0.7, 0.7, 0.7, 0.4)
    
    // Text
    readonly property color textPrimary: "#2e3440"
    readonly property color textSecondary: "#3b4252"
    readonly property color textDim: "#d8dee9"
    
    // Accents
    readonly property color accent: "#5e81ac"
    readonly property color urgent: "#bf616a"
    readonly property color success: "#a3be8c"
    
    // Fonts
    readonly property string fontFamily: "Inter, Roboto, Segoe UI, sans-serif"
    readonly property int fontSizeSmall: 10
    readonly property int fontSizeNormal: 12
    readonly property int fontSizeLarge: 14
}
