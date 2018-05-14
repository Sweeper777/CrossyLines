import UIKit
import Eureka

class SettingsController: FormViewController {
    
    weak var delegate: SettingsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section(footer: "Drag the number handle to the left or right to change it!".localized)
        <<< AnimatedStepperRow("nodeCount") {
            row in
            row.cell.label.text = "Number of nodes".localized
            row.cell.stepper.minimumValue = 7
            row.cell.stepper.maximumValue = 40
            row.value = UserSettings.nodeCount
        }
        .onChange({ (row) in
            UserSettings.nodeCount = row.value ?? UserSettings.nodeCount
        })
        <<< AnimatedStepperRow("maxConnections") {
            row in
            row.cell.label.text = "Max Connections".localized
            row.cell.stepper.minimumValue = 4
            row.cell.stepper.maximumValue = 8
            row.value = UserSettings.maxConnectionCount
        }
        .onChange({ (row) in
            UserSettings.maxConnectionCount = row.value ?? UserSettings.maxConnectionCount
        })
        
        form +++ SwitchRow("colorCodeConnections") {
            row in
            row.title = "Color Code Connections".localized
            row.value = UserSettings.colorCodeConnections
        }
        .onChange({ [weak self] (row) in
            UserSettings.colorCodeConnections = row.value ?? UserSettings.colorCodeConnections
            self?.delegate?.didChangeImportantSetting()
        })
        
        form +++ Section("Node size".localized)
        
        <<< SegmentedRow<Int>("nodeSize") {
            row in
            row.options = [30, 60, 90]
            row.displayValueFor = { value in
                guard let x = value else { return "" }
                switch x {
                case 30: return "Small".localized
                case 60: return "Medium".localized
                case 90: return "Large".localized
                default: return ""
                }
            }
            row.value = UserSettings.nodeSize
        }
        .onChange({ [weak self] (row) in
            UserSettings.nodeSize = row.value ?? UserSettings.nodeSize
            self?.delegate?.didChangeImportantSetting()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserSettings.saveUserSettings()
    }
    
    @IBAction func done() {
        self.dismiss(animated: true, completion: nil)
    }
}
