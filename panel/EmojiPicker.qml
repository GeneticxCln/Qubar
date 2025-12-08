import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

PopupWindow {
    id: emojiPicker
    
    width: 400
    height: 500
    visible: false
    color: "transparent"
    
    // Dependencies
    required property var backend
    
    // Emoji data
    property var categories: [
        { id: "smileys", name: "😀", label: "Smileys" },
        { id: "people", name: "👋", label: "People" },
        { id: "animals", name: "🐱", label: "Animals" },
        { id: "food", name: "🍕", label: "Food" },
        { id: "activities", name: "⚽", label: "Activities" },
        { id: "travel", name: "🚗", label: "Travel" },
        { id: "objects", name: "💡", label: "Objects" },
        { id: "symbols", name: "❤️", label: "Symbols" },
        { id: "flags", name: "🏳️", label: "Flags" }
    ]
    
    property string activeCategory: "smileys"
    property string searchQuery: ""
    property var recentEmojis: []
    
    // Emoji lists by category
    property var emojiData: {
        "smileys": ["😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃", "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "😚", "😙", "🥲", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥", "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "🥸", "😎", "🤓", "🧐"],
        "people": ["👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤌", "🤏", "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇", "☝️", "👍", "👎", "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "✍️", "💅", "🤳", "💪", "🦾", "🦿", "🦵", "🦶", "👂", "🦻", "👃", "🧠", "🫀", "🫁", "🦷", "🦴", "👀", "👁️", "👅", "👄", "👶", "🧒", "👦", "👧", "🧑", "👱", "👨", "🧔", "👩", "🧓", "👴", "👵"],
        "animals": ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐽", "🐸", "🐵", "🙈", "🙉", "🙊", "🐒", "🐔", "🐧", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🪱", "🐛", "🦋", "🐌", "🐞", "🐜", "🪰", "🪲", "🪳", "🦟", "🦗", "🕷️", "🕸️", "🦂", "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡", "🐠", "🐟", "🐬"],
        "food": ["🍕", "🍔", "🍟", "🌭", "🍿", "🧂", "🥓", "🥚", "🍳", "🧇", "🥞", "🧈", "🍞", "🥐", "🥖", "🥨", "🧀", "🥗", "🥙", "🥪", "🌮", "🌯", "🫔", "🥫", "🍝", "🍜", "🍲", "🍛", "🍣", "🍱", "🥟", "🦪", "🍤", "🍙", "🍚", "🍘", "🍥", "🥠", "🥮", "🍢", "🍡", "🍧", "🍨", "🍦", "🥧", "🧁", "🍰", "🎂", "🍮", "🍭", "🍬", "🍫", "🍩", "🍪", "🌰", "🥜", "🍯", "🥛", "🍼", "☕", "🫖", "🍵", "🧃", "🥤"],
        "activities": ["⚽", "🏀", "🏈", "⚾", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱", "🪀", "🏓", "🏸", "🏒", "🏑", "🥍", "🏏", "🪃", "🥅", "⛳", "🪁", "🏹", "🎣", "🤿", "🥊", "🥋", "🎽", "🛹", "🛼", "🛷", "⛸️", "🥌", "🎿", "⛷️", "🏂", "🪂", "🏋️", "🤼", "🤸", "⛹️", "🤺", "🤾", "🏌️", "🏇", "🧘", "🏄", "🏊", "🤽", "🚣", "🧗", "🚵", "🚴", "🏆", "🥇", "🥈", "🥉", "🏅", "🎖️", "🏵️", "🎗️", "🎫", "🎟️", "🎪", "🎭"],
        "travel": ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐", "🛻", "🚚", "🚛", "🚜", "🦯", "🦽", "🦼", "🛴", "🚲", "🛵", "🏍️", "🛺", "🚨", "🚔", "🚍", "🚘", "🚖", "🚡", "🚠", "🚟", "🚃", "🚋", "🚞", "🚝", "🚄", "🚅", "🚈", "🚂", "🚆", "🚇", "🚊", "🚉", "✈️", "🛫", "🛬", "🛩️", "💺", "🛰️", "🚀", "🛸", "🚁", "🛶", "⛵", "🚤", "🛥️", "🛳️", "⛴️", "🚢", "⚓", "🪝", "⛽", "🚧", "🚦", "🚥"],
        "objects": ["💡", "🔦", "🏮", "🪔", "📱", "📲", "💻", "🖥️", "🖨️", "⌨️", "🖱️", "🖲️", "💽", "💾", "💿", "📀", "🧮", "🎥", "🎞️", "📽️", "🎬", "📺", "📷", "📸", "📹", "📼", "🔍", "🔎", "🕯️", "💰", "🪙", "💴", "💵", "💶", "💷", "💳", "💎", "⚖️", "🪜", "🧰", "🪛", "🔧", "🔨", "⚒️", "🛠️", "⛏️", "🪚", "🔩", "⚙️", "🪤", "🧱", "⛓️", "🧲", "🔫", "💣", "🧨", "🪓", "🔪", "🗡️", "⚔️", "🛡️", "🚬", "⚰️", "🪦"],
        "symbols": ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💔", "❣️", "💕", "💞", "💓", "💗", "💖", "💘", "💝", "💟", "☮️", "✝️", "☪️", "🕉️", "☸️", "✡️", "🔯", "🕎", "☯️", "☦️", "🛐", "⛎", "♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓", "🆔", "⚛️", "🉑", "☢️", "☣️", "📴", "📳", "🈶", "🈚", "🈸", "🈺", "🈷️", "✴️", "🆚", "💮", "🉐", "㊙️", "㊗️", "🈴", "🈵", "🈹"],
        "flags": ["🏳️", "🏴", "🏁", "🚩", "🏳️‍🌈", "🏳️‍⚧️", "🏴‍☠️", "🇦🇫", "🇦🇱", "🇩🇿", "🇦🇸", "🇦🇩", "🇦🇴", "🇦🇮", "🇦🇶", "🇦🇬", "🇦🇷", "🇦🇲", "🇦🇼", "🇦🇺", "🇦🇹", "🇦🇿", "🇧🇸", "🇧🇭", "🇧🇩", "🇧🇧", "🇧🇾", "🇧🇪", "🇧🇿", "🇧🇯", "🇧🇲", "🇧🇹", "🇧🇴", "🇧🇦", "🇧🇼", "🇧🇷", "🇮🇴", "🇻🇬", "🇧🇳", "🇧🇬", "🇧🇫", "🇧🇮", "🇰🇭", "🇨🇲", "🇨🇦", "🇮🇨", "🇨🇻", "🇧🇶", "🇰🇾", "🇨🇫", "🇹🇩", "🇨🇱", "🇨🇳", "🇨🇽", "🇨🇨", "🇨🇴", "🇰🇲", "🇨🇬", "🇨🇩", "🇨🇰", "🇨🇷", "🇭🇷", "🇨🇺", "🇨🇼"]
    }
    
    // Filtered emojis based on search
    property var filteredEmojis: {
        if (searchQuery.length > 0) {
            var all = []
            for (var cat in emojiData) {
                all = all.concat(emojiData[cat])
            }
            return all.filter(e => e.includes(searchQuery))
        }
        return emojiData[activeCategory] || []
    }
    
    // Copy emoji to clipboard
    function copyEmoji(emoji) {
        copyProcess.command = ["wl-copy", emoji]
        copyProcess.running = true
        
        // Add to recent
        var recent = recentEmojis.filter(e => e !== emoji)
        recent.unshift(emoji)
        recentEmojis = recent.slice(0, 20)
        
        // Close picker
        emojiPicker.visible = false
    }
    
    Process {
        id: copyProcess
        onRunningChanged: {
            if (!running) {
                console.log("[EmojiPicker] Emoji copied")
            }
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
                    text: "😀 Emoji Picker"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                }
                
                Item { Layout.fillWidth: true }
                
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
                        onClicked: emojiPicker.visible = false
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
                        text: "🔍 Search emojis..."
                        color: Theme.textDim
                        visible: !parent.text && !parent.activeFocus
                    }
                    
                    onTextChanged: emojiPicker.searchQuery = text
                }
            }
            
            // Category tabs
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Repeater {
                    model: emojiPicker.categories
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 6
                        color: emojiPicker.activeCategory === modelData.id ? Theme.accent : Theme.hover
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.name
                            font.pixelSize: 18
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                emojiPicker.activeCategory = modelData.id
                                emojiPicker.searchQuery = ""
                            }
                        }
                        
                        ToolTip.visible: hoverArea.containsMouse
                        ToolTip.text: modelData.label
                        ToolTip.delay: 300
                        
                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }
                    }
                }
            }
            
            // Recent emojis (if any)
            ColumnLayout {
                visible: recentEmojis.length > 0 && searchQuery.length === 0
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    text: "Recent"
                    color: Theme.textDim
                    font.pixelSize: 12
                }
                
                Flow {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Repeater {
                        model: recentEmojis
                        
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 6
                            color: recentHover.containsMouse ? Theme.hover : "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 22
                            }
                            
                            MouseArea {
                                id: recentHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: emojiPicker.copyEmoji(modelData)
                            }
                        }
                    }
                }
            }
            
            // Emoji grid
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                GridView {
                    id: emojiGrid
                    anchors.fill: parent
                    cellWidth: 44
                    cellHeight: 44
                    
                    model: emojiPicker.filteredEmojis
                    
                    delegate: Rectangle {
                        width: 40
                        height: 40
                        radius: 6
                        color: emojiHover.containsMouse ? Theme.hover : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 24
                        }
                        
                        MouseArea {
                            id: emojiHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: emojiPicker.copyEmoji(modelData)
                        }
                    }
                }
            }
            
            // Status
            Text {
                text: emojiPicker.filteredEmojis.length + " emojis"
                color: Theme.textDim
                font.pixelSize: 11
            }
        }
    }
    
    // Keyboard navigation
    Keys.onEscapePressed: emojiPicker.visible = false
}
