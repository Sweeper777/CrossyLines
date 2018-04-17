import UIKit

@IBDesignable
class NodeView: UIView {
    override func draw(_ rect: CGRect) {
        let inset = self.bounds.width / 4
        let insettedRect =  self.bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(ovalIn: insettedRect)
        path.lineWidth = insettedRect.width / 10
        UIColor.yellow.setFill()
        UIColor.black.setStroke()
        path.fill()
        path.stroke()
    }
}
