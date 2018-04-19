import UIKit
import CircleMenu

class ViewController: UIViewController, CircleMenuDelegate {

    @IBOutlet var graphView: GraphView!
    @IBOutlet var circleMenu: CircleMenu!
    
    let items: [(icon: String, color: UIColor)] = [
        ("restart", UIColor(red: 0.19, green: 0.57, blue: 1, alpha: 1)),
        ("options", UIColor(red: 0.22, green: 0.74, blue: 0, alpha: 1)),
        ("solution", UIColor(red: 0.96, green: 0.23, blue: 0.21, alpha: 1)),
        ("help", UIColor(red: 0.51, green: 0.15, blue: 1, alpha: 1)),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let nodeView = NodeView(frame: CGRect(x: 100, y: 100, width: 30, height: 30))
//        nodeView.backgroundColor = .clear
//        addObserver(self, forKeyPath: "", options: [.new], context: nil)
//        self.view.addSubview(nodeView)
        
        DispatchQueue.main.async {
            let graph = Graph(nodeCount: 20, maxDegree: 4)
            graph.shuffle(within: self.graphView.bounds)
            self.graphView.graph = graph
            self.graphView.syncDrawing()
        }
        
        if let menu = circleMenu {
            menu.delegate = self
            menu.startAngle = 270
            menu.endAngle = 360
            menu.layer.cornerRadius = menu.width / 2
            menu.layer.borderWidth = 2
        }
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

