import UIKit

class GuideLabel: UILabel {
    init(_ text: String) {
        super.init(frame: CGRect.zero)
        self.text = text
        self.numberOfLines = 0
        self.sizeToFit()
        self.backgroundColor = .white
        self.layer.cornerRadius = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
