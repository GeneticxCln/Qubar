import QtQuick
import Quickshell.Io

QtObject {
    id: appLauncher
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal applicationsLoaded()
    signal appLaunched(string name)
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property var applications: []       // All parsed apps
    property var recentApps: []         // Recently launched (max 10)
    property var favoriteApps: []       // User favorites
    property string searchQuery: ""
    property string activeCategory: "all"
    property var filteredApps: []       // Search results
    property bool loading: false
    
    // Desktop entry locations
    readonly property var desktopDirs: [
        "/usr/share/applications",
        Qt.getenv("HOME") + "/.local/share/applications"
    ]
    
    // ═══════════════════════════════════════════════════════════
    // PUBLIC FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function loadApplications() {
        loading = true
        console.log("[AppLauncher] Loading applications...")
        
        // Use find to get all .desktop files, then parse
        loadProcess.start()
    }
    
    function launch(app) {
        if (!app || !app.desktopFile) {
            error("Invalid app")
            return
        }
        
        console.log("[AppLauncher] Launching:", app.name)
        
        // Use gtk-launch for proper desktop entry handling
        launchProcess.command = ["gtk-launch", app.desktopFile.replace(/\.desktop$/, "")]
        launchProcess.start()
        
        // Track recent
        addToRecent(app)
        appLaunched(app.name)
    }
    
    function search(query) {
        searchQuery = query.toLowerCase().trim()
        
        if (!searchQuery) {
            filteredApps = applications
            return
        }
        
        filteredApps = applications.filter(function(app) {
            return app.name.toLowerCase().includes(searchQuery) ||
                   (app.categories && app.categories.toLowerCase().includes(searchQuery)) ||
                   (app.keywords && app.keywords.toLowerCase().includes(searchQuery))
        })
    }
    
    function getAppsByCategory(category) {
        return applications.filter(function(app) {
            return app.categories && app.categories.includes(category)
        })
    }
    
    function filterByCategory(categoryId) {
        activeCategory = categoryId
        
        if (categoryId === "all") {
            // Show all apps (but apply search if active)
            if (searchQuery) {
                search(searchQuery)
            } else {
                filteredApps = applications
            }
        } else if (categoryId === "favorites") {
            filteredApps = favoriteApps
        } else if (categoryId === "terminal") {
            filteredApps = applications.filter(function(app) {
                return app.categories && (
                    app.categories.includes("TerminalEmulator") ||
                    app.categories.includes("System") ||
                    app.name.toLowerCase().includes("terminal") ||
                    app.name.toLowerCase().includes("console")
                )
            })
        } else if (categoryId === "files") {
            filteredApps = applications.filter(function(app) {
                return app.categories && (
                    app.categories.includes("FileManager") ||
                    app.categories.includes("FileTools") ||
                    app.name.toLowerCase().includes("file")
                )
            })
        } else if (categoryId === "settings") {
            filteredApps = applications.filter(function(app) {
                return app.categories && (
                    app.categories.includes("Settings") ||
                    app.categories.includes("System") ||
                    app.name.toLowerCase().includes("setting") ||
                    app.name.toLowerCase().includes("config")
                )
            })
        }
        
        console.log("[AppLauncher] Filtered by category:", categoryId, "->", filteredApps.length, "apps")
    }
    
    function addToFavorites(app) {
        if (!app) return
        var exists = favoriteApps.some(a => a.desktopFile === app.desktopFile)
        if (!exists) {
            var newFavorites = favoriteApps.slice()
            newFavorites.push(app)
            favoriteApps = newFavorites
            saveFavorites()
        }
    }
    
    function removeFromFavorites(app) {
        if (!app) return
        favoriteApps = favoriteApps.filter(a => a.desktopFile !== app.desktopFile)
        saveFavorites()
    }
    
    function saveFavorites() {
        // In a real implementation, save to file
        console.log("[AppLauncher] Favorites:", favoriteApps.length)
    }
    
    // ═══════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════
    
    function addToRecent(app) {
        // Remove if exists, add to front
        var recent = recentApps.filter(a => a.desktopFile !== app.desktopFile)
        recent.unshift(app)
        recentApps = recent.slice(0, 10) // Keep max 10
    }
    
    function parseDesktopFiles(fileList) {
        var apps = []
        var files = fileList.trim().split("\n")
        
        for (var i = 0; i < files.length; i++) {
            var file = files[i].trim()
            if (!file) continue
            
            // Parse each file synchronously (or queue async)
            parseDesktopFile(file, function(app) {
                if (app) apps.push(app)
            })
        }
        
        // Sort alphabetically
        apps.sort(function(a, b) {
            return a.name.localeCompare(b.name)
        })
        
        applications = apps
        filteredApps = apps
        loading = false
        console.log("[AppLauncher] Loaded", apps.length, "applications")
        applicationsLoaded()
    }
    
    function parseDesktopFile(filePath, callback) {
        var proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["cat", "${filePath}"]
            }
        `, appLauncher)
        
        proc.finished.connect(function() {
            var app = parseDesktopEntry(proc.stdout, filePath)
            callback(app)
            proc.destroy()
        })
        
        proc.start()
    }
    
    function parseDesktopEntry(content, filePath) {
        // Skip if NoDisplay=true or hidden
        if (content.includes("NoDisplay=true") || content.includes("Hidden=true")) {
            return null
        }
        
        // Only handle Application type
        if (!content.includes("Type=Application")) {
            return null
        }
        
        var app = {
            name: extractValue(content, "Name"),
            icon: extractValue(content, "Icon") || "application-x-executable",
            exec: extractValue(content, "Exec"),
            categories: extractValue(content, "Categories"),
            keywords: extractValue(content, "Keywords"),
            comment: extractValue(content, "Comment"),
            desktopFile: filePath.split("/").pop() // Filename only
        }
        
        // Skip if no name
        if (!app.name) return null
        
        return app
    }
    
    function extractValue(content, key) {
        var regex = new RegExp("^" + key + "=(.*)$", "m")
        var match = content.match(regex)
        return match ? match[1].trim() : ""
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    Process {
        id: loadProcess
        command: ["find", "/usr/share/applications", Qt.getenv("HOME") + "/.local/share/applications", 
                  "-maxdepth", "1", "-name", "*.desktop", "-type", "f"]
        
        onFinished: {
            parseDesktopFiles(stdout)
        }
        
        onError: (msg) => {
            console.error("[AppLauncher] Load error:", msg)
            appLauncher.error(msg)
        }
    }
    
    Process {
        id: launchProcess
        
        onError: (msg) => {
            console.error("[AppLauncher] Launch error:", msg)
            appLauncher.error(msg)
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    function initialize() {
        console.log("[AppLauncher] Initializing...")
        loadApplications()
    }
    
    Component.onCompleted: {
        console.log("[AppLauncher] Module loaded")
    }
}
