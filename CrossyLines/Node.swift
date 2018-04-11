import CoreGraphics

class Node: Hashable {
    var x: CGFloat = 0
    var y: CGFloat = 0
    
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}
