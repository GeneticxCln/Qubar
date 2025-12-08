import "root:/modules/common/"
import QtQuick
import Quickshell
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool overviewOpen: false
    property bool notificationPanelVisible: false
    property bool settingsPanelVisible: false
    property bool wallpaperPickerVisible: false
}