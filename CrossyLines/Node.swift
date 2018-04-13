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
}
