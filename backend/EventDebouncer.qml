import QtQuick

QtObject {
    id: eventDebouncer
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal debounced(string eventName, var data)
    signal throttled(string eventName, var data)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    
    // Pending debounced events: eventName -> { timer, data }
    property var pendingDebounce: ({})
    
    // Last emit time for throttled events: eventName -> timestamp
    property var lastThrottleTime: ({})
    
    // Default delays (ms)
    property int defaultDebounceDelay: 100
    property int defaultThrottleInterval: 50
    
    // ═══════════════════════════════════════════════════════════
    // DEBOUNCE - Delays until quiet period
    // ═══════════════════════════════════════════════════════════
    
    // Debounce an event - only fires after `delay` ms of no new events
    function debounce(eventName, data, delay) {
        delay = delay || defaultDebounceDelay
        
        // Cancel existing timer for this event
        if (pendingDebounce[eventName]) {
            pendingDebounce[eventName].timer.stop()
            pendingDebounce[eventName].timer.destroy()
        }
        
        // Create new timer
        var timer = Qt.createQmlObject(`
            import QtQuick
            Timer {
                interval: ${delay}
                repeat: false
                running: true
            }
        `, eventDebouncer)
        
        var entry = {
            timer: timer,
            data: data,
            eventName: eventName
        }
        
        timer.triggered.connect(function() {
            // Emit the debounced event
            console.log("[EventDebouncer] Debounced:", eventName)
            debounced(eventName, entry.data)
            
            // Cleanup
            delete pendingDebounce[eventName]
            timer.destroy()
        })
        
        pendingDebounce[eventName] = entry
    }
    
    // ═══════════════════════════════════════════════════════════
    // THROTTLE - Limits to one event per interval
    // ═══════════════════════════════════════════════════════════
    
    // Throttle an event - fires at most once per `interval` ms
    function throttle(eventName, data, interval) {
        interval = interval || defaultThrottleInterval
        
        var now = Date.now()
        var lastTime = lastThrottleTime[eventName] || 0
        
        if (now - lastTime >= interval) {
            // Enough time has passed, emit immediately
            lastThrottleTime[eventName] = now
            console.log("[EventDebouncer] Throttled (emit):", eventName)
            throttled(eventName, data)
            return true
        } else {
            // Too soon, skip this event
            return false
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // CONVENIENCE: Debounce specific event types
    // ═══════════════════════════════════════════════════════════
    
    function debounceWindowTitle(address, title) {
        debounce("windowtitle_" + address, { address: address, title: title }, 150)
    }
    
    function debounceWorkspaceChange(workspaceId) {
        debounce("workspace", { id: workspaceId }, 50)
    }
    
    function throttleWindowFocus(address) {
        return throttle("windowfocus", { address: address }, 30)
    }
    
    // ═══════════════════════════════════════════════════════════
    // CLEANUP
    // ═══════════════════════════════════════════════════════════
    
    function cancelAll() {
        for (var eventName in pendingDebounce) {
            if (pendingDebounce[eventName].timer) {
                pendingDebounce[eventName].timer.stop()
                pendingDebounce[eventName].timer.destroy()
            }
        }
        pendingDebounce = {}
        lastThrottleTime = {}
    }
    
    function cancel(eventName) {
        if (pendingDebounce[eventName]) {
            pendingDebounce[eventName].timer.stop()
            pendingDebounce[eventName].timer.destroy()
            delete pendingDebounce[eventName]
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    Component.onCompleted: {
        console.log("[EventDebouncer] Module loaded")
    }
    
    Component.onDestruction: {
        cancelAll()
    }
}
