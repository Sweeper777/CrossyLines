import UIKit
import SwiftyUtils
import UIView_draggable

class GraphView: UIView {
    private var nodeViewsToNodes: [NodeView: Node] = [:]
    private var displayLink: CADisplayLink!
    
    var graph: Graph! {
        didSet {
            self.subviews.forEach { $0.removeFromSuperview() }
            nodeViewsToNodes = [:]
            
            if graph != nil {
                for node in graph.nodes {
                    let nodeView = NodeView(frame: CGRect(x: node.x - 15, y: node.y - 15, width: 30, height: 30))
                    nodeView.backgroundColor = .clear
                    nodeView.enableDragging()
                    nodeView.cagingArea = self.bounds
                    self.addSubview(nodeView)
                    nodeViewsToNodes[nodeView] = node
                }
            }
            
            self.setNeedsDisplay()
        }
    }
    
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
