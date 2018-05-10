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
    
    static func fromJSON(_ json: JSON) -> Graph? {
        let jsonNodes = json["nodes"]
        let jsonConnections = json["connections"]
        var nodes = [Node]()
        var connections = Set<Connection>()
        
        var dict: [Int: Node] = [:]
        for (key, jsonNode) in jsonNodes {
            guard let x = jsonNode["x"].double else { return nil }
            guard let y = jsonNode["y"].double else { return nil }
            let node = Node(x: x.f, y: y.f)
            nodes.append(node)
            guard let nodeNumber = Int(String(key.dropFirst(4))) else { return nil }
            dict[nodeNumber] = node
        }
        
        for (_, jsonConnection) in jsonConnections {
            guard let from = jsonConnection["from"].int else { return nil }
            guard let to = jsonConnection["to"].int else { return nil }
            guard let fromNode = dict[from] else { return nil }
            guard let toNode = dict[to] else { return nil }
            connections.insert(Connection(node1: fromNode, node2: toNode))
        }
        
        return Graph(nodes: nodes, connections: connections)
    }
}
