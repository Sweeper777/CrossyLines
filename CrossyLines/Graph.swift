import CoreGraphics
import SwiftRandom

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
        func randomPoints(_ nodeCount: Int) -> Set<Point> {
            var points = Set<Point>()
            for _ in 0..<nodeCount {
                while true {
                    let point = Point(x: Int.random(0, nodeCount / 2), y: Int.random(0, nodeCount / 2))
                    if points.insert(point).inserted {
                        break
                    }
                }
            }
            return points
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
    }
    
    init(nodes: [Node], connections: Set<Connection>) {
        self.nodes = nodes
        self.connections = connections
    }
    
    func shuffle(within rect: CGRect) {
        let inset: CGFloat = UserSettings.nodeSizeHalf.f
        let insetRect = rect.insetBy(dx: inset, dy: inset)
        let coordinates = coordinatesOnEllipse(halfWidth: Double(insetRect.width / 2), halfHeight: Double(insetRect.height / 2), count: self.nodes.count)
        zip(self.nodes, coordinates).forEach { pair in
            pair.0.x = pair.1.x.f + inset
            pair.0.y = pair.1.y.f + inset
        }
    }
    
    func checkIntersections() -> [Connection: Bool] {
        var dict = [Connection: Bool]()
//        var tempConnections = connections
//        while true {
//            if let connectionToCheck = tempConnections.subtracting(dict.keys).first {
//                let intersections = Set(tempConnections.filter { connectionToCheck.intersects(with: $0) })
//                if intersections.isEmpty {
//                    dict[connectionToCheck] = false
//                    tempConnections.remove(connectionToCheck)
//                } else {
//                    dict[connectionToCheck] = true
//                    for connection in intersections {
//                        dict[connection] = true
//                    }
//                }
//            } else {
//                break
//            }
//        }
        
        let arrConnections = Array(connections)
        for i in 0..<arrConnections.count {
            for j in (i+1)..<arrConnections.count {
                if arrConnections[i].intersects(with: arrConnections[j]) {
                    dict[arrConnections[i]] = true
                    dict[arrConnections[j]] = true
                }
            }
        }
        return dict
    }
    
    func scale(toFit rect: CGRect) {
        let maxX = nodes.map { $0.x }.max()!
        let maxY = nodes.map { $0.y }.max()!
        let dx = rect.width / maxX
        let dy = rect.height / maxY
        nodes.forEach {
            $0.x *= dx
            $0.y *= dy
            $0.x += rect.x
            $0.y += rect.y
        }
    }
    
    func createCopy() -> Graph {
        let newNodes = nodes.map { $0.createCopy() }
        var newConnections = Set<Connection>()
        for connection in connections {
            let index1 = nodes.index(of: connection.node1)!
            let index2 = nodes.index(of: connection.node2)!
            newConnections.insert(Connection(node1: newNodes[index1], node2: newNodes[index2]))
        }
        return Graph(nodes: newNodes, connections: newConnections)
    }
}

fileprivate func coordinatesOnEllipse(halfWidth: Double, halfHeight: Double, count: Int) -> [(x: Double, y: Double)] {
    var coordinates = [(Double, Double)]()
    
    var theta = 0.0
    let twoPi = Double.pi * 2
    let deltaTheta = 0.0001
    let numIntegrals = Int(round(twoPi / deltaTheta))
    var circ = 0.0
    var dpt = 0.0
    
    for i in 0..<numIntegrals {
        theta += Double(i) * deltaTheta
        dpt = computeDpt(width: halfWidth, height: halfHeight, theta: theta)
        circ += dpt
    }
    var nextPoint = 0
    var run = 0.0
    theta = 0.0
    for _ in 0..<numIntegrals {
        theta += deltaTheta;
        let subIntegral = Double(count) * run / circ;
        if Int(subIntegral) >= nextPoint {
            let x = halfWidth * cos(theta)
            let y = halfHeight * sin(theta)
            coordinates.append((x, y))
            nextPoint += 1
        }
        run += computeDpt(width: halfWidth, height: halfHeight, theta: theta)
    }
    return coordinates.map { ($0.0 + halfWidth, $0.1 + halfHeight) }
}

fileprivate func computeDpt(width: Double, height: Double, theta: Double) -> Double {
    let dpt_sin = pow(width * sin(theta), 2.0)
    let dpt_cos = pow(height * cos(theta), 2.0)
    return sqrt(dpt_sin + dpt_cos)
}

