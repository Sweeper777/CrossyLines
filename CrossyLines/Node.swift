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
    
}
