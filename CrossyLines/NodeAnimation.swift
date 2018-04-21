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
    
}
