import QtQuick
import Quickshell.Io

QtObject {
    id: notificationController
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal notificationReceived(var notification)
    signal notificationDismissed(int id)
    signal notificationsUpdated()
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property var notifications: [] // [{id, app, summary, body, icon, time}]
    property int unreadCount: 0
    property bool doNotDisturb: false
    property int maxHistory: 50
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function dismiss(id) {
        notifications = notifications.filter(n => n.id !== id)
        updateUnreadCount()
        notificationDismissed(id)
        notificationsUpdated()
    }
    
    function dismissAll() {
        notifications = []
        unreadCount = 0
        notificationsUpdated()
    }
    
    function markAsRead(id) {
        for (var i = 0; i < notifications.length; i++) {
            if (notifications[i].id === id) {
                notifications[i].read = true
                break
            }
        }
        updateUnreadCount()
    }
    
    function markAllAsRead() {
        for (var i = 0; i < notifications.length; i++) {
            notifications[i].read = true
        }
        unreadCount = 0
        notificationsUpdated()
    }
    
    function toggleDoNotDisturb() {
        doNotDisturb = !doNotDisturb
    }
    
    function refresh() {
        // Using swaync-client for notification history
        historyProcess.start()
    }
    
    // ═══════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════
    
    function updateUnreadCount() {
        var count = 0
        for (var i = 0; i < notifications.length; i++) {
            if (!notifications[i].read) count++
        }
        unreadCount = count
    }
    
    function addNotification(notification) {
        // Add to front
        var newList = [notification].concat(notifications)
        // Limit history
        if (newList.length > maxHistory) {
            newList = newList.slice(0, maxHistory)
        }
        notifications = newList
        updateUnreadCount()
        notificationReceived(notification)
        notificationsUpdated()
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    // Get notification history from swaync
    Process {
        id: historyProcess
        command: ["swaync-client", "-s"]
        
        onFinished: {
            try {
                var data = JSON.parse(stdout)
                if (Array.isArray(data)) {
                    var parsed = data.map(function(n, idx) {
                        return {
                            id: n.id || idx,
                            app: n["app-name"] || n.appName || "Unknown",
                            summary: n.summary || "",
                            body: n.body || "",
                            icon: n["app-icon"] || n.appIcon || "",
                            time: n.time || Date.now(),
                            read: false
                        }
                    })
                    notificationController.notifications = parsed
                    updateUnreadCount()
                    notificationsUpdated()
                }
            } catch (e) {
                // swaync not available, try dunstctl
                dunstProcess.start()
            }
        }
    }
    
    // Fallback: dunst history
    Process {
        id: dunstProcess
        command: ["dunstctl", "history"]
        
        onFinished: {
            try {
                var data = JSON.parse(stdout)
                if (data && data.data && Array.isArray(data.data[0])) {
                    var parsed = data.data[0].map(function(n, idx) {
                        return {
                            id: n.id?.data || idx,
                            app: n.appname?.data || "Unknown",
                            summary: n.summary?.data || "",
                            body: n.body?.data || "",
                            icon: n.icon_path?.data || "",
                            time: Date.now(),
                            read: false
                        }
                    })
                    notificationController.notifications = parsed
                    updateUnreadCount()
                    notificationsUpdated()
                }
            } catch (e) {
                console.warn("[NotificationController] No notification daemon found")
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // POLLING
    // ═══════════════════════════════════════════════════════════
    
    Timer {
        id: pollTimer
        interval: 5000
        repeat: true
        running: true
        onTriggered: notificationController.refresh()
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[NotificationController] Initializing...")
        refresh()
    }
    
    Component.onCompleted: {
        console.log("[NotificationController] Module loaded")
        refresh()
    }
}
