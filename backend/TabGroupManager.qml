import QtQuick

QtObject {
    id: tabGroupManager
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal groupCreated(string groupId)
    signal groupDestroyed(string groupId)
    signal windowAddedToGroup(string groupId, string windowAddress)
    signal windowRemovedFromGroup(string groupId, string windowAddress)
    signal activeWindowChanged(string groupId, string windowAddress)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property var groups: ({})           // Map: groupId -> TabGroup
    property var windowToGroup: ({})    // Map: windowAddress -> groupId
    property var groupList: []          // Array for iteration
    
    // Apps that should be grouped (configurable)
    property var groupableApps: [
        "firefox",
        "chromium",
        "google-chrome",
        "brave-browser",
        "code",
        "Code"
    ]
    
    // ═══════════════════════════════════════════════════════════
    // TAB GROUP MODEL
    // ═══════════════════════════════════════════════════════════
    
    function createTabGroup(primaryAppId, firstWindow) {
        var groupId = primaryAppId + "_" + Date.now()
        
        var group = {
            groupId: groupId,
            primaryAppId: primaryAppId,
            windows: [firstWindow],
            activeWindow: firstWindow,
            createdAt: Date.now()
        }
        
        var newGroups = Object.assign({}, groups)
        newGroups[groupId] = group
        groups = newGroups
        
        groupList = Object.values(groups)
        
        // Map window to group
        var newMap = Object.assign({}, windowToGroup)
        newMap[firstWindow.address] = groupId
        windowToGroup = newMap
        
        console.log("[TabGroupManager] Created group:", groupId, "for", primaryAppId)
        groupCreated(groupId)
        
        return groupId
    }
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function shouldGroupWindow(window) {
        return groupableApps.includes(window.appId)
    }
    
    function findGroupForApp(appId) {
        for (var groupId in groups) {
            if (groups[groupId].primaryAppId === appId) {
                return groupId
            }
        }
        return null
    }
    
    function addWindowToGroup(window) {
        if (!shouldGroupWindow(window)) {
            return null
        }
        
        // Find existing group for this app
        var groupId = findGroupForApp(window.appId)
        
        if (groupId) {
            // Add to existing group
            var group = groups[groupId]
            group.windows = group.windows.concat([window])
            
            var newGroups = Object.assign({}, groups)
            newGroups[groupId] = group
            groups = newGroups
            
            var newMap = Object.assign({}, windowToGroup)
            newMap[window.address] = groupId
            windowToGroup = newMap
            
            console.log("[TabGroupManager] Added window to group:", groupId)
            windowAddedToGroup(groupId, window.address)
            
            return groupId
        } else {
            // Create new group
            return createTabGroup(window.appId, window)
        }
    }
    
    function removeWindowFromGroup(windowAddress) {
        var groupId = windowToGroup[windowAddress]
        if (!groupId) return
        
        var group = groups[groupId]
        if (!group) return
        
        // Remove window from group
        group.windows = group.windows.filter(function(w) {
            return w.address !== windowAddress
        })
        
        // Remove from map
        var newMap = Object.assign({}, windowToGroup)
        delete newMap[windowAddress]
        windowToGroup = newMap
        
        if (group.windows.length === 0) {
            // Destroy empty group
            var newGroups = Object.assign({}, groups)
            delete newGroups[groupId]
            groups = newGroups
            groupList = Object.values(groups)
            
            console.log("[TabGroupManager] Destroyed empty group:", groupId)
            groupDestroyed(groupId)
        } else {
            // Update active window if needed
            if (group.activeWindow && group.activeWindow.address === windowAddress) {
                group.activeWindow = group.windows[0]
                activeWindowChanged(groupId, group.activeWindow.address)
            }
            
            var newGroups2 = Object.assign({}, groups)
            newGroups2[groupId] = group
            groups = newGroups2
            
            windowRemovedFromGroup(groupId, windowAddress)
        }
    }
    
    function setActiveWindowInGroup(windowAddress) {
        var groupId = windowToGroup[windowAddress]
        if (!groupId) return
        
        var group = groups[groupId]
        if (!group) return
        
        var window = group.windows.find(function(w) {
            return w.address === windowAddress
        })
        
        if (window && group.activeWindow !== window) {
            group.activeWindow = window
            
            var newGroups = Object.assign({}, groups)
            newGroups[groupId] = group
            groups = newGroups
            
            activeWindowChanged(groupId, windowAddress)
        }
    }
    
    function getGroup(groupId) {
        return groups[groupId] || null
    }
    
    function getGroupForWindow(windowAddress) {
        var groupId = windowToGroup[windowAddress]
        return groupId ? groups[groupId] : null
    }
    
    function getWindowsInGroup(groupId) {
        var group = groups[groupId]
        return group ? group.windows : []
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    Component.onCompleted: {
        console.log("[TabGroupManager] Module loaded")
        console.log("[TabGroupManager] Groupable apps:", groupableApps.join(", "))
    }
}
