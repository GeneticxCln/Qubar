import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"

Item {
    id: root
    width: parent.width
    height: contentColumn.implicitHeight
    
    required property var backend
    
    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12
        
        // Header
        Text {
            text: "Appearance"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
        }
        
        // ═══════════════════════════════════════════════════════════
        // BLUR SECTION
        // ═══════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            height: blurContent.implicitHeight + 20
            color: Theme.backgroundAlt
            radius: Theme.cornerRadius
            
            ColumnLayout {
                id: blurContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                
                // Blur Toggle
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "🌫️ Blur"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Switch {
                        checked: backend && backend.appearance ? backend.appearance.blurEnabled : true
                        onCheckedChanged: {
                            if (backend && backend.appearance) {
                                backend.appearance.setBlur(checked)
                            }
                        }
                    }
                }
                
                // Blur Intensity Slider
                RowLayout {
                    Layout.fillWidth: true
                    visible: backend && backend.appearance && backend.appearance.blurEnabled
                    
                    Text {
                        text: "Intensity"
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    
                    Slider {
                        Layout.fillWidth: true
                        from: 1
                        to: 15
                        stepSize: 1
                        value: backend && backend.appearance ? backend.appearance.blurSize : 8
                        onMoved: {
                            if (backend && backend.appearance) {
                                backend.appearance.setBlurSize(Math.round(value))
                            }
                        }
                    }
                    
                    Text {
                        text: backend && backend.appearance ? backend.appearance.blurSize : "8"
                        color: Theme.textDim
                        font.pixelSize: Theme.fontSizeSmall
                        width: 20
                    }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════
        // OPACITY SECTION
        // ═══════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            height: opacityContent.implicitHeight + 20
            color: Theme.backgroundAlt
            radius: Theme.cornerRadius
            
            ColumnLayout {
                id: opacityContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                
                Text {
                    text: "👁️ Window Opacity"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                }
                
                // Inactive Window Opacity
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Inactive windows"
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    
                    Slider {
                        Layout.fillWidth: true
                        from: 0.5
                        to: 1.0
                        stepSize: 0.05
                        value: backend && backend.appearance ? backend.appearance.inactiveOpacity : 0.95
                        onMoved: {
                            if (backend && backend.appearance) {
                                backend.appearance.setInactiveOpacity(value)
                            }
                        }
                    }
                    
                    Text {
                        text: backend && backend.appearance ? 
                              Math.round(backend.appearance.inactiveOpacity * 100) + "%" : "95%"
                        color: Theme.textDim
                        font.pixelSize: Theme.fontSizeSmall
                        width: 35
                    }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════
        // ANIMATIONS SECTION
        // ═══════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            height: animContent.implicitHeight + 20
            color: Theme.backgroundAlt
            radius: Theme.cornerRadius
            
            ColumnLayout {
                id: animContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                // Header
                Text {
                    text: "✨ Animation Style"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.bold: true
                }
                
                // Subtitle showing current style
                Text {
                    text: {
                        if (backend && backend.appearance) {
                            var style = backend.appearance.animationStyle
                            var styles = backend.appearance.animationStyles
                            for (var i = 0; i < styles.length; i++) {
                                if (styles[i].id === style) {
                                    return "Current: " + styles[i].name + " - " + styles[i].desc
                                }
                            }
                        }
                        return "Current: Default"
                    }
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                
                // Animation Styles Grid - 2 columns
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 8
                    columnSpacing: 8
                    
                    Repeater {
                        model: backend && backend.appearance ? backend.appearance.animationStyles : []
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            radius: 8
                            
                            property bool isActive: backend && backend.appearance && 
                                                   backend.appearance.animationStyle === modelData.id
                            
                            color: isActive ? Theme.accent : Theme.background
                            border.width: 1
                            border.color: isActive ? Theme.accent : Theme.textDim
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                
                                // Icon
                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 20
                                    Layout.preferredWidth: 28
                                }
                                
                                // Name and description
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        text: modelData.name
                                        color: parent.parent.parent.isActive ? "#ffffff" : Theme.textPrimary
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.bold: true
                                    }
                                    
                                    Text {
                                        text: modelData.desc
                                        color: parent.parent.parent.isActive ? "rgba(255,255,255,0.7)" : Theme.textDim
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (backend && backend.appearance) {
                                        backend.appearance.setAnimationStyle(modelData.id)
                                    }
                                }
                            }
                            
                            // Hover effect
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "white"
                                opacity: hoverArea.containsMouse ? 0.1 : 0
                                
                                MouseArea {
                                    id: hoverArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (backend && backend.appearance) {
                                            backend.appearance.setAnimationStyle(modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════
        // BORDERS & SHADOWS
        // ═══════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            height: borderContent.implicitHeight + 20
            color: Theme.backgroundAlt
            radius: Theme.cornerRadius
            
            ColumnLayout {
                id: borderContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                
                // Border Style
                Text {
                    text: "🎨 Border Style"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Repeater {
                        model: [
                            { id: "rainbow", label: "Rainbow", icon: "🌈" },
                            { id: "accent", label: "Accent", icon: "💠" },
                            { id: "solid", label: "Solid", icon: "▪️" }
                        ]
                        
                        Rectangle {
                            width: 75
                            height: 32
                            radius: 8
                            
                            property bool isActive: backend && backend.appearance && 
                                                   backend.appearance.borderStyle === modelData.id
                            
                            color: isActive ? Theme.accent : Theme.background
                            border.width: 1
                            border.color: isActive ? Theme.accent : Theme.textDim
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 12
                                }
                                
                                Text {
                                    text: modelData.label
                                    color: parent.parent.isActive ? "#ffffff" : Theme.textSecondary
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (backend && backend.appearance) {
                                        backend.appearance.setBorderStyle(modelData.id)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Shadows Toggle
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    
                    Text {
                        text: "🌑 Shadows"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Switch {
                        checked: backend && backend.appearance ? backend.appearance.shadowsEnabled : true
                        onCheckedChanged: {
                            if (backend && backend.appearance) {
                                backend.appearance.setShadows(checked)
                            }
                        }
                    }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════
        // GAPS & ROUNDING
        // ═══════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            height: gapsContent.implicitHeight + 20
            color: Theme.backgroundAlt
            radius: Theme.cornerRadius
            
            ColumnLayout {
                id: gapsContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                
                Text {
                    text: "📐 Layout"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                }
                
                // Corner Rounding
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Corners"
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    
                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 20
                        stepSize: 2
                        value: backend && backend.appearance ? backend.appearance.cornerRounding : 10
                        onMoved: {
                            if (backend && backend.appearance) {
                                backend.appearance.setCornerRounding(Math.round(value))
                            }
                        }
                    }
                    
                    Text {
                        text: backend && backend.appearance ? backend.appearance.cornerRounding + "px" : "10px"
                        color: Theme.textDim
                        font.pixelSize: Theme.fontSizeSmall
                        width: 35
                    }
                }
                
                // Gaps
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Gaps"
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    
                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 20
                        stepSize: 2
                        value: backend && backend.appearance ? backend.appearance.gapsOut : 10
                        onMoved: {
                            if (backend && backend.appearance) {
                                backend.appearance.setGapsOut(Math.round(value))
                                backend.appearance.setGapsIn(Math.round(value / 2))
                            }
                        }
                    }
                    
                    Text {
                        text: backend && backend.appearance ? backend.appearance.gapsOut + "px" : "10px"
                        color: Theme.textDim
                        font.pixelSize: Theme.fontSizeSmall
                        width: 35
                    }
                }
            }
        }
    }
}
