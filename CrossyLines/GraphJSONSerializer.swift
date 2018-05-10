import SwiftyJSON

extension Graph {
    func toJSON() -> JSON {
        var nodesJSON: JSON = [:]
        var backwardsDict = [Node: Int]()
        for (i, node) in self.nodes.enumerated() {
            nodesJSON["node\(i)"] = ["x": node.x, "y": node.y]
            backwardsDict[node] = i
        }
        var connectionsJSON: [JSON] = []
        for connection in self.connections {
            connectionsJSON.append(["from": backwardsDict[connection.node1]!, "to": backwardsDict[connection.node2]!])
        }
        return ["nodes": nodesJSON, "connections": connectionsJSON]
    }
}
