import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: musicWidget
    
    // Dependencies
    required property var backend
    property var media: backend.media
    
    // Layout
    implicitWidth: contentRow.implicitWidth + 20
    implicitHeight: Theme.barHeight - 8
    radius: 8
    
    // Only visible when music is playing
    visible: media && media.hasActivePlayer
    
    color: hoverArea.containsMouse ? Theme.tabHover : Theme.tabInactive
    
    Behavior on color { ColorAnimation { duration: 100 } }
    
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8
        
        // Album art or music icon
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 4
            color: Theme.accent
            clip: true
            
            Image {
                id: albumArt
                anchors.fill: parent
                source: media ? media.artUrl : ""
                visible: status === Image.Ready && source != ""
                fillMode: Image.PreserveAspectCrop
            }
            
            // Fallback icon
            Text {
                anchors.centerIn: parent
                visible: albumArt.status !== Image.Ready || albumArt.source == ""
                text: "🎵"
                font.pixelSize: 14
            }
        }
        
        // Track info
        ColumnLayout {
            spacing: 0
            Layout.maximumWidth: 150
            
            // Title
            Text {
                text: media ? media.title || "Unknown" : "Unknown"
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
                font.bold: true
                elide: Text.ElideRight
                Layout.maximumWidth: 150
            }
            
            // Artist
            Text {
                text: media ? media.artist || "Unknown" : "Unknown"
                color: Theme.textDim
                font.pixelSize: 10
                font.family: Theme.fontFamily
                elide: Text.ElideRight
                Layout.maximumWidth: 150
            }
        }
        
        // Play/Pause button
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: playHover.containsMouse ? Theme.accent : Theme.hover
            
            Text {
                anchors.centerIn: parent
                text: media && media.playing ? "⏸" : "▶"
                font.pixelSize: 12
                color: playHover.containsMouse ? Theme.background : Theme.textPrimary
            }
            
            MouseArea {
                id: playHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    if (media) media.playPause()
                }
            }
        }
        
        // Next button
        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 10
            color: nextHover.containsMouse ? Theme.hover : "transparent"
            
            Text {
                anchors.centerIn: parent
                text: "⏭"
                font.pixelSize: 10
                color: Theme.textSecondary
            }
            
            MouseArea {
                id: nextHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    if (media) media.next()
                }
            }
        }
    }
    
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
