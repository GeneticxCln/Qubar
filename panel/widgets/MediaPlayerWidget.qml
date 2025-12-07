import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"
import "../../modules/common/widgets"

Rectangle {
    id: root
    
    required property var backend
    property var media: backend.media
    
    Layout.fillWidth: true
    implicitHeight: visible ? 110 : 0
    visible: media.hasPlayer && media.status !== "stopped"
    
    color: Qt.rgba(0, 0, 0, 0.2)
    radius: 12
    
    // Artwork Background (Blurred)
    Image {
        anchors.fill: parent
        source: media.albumArt
        fillMode: Image.PreserveAspectCrop
        visible: media.albumArt !== ""
        opacity: 0.3
        layer.enabled: true
        // layer.effect: FastBlur { radius: 32 } // Requires QtGraphicalEffects, skipping for simplicity or need import
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 4
        
        // Track Info
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            // Album Art
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 8
                color: Theme.background
                clips: true
                
                Image {
                    anchors.fill: parent
                    source: media.albumArt || ""
                    fillMode: Image.PreserveAspectCrop
                    
                    // Fallback icon
                    Text {
                        anchors.centerIn: parent
                        text: "🎵"
                        visible: parent.status !== Image.Ready
                        font.pixelSize: 24
                    }
                }
            }
            
            // Text Info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: media.title || "Unknown Title"
                    color: Theme.textPrimary
                    font.bold: true
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Text {
                    text: media.artist || "Unknown Artist"
                    color: Theme.textSecondary
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
        
        // Progress Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 4
            height: 4
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.1)
            
            Rectangle {
                height: parent.height
                width: media.length > 0 ? (media.position / media.length) * parent.width : 0
                radius: 2
                color: Theme.accent
            }
        }
        
        // Controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24
            
            // Previous
            RippleButton {
                width: 32; height: 32
                radius: 16
                text: "⏮"
                rippleColor: Qt.rgba(1, 1, 1, 0.1)
                onClicked: media.previous()
            }
            
            // Play/Pause
            RippleButton {
                width: 40; height: 40
                radius: 20
                text: media.status === "playing" ? "⏸" : "▶"
                color: Theme.accent
                hoverColor: Theme.accentHover
                pressColor: Theme.accentActive
                onClicked: media.playPause()
            }
            
            // Next
            RippleButton {
                width: 32; height: 32
                radius: 16
                text: "⏭"
                rippleColor: Qt.rgba(1, 1, 1, 0.1)
                onClicked: media.next()
            }
        }
    }
}
