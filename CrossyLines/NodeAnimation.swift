import UIKit

class NodeAnimation: CustomStringConvertible {
    let from: CGPoint
    let to: CGPoint
    let totalFrames: Int
    let step: CGFloat
    let totalLength: CGFloat
    
    var currentFrame = 0
    var currentPosition: CGPoint
    
    var completed: Bool {
        return currentFrame >= totalFrames
    }
    
    init(from: CGPoint, to: CGPoint, totalFrames: Int) {
        self.from = from
        self.to = to
        self.totalFrames = totalFrames
        
        currentPosition = from
        
        totalLength = sqrt(pow(to.y - from.y, 2) + pow(to.x - from.x, 2))
        step = totalLength / CGFloat(totalFrames)
    }
    
    func nextFrame() {
        currentFrame += 1
        if totalLength != 0 {
            let k1 = step * CGFloat(currentFrame)
            let k2 = totalLength - k1
            let x = (k1 * to.x + k2 * from.x) / totalLength
            let y = (k1 * to.y + k2 * from.y) / totalLength
            currentPosition = CGPoint(x: x, y: y)
        }
    }
    
}
