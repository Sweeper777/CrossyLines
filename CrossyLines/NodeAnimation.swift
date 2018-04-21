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
    
}
