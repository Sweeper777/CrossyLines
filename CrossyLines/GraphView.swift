import UIKit
import SwiftyUtils
import UIView_draggable

class GraphView: UIView {
    
    private var nodeViewsToNodes: [NodeView: Node] = [:]
    private var displayLink: CADisplayLink!
    
    private var animations = [NodeAnimation]()
    
    weak var delegate: GraphViewDelegate?
    
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
                    nodeView.draggingStartedBlock = { [weak self] view in
                        self?.delegate?.graphViewDidStartDragging(nodeView: view as! NodeView) }
                    nodeView.draggingEndedBlock = { [weak self] view in
                        self?.delegate?.graphViewDidEndDragging(nodeView: view as! NodeView) }
                    self.addSubview(nodeView)
                    nodeViewsToNodes[nodeView] = node
                }
            }
            
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if graph == nil { return }
        
        let intersectionDict = graph.checkIntersections()
        
        for connection in graph.connections {
            let path = UIBezierPath()
            path.lineWidth = 2
            path.move(to: CGPoint(x: connection.node1.x, y: connection.node1.y))
            path.addLine(to: CGPoint(x: connection.node2.x, y: connection.node2.y))
            if UserSettings.colorCodeConnections {
                if intersectionDict[connection] ?? false {
                    UIColor.red.setStroke()
                } else {
                    UIColor.green.darker().setStroke()
                }
            } else {
                UIColor.black.setStroke()
            }
            path.stroke()
        }
    }
    
    func syncDrawing() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateNodePositions))
        displayLink.add(to: .main, forMode: .defaultRunLoopMode)
    }
    
    @objc func updateNodePositions() {
        if animations.isNotEmpty {
            animations.forEach { $0.nextFrame() }
            zip(subviews, animations).forEach({ (tuple) in
                tuple.0.frame.origin = tuple.1.currentPosition
            })
            if animations.contains(where: { $0.completed }) {
                animations.removeAll()
                subviews.forEach { $0.enableDragging() }
            }
        }
        
        for kvp in nodeViewsToNodes {
            kvp.value.x = kvp.key.x + 15
            kvp.value.y = kvp.key.y + 15
        }
        setNeedsDisplay()
    }
    
    func animate(to graph: Graph, frameCount: Int) {
        subviews.forEach { $0.setDraggable(false) }
        animations = zip(self.subviews, graph.nodes).map {
            NodeAnimation(from: $0.0.frame.origin, to: CGPoint(x: $0.1.x - 15, y: $0.1.y - 15), totalFrames: frameCount)
        }
    }
}
