import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: wallpaperManager
    
    // ═══════════════════════════════════════════════════════════
    // SIGNALS
    // ═══════════════════════════════════════════════════════════
    signal wallpaperApplied(string path)
    signal wallpapersLoaded()
    signal error(string message)
    
    // ═══════════════════════════════════════════════════════════
    // PROPERTIES
    // ═══════════════════════════════════════════════════════════
    property string wallpaperDir: Quickshell.env("HOME") + "/Qubar/wallpapers"
    property string currentWallpaper: wallpaperDir + "/current.jpg"
    
    property var wallpapers: []           // Array of wallpaper objects
    property var filteredWallpapers: []   // Filtered list for search
    property bool loading: false
    property string searchQuery: ""
    
    // Wallpaper categories
    readonly property var categories: [
        "All",
        "Anime",
        "Nature",
        "Abstract",
        "City",
        "Dark",
        "Light"
    ]
    property string activeCategory: "All"
    
    // ═══════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════
    
    function loadWallpapers() {
        console.log("[WallpaperManager] Loading wallpapers from:", wallpaperDir)
        loading = true
        wallpapers = []
        
        // Use Process to list wallpapers
        scanProcess.running = true
    }
    
    function filterWallpapers(query) {
        searchQuery = query.toLowerCase()
        
        if (searchQuery === "" && activeCategory === "All") {
            filteredWallpapers = wallpapers
            return
        }
        
        filteredWallpapers = wallpapers.filter(function(wp) {
            // Filter by search query
            var matchesSearch = searchQuery === "" || 
                               wp.name.toLowerCase().includes(searchQuery) ||
                               wp.basename.toLowerCase().includes(searchQuery)
            
            // Filter by category
            var matchesCategory = activeCategory === "All" ||
                                 wp.category === activeCategory
            
            return matchesSearch && matchesCategory
        })
        
        console.log("[WallpaperManager] Filtered:", filteredWallpapers.length, "wallpapers")
    }
    
    function setCategory(category) {
        activeCategory = category
        filterWallpapers(searchQuery)
    }
    
    function applyWallpaper(path) {
        console.log("[WallpaperManager] Applying wallpaper:", path)
        
        // Call set-wallpaper.sh script
        applyProcess.command = [
            Quickshell.env("HOME") + "/Qubar/scripts/set-wallpaper.sh",
            path
        ]
        applyProcess.running = true
    }
    
    function categorizeWallpaper(filename) {
        var lower = filename.toLowerCase()
        
        if (lower.includes("anime") || lower.includes("girl") || lower.includes("manga")) {
            return "Anime"
        } else if (lower.includes("nature") || lower.includes("forest") || 
                   lower.includes("mountain") || lower.includes("landscape") ||
                   lower.includes("tree") || lower.includes("beach")) {
            return "Nature"
        } else if (lower.includes("abstract") || lower.includes("geometric")) {
            return "Abstract"
        } else if (lower.includes("city") || lower.includes("street") || 
                   lower.includes("building") || lower.includes("urban")) {
            return "City"
        } else if (lower.includes("dark") || lower.includes("night")) {
            return "Dark"
        } else if (lower.includes("light") || lower.includes("bright")) {
            return "Light"
        } else {
            return "All"
        }
    }
    
    function parseWallpaperList(output) {
        var lines = output.trim().split('\n')
        var newWallpapers = []
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line === "" || line.includes("Dynamic-Wallpapers")) {
                continue  // Skip empty lines and Dynamic-Wallpapers subdirs
            }
            
            // Extract basename from path
            var parts = line.split('/')
            var basename = parts[parts.length - 1]
            var nameWithoutExt = basename.replace(/\.(jpg|png|jpeg|webp)$/i, '')
            
            // Clean up name (replace dashes/underscores with spaces, capitalize)
            var cleanName = nameWithoutExt
                .replace(/_/g, ' ')
                .replace(/-/g, ' ')
                .replace(/\b\w/g, function(c) { return c.toUpperCase() })
            
            var wallpaper = {
                path: line,
                basename: basename,
                name: cleanName,
                category: categorizeWallpaper(basename)
            }
            
            newWallpapers.push(wallpaper)
        }
        
        console.log("[WallpaperManager] Loaded", newWallpapers.length, "wallpapers")
        wallpapers = newWallpapers
        filteredWallpapers = newWallpapers
        loading = false
        wallpapersLoaded()
    }
    
    // ═══════════════════════════════════════════════════════════
    // PROCESSES
    // ═══════════════════════════════════════════════════════════
    
    Process {
        id: scanProcess
        command: [
            "find",
            wallpaperManager.wallpaperDir,
            "-maxdepth", "1",
            "-type", "f",
            "(",
            "-name", "*.jpg",
            "-o", "-name", "*.png",
            "-o", "-name", "*.jpeg",
            "-o", "-name", "*.webp",
            ")",
            "-not", "-name", "current.jpg"
        ]
        running: false
        
        onExited: (code, status) => {
            if (status === Process.NormalExit && code === 0) {
                wallpaperManager.parseWallpaperList(scanProcess.stdout())
            } else {
                console.error("[WallpaperManager] Failed to scan wallpapers:", scanProcess.stderr())
                wallpaperManager.error("Failed to load wallpapers")
                wallpaperManager.loading = false
            }
        }
    }
    
    Process {
        id: applyProcess
        running: false
        
        onExited: (code, status) => {
            if (status === Process.NormalExit && code === 0) {
                console.log("[WallpaperManager] Wallpaper applied successfully")
                wallpaperManager.wallpaperApplied(applyProcess.command[1])
            } else {
                console.error("[WallpaperManager] Failed to apply wallpaper:", applyProcess.stderr())
                wallpaperManager.error("Failed to apply wallpaper")
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════
    
    Component.onCompleted: {
        console.log("[WallpaperManager] Module loaded")
        loadWallpapers()
    }
}
