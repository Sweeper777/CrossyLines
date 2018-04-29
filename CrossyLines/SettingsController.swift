import UIKit
import Eureka

class SettingsController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section(footer: "Drag the number handle to the left or right to change it!")
        <<< AnimatedStepperRow("nodeCount") {
            row in
            row.cell.label.text = "Number of nodes"
            row.cell.stepper.minimumValue = 7
            row.cell.stepper.maximumValue = 40
            row.value = UserSettings.nodeCount
        }
        .onChange({ (row) in
            UserSettings.nodeCount = row.value ?? UserSettings.nodeCount
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserSettings.saveUserSettings()
    }
}
