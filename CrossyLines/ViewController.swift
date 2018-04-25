import UIKit
import CircleMenu

class ViewController: UIViewController, CircleMenuDelegate, GraphViewDelegate {

    @IBOutlet var graphView: GraphView!
    @IBOutlet var circleMenu: CircleMenu!
    @IBOutlet var newButton: UIButton!
    
    var graph : Graph!
    var solutionGraph: Graph!
    var solved = false
    
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
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return}
            self.graph = Graph(nodeCount: 20, maxDegree: 4)
            self.solutionGraph = self.graph.createCopy()
            self.graph.shuffle(within: self.graphView.bounds)
            self.graphView.graph = self.graph
            self.graphView.delegate = self
            self.graphView.syncDrawing()
        }
        
        if let menu = circleMenu {
            menu.delegate = self
            menu.startAngle = 270
            menu.endAngle = 360
            menu.layer.cornerRadius = menu.width / 2
            menu.layer.borderWidth = 2
        }
        
        if let newButton = self.newButton {
            newButton.layer.cornerRadius = newButton.width / 2
            newButton.layer.borderWidth = 2
            newButton.setImage(#imageLiteral(resourceName: "new").withRenderingMode(.alwaysTemplate), for: .highlighted)
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
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        let largeImage = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular ? "-large" : ""
        
        button.backgroundColor = items[atIndex].color
        
        button.setImage(UIImage(named: items[atIndex].icon + largeImage), for: .normal)
        
        // set highlited image
        let highlightedImage = UIImage(named: items[atIndex].icon + largeImage)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        switch atIndex {
        case 0:
            let originalGraph = graph.createCopy()
            originalGraph.shuffle(within: graphView.bounds)
            graphView.animate(to: originalGraph, frameCount: 30)
        case 2:
            let insettedRect = self.graphView.bounds.insetBy(dx: 15, dy: 15)
            let graphCopy = solutionGraph.createCopy()
            graphCopy.scale(toFit: insettedRect)
            self.graphView.animate(to: graphCopy, frameCount: 120)
            self.solved = true
        default:
            break
        }
        
    }
    
    func graphViewDidStartDragging(nodeView: NodeView) {
        circleMenu?.hideButtons(circleMenu.duration)
    }
    
    func graphViewDidEndDragging(nodeView: NodeView) {
        if !solved && !graph.checkIntersections().values.contains(true) {
            solved = true
            let alert = UIAlertController(title: "Congratulations!", message: "You solved the puzzle! Tap on \"NEW\" to get a new one!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func newGraph() {
        circleMenu?.hideButtons(circleMenu.duration)
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else { return }
            self.graph = Graph(nodeCount: 20, maxDegree: 4)
            self.solutionGraph = self.graph.createCopy()
            self.graph.shuffle(within: self.graphView.bounds)
            self.graphView.graph = self.graph
            self.solved = false
            
        }
    }
}

