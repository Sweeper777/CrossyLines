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
    
    @IBAction func stepperValueChanged(){
        row.value = stepper.value
        row.updateCell()
    }
    
    override func update() {
        if let value = row.value {
            stepper.value = value
        }
    }
    
    override func setup() {
        stepper.valueBackgroundColor = UIColor.blue.lighter()
        stepper.operationSymbolsColor = .white
        stepper.backgroundColor = UIColor.blue.darker()
        stepper.tintColor = .white
    }
}
