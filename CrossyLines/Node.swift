import CoreGraphics
struct Point: Hashable {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    var hashValue: Int {
        return x * 31 + y
    }
}

class Node: Hashable {
    var x: CGFloat
    var y: CGFloat
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    func samePointAs(_ node: Node) -> Bool {
        return x == node.x && y == node.y
    }
}

struct Connection: Hashable, CustomStringConvertible {
    let node1: Node
    let node2: Node
    
    func isConnected(to node: Node) -> Bool {
        return node1 == node || node2 == node
    }
    
    func intersects(with connection: Connection) -> Bool {
        let p1 = self.node1
        let p2 = self.node2
        let p3 = connection.node1
        let p4 = connection.node2
        let d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x)
        if d == 0 {
            return false
        }
        
        let u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d
        let v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d
        if !(0.0...1.0).contains(u) || !(0.0...1.0).contains(v) {
            return false
        }
        return true
    }
    
    static func ==(lhs: Connection, rhs: Connection) -> Bool {
        return lhs.isConnected(to: rhs.node1) && lhs.isConnected(to: rhs.node2)
    }
    
    var hashValue: Int {
        return node1.hashValue ^ node2.hashValue
    }
    var description: String {
        return "(\(node1.x), \(node1.y), \(node2.x), \(node2.y))"
    }
}

class Graph {
    var nodes: Array<Node>
    var connections: Set<Connection>
    
    private func nodeArrayInOrderOfDegree(degreesDict: [Node: Int]) -> [Node] {
        return nodes.sorted(by: { (a, b) -> Bool in
            return (degreesDict[a] ?? 0) <= (degreesDict[b] ?? 0)
        })
    }
    
    private func nodeArrayInOrderOfDistance(to node: Node) -> [Node] {
        return Array(nodes.sorted(by: { (a, b) -> Bool in
            let aDist = sqrt(pow(a.x - node.x, 2) + pow(a.y - node.y, 2))
            let bDist = sqrt(pow(b.x - node.x, 2) + pow(b.y - node.y, 2))
            return aDist < bDist
        }).dropFirst())
    }
    
    init(nodeCount: Int, maxDegree: Int) {
        nodes = []
        var usedPoints = Set<Point>()
        for _ in 0..<nodeCount {
            while true {
                let point = Point(x: Int.random(0, nodeCount / 2), y: Int.random(0, nodeCount / 2))
                if usedPoints.insert(point).inserted {
                    break
                }
            }
        }
        
        for point in usedPoints {
            nodes.append(Node(x: CGFloat(point.x * 40), y: CGFloat(point.y * 40)))
        }
        
        var degrees = [Node: Int]()
        connections = []
        var edgeAdded = false
        addEdge: while true {
            edgeAdded = false
            for nodeToAddEdge in nodeArrayInOrderOfDegree(degreesDict: degrees) {
                let nearestNeighbours = nodeArrayInOrderOfDistance(to: nodeToAddEdge)
                for neighbour in nearestNeighbours {
                    let candidateEdge = Connection(node1: nodeToAddEdge, node2: neighbour)
                    let notDuplicate = !connections.contains(candidateEdge)
                    let notIntersecting = !connections.contains { $0.intersects(with: candidateEdge) }
                    let notExceedingMaxDegree = (degrees[nodeToAddEdge] ?? 0) < maxDegree && (degrees[neighbour] ?? 0) < maxDegree
                    if notDuplicate && notIntersecting && notExceedingMaxDegree {
                        connections.insert(candidateEdge)
                        degrees[nodeToAddEdge] = (degrees[nodeToAddEdge] ?? 0) + 1
                        degrees[neighbour] = (degrees[neighbour] ?? 0) + 1
                        edgeAdded = true
                        continue addEdge
                    }
                }
            }
            if !edgeAdded {
                break
            }
        }
        print(degrees)
    }
}
