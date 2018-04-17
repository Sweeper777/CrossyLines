import UIKit

class ViewController: UIViewController {

    @IBOutlet var graphView: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let nodeView = NodeView(frame: CGRect(x: 100, y: 100, width: 30, height: 30))
//        nodeView.backgroundColor = .clear
//        addObserver(self, forKeyPath: "", options: [.new], context: nil)
//        self.view.addSubview(nodeView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if self.traitCollection.horizontalSizeClass == .regular &&
            self.traitCollection.verticalSizeClass == .regular {
            return .all
        } else {
            return .portrait
        }
    }
}

