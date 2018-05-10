import SwiftyJSON

extension Graph {
    func toJSON() -> JSON {
        var nodesJSON: JSON = [:]
        var backwardsDict = [Node: Int]()
        for (i, node) in self.nodes.enumerated() {
            nodesJSON["node\(i)"] = ["x": node.x, "y": node.y]
            backwardsDict[node] = i
        }
    }
}
