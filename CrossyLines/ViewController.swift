import UIKit

class ViewController: UIViewController {

    @IBOutlet var graphView: GraphView!
    
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

