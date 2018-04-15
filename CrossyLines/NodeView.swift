import UIKit

@IBDesignable
class NodeView: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: self.bounds.insetBy(dx: 1.5, dy: 1.5))
        path.lineWidth = 3
        UIColor.yellow.setFill()
        UIColor.black.setStroke()
        path.fill()
        path.stroke()
    }
}
