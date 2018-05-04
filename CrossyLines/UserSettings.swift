import Foundation

class UserSettings {
    static var nodeCount: Int = 7
    static var maxConnectionCount = 4
    static var colorCodeConnections = true
    static var nodeSize: Double = 30
    static var nodeSizeHalf: Double {
        return nodeSize / 2.0
    }
    
    static func loadUserSettings() {
        let defaults = UserDefaults.standard
        nodeCount = defaults.has(key: "nodeCount") ? defaults.integer(forKey: "nodeCount") : 7
        maxConnectionCount = defaults.has(key: "maxConnectionCount") ? defaults.integer(forKey: "maxConnectionCount") : 4
        colorCodeConnections = defaults.has(key: "colorCodeConnections") ? defaults.bool(forKey: "colorCodeConnections") : true
        nodeSize = defaults.has(key: "nodeSize") ? defaults.double(forKey: "nodeSize") : 30
    }
    
    static func saveUserSettings() {
        let defaults = UserDefaults.standard
        defaults.set(nodeCount, forKey: "nodeCount")
        defaults.set(maxConnectionCount, forKey: "maxConnectionCount")
        defaults.set(colorCodeConnections, forKey: "colorCodeConnections")
    }
}
