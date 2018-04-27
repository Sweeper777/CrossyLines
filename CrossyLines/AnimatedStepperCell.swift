import UIKit
import Eureka
import Stepperier

class AnimatedStepperCell: Cell<Int>, CellType {
    @IBOutlet var stepper: Stepperier!
    @IBOutlet var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
}
