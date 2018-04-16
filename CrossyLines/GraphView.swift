import UIKit
import SwiftyUtils
import UIView_draggable

class GraphView: UIView {
    private var nodeViewsToNodes: [NodeView: Node] = [:]
    private var displayLink: CADisplayLink!
    
    override func draw(_ rect: CGRect) {
        if graph == nil { return }
        
        let path = UIBezierPath()
        path.lineWidth = 2
        for connection in graph.connections {
            path.move(to: CGPoint(x: connection.node1.x, y: connection.node1.y))
            path.addLine(to: CGPoint(x: connection.node2.x, y: connection.node2.y))
        }
        UIColor.black.setStroke()
        path.stroke()
    }
    
}
