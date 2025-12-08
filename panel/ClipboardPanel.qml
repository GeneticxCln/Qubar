import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

PopupWindow {
    id: clipboardPanel
    
    width: 450
    height: 500
    visible: false
    color: "transparent"
    
    // Dependencies
    required property var backend
    
    // Clipboard history
    property var clipboardHistory: []
    property string searchQuery: ""
    property int maxHistory: 50
    
    // Filtered items
    property var filteredItems: {
        if (searchQuery.length > 0) {
            return clipboardHistory.filter(item => 
                item.text.toLowerCase().includes(searchQuery.toLowerCase())
            )
        }
        return clipboardHistory
    }
    
    // Load clipboard history using cliphist
    function loadHistory() {
        historyLoader.running = true
    }
    
    // Copy item to clipboard
    function copyItem(text) {
        copyProcess.command = ["wl-copy", text]
        copyProcess.running = true
        clipboardPanel.visible = false
    }
    
    // Delete item from history
    function deleteItem(index) {
        var item = clipboardHistory[index]
        if (item) {
            deleteProcess.command = ["cliphist", "delete-query", item.text]
            deleteProcess.running = true
            clipboardHistory.splice(index, 1)
            clipboardHistoryChanged()
        }
    }
    
    // Clear all history
    function clearHistory() {
        clearProcess.running = true
        clipboardHistory = []
    }
    
    // Processes
    Process {
        id: historyLoader
        command: ["cliphist", "list"]
        
        onRunningChanged: {
            if (!running) {
                parseHistory(stdout())
            }
        }
    }
    
    Process {
        id: copyProcess
        onRunningChanged: {
            if (!running) {
                console.log("[Clipboard] Item copied")
            }
        }
    }
    
    Process {
        id: deleteProcess
    }
    
    Process {
        id: clearProcess
        command: ["cliphist", "wipe"]
        onRunningChanged: {
            if (!running) {
                console.log("[Clipboard] History cleared")
            }
        }
    }
    
    function parseHistory(output) {
        var lines = output.trim().split("\n")
        var items = []
        
        for (var i = 0; i < Math.min(lines.length, maxHistory); i++) {
            var line = lines[i]
            if (line.length > 0) {
                // cliphist format: ID\ttext
                var parts = line.split("\t")
                var text = parts.length > 1 ? parts.slice(1).join("\t") : line
                
                items.push({
                    id: i,
                    text: text,
                    preview: text.substring(0, 100),
                    isImage: text.startsWith("[[")  // cliphist image marker
                })
            }
        }
        
        clipboardHistory = items
    }
    
    // Load on show
    onVisibleChanged: {
        if (visible) {
            loadHistory()
        }
    }
    
    // Main container
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: Theme.cornerRadius
        border.width: 1
        border.color: Theme.accent
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "📋 Clipboard History"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                }
                
                Item { Layout.fillWidth: true }
                
                // Clear button
                Rectangle {
                    width: 60
                    height: 28
                    radius: 6
                    color: clearHover.containsMouse ? Theme.urgent : Theme.hover
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Clear"
                        color: Theme.textPrimary
                        font.pixelSize: 12
                    }
                    
                    MouseArea {
                        id: clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clipboardPanel.clearHistory()
                    }
                }
                
                // Close button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: closeHover.containsMouse ? Theme.urgent : Theme.hover
                    
                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: Theme.textPrimary
                        font.pixelSize: 18
                    }
                    
                    MouseArea {
                        id: closeHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clipboardPanel.visible = false
                    }
                }
            }
            
            // Search
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: Theme.backgroundAlt
                radius: 8
                
                TextInput {
                    anchors.fill: parent
                    anchors.margins: 10
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    
                    Text {
                        text: "🔍 Search clipboard..."
                        color: Theme.textDim
                        visible: !parent.text && !parent.activeFocus
                    }
                    
                    onTextChanged: clipboardPanel.searchQuery = text
                }
            }
            
            // History list
            ListView {
                id: historyList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                
                model: clipboardPanel.filteredItems
                
                delegate: Rectangle {
                    width: historyList.width
                    height: Math.min(80, contentCol.implicitHeight + 16)
                    radius: 8
                    color: itemHover.containsMouse ? Theme.hover : Theme.backgroundAlt
                    
                    Behavior on color { ColorAnimation { duration: 100 } }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        // Content
                        ColumnLayout {
                            id: contentCol
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                Layout.fillWidth: true
                                text: modelData.isImage ? "📷 Image" : modelData.preview
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.WrapAnywhere
                            }
                            
                            Text {
                                visible: modelData.text.length > 100
                                text: modelData.text.length + " characters"
                                color: Theme.textDim
                                font.pixelSize: 10
                            }
                        }
                        
                        // Delete button
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: deleteHover.containsMouse ? Theme.urgent : "transparent"
                            visible: itemHover.containsMouse
                            
                            Text {
                                anchors.centerIn: parent
                                text: "🗑"
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                id: deleteHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: clipboardPanel.deleteItem(index)
                            }
                        }
                    }
                    
                    MouseArea {
                        id: itemHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            if (!modelData.isImage) {
                                clipboardPanel.copyItem(modelData.text)
                            }
                        }
                    }
                }
                
                // Empty state
                Text {
                    anchors.centerIn: parent
                    visible: clipboardPanel.filteredItems.length === 0
                    text: clipboardPanel.searchQuery ? "No matching items" : "Clipboard is empty"
                    color: Theme.textDim
                    font.pixelSize: 14
                }
            }
            
            // Status
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: clipboardPanel.clipboardHistory.length + " items"
                    color: Theme.textDim
                    font.pixelSize: 11
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "Click to paste • 🗑 to delete"
                    color: Theme.textDim
                    font.pixelSize: 10
                }
            }
        }
    }
    
    // Keyboard navigation
    Keys.onEscapePressed: clipboardPanel.visible = false
}
