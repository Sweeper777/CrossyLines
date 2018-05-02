import UIKit
import CircleMenu
import SCLAlertView_Objective_C
import Kamishibai

class ViewController: UIViewController, CircleMenuDelegate, GraphViewDelegate {

    @IBOutlet var graphView: GraphView!
    @IBOutlet var circleMenu: CircleMenu!
    @IBOutlet var newButton: UIButton!
    
    var graph : Graph!
    var solutionGraph: Graph!
    var solved = false
    
    lazy var kamishibai: Kamishibai = {
        return Kamishibai(initialViewController: self)
    }()
    var cover: UIVisualEffectView!
    var introView: MYBlurIntroductionView!
    
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
        
        newGraph()
        self.graphView.delegate = self
        self.graphView.syncDrawing()
        
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
        case 1:
            performSegue(withIdentifier: "showSettings", sender: nil)
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
            
            SCLAlertView().showSuccess(self, title: "Congratulations!", subTitle: "You completed the puzzle! Tap \"NEW\" to do another one!", closeButtonTitle: "OK", duration: 0)
        }
    }
    
    @IBAction func newGraph() {
        circleMenu?.hideButtons(circleMenu.duration)
        DispatchQueue.main.async {
            [weak self] in
            guard let `self` = self else { return }
            self.graph = Graph(nodeCount: UserSettings.nodeCount, maxDegree: UserSettings.maxConnectionCount)
            self.solutionGraph = self.graph.createCopy()
            self.graph.shuffle(within: self.graphView.bounds)
            self.graphView.graph = self.graph
            self.solved = false
            
        }
    }
    
    func repositionViews() {
        guard traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular else { return }
        
        newButton.removeFromSuperview()
        circleMenu.removeFromSuperview()
        
        let safeArea: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeArea = view.safeAreaInsets
        } else {
            safeArea = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        let circleMenuX: CGFloat
        let circleMenuY: CGFloat
        if graphView.x > graphView.y {
            circleMenuX = safeArea.left + 8
            circleMenuY = view.bounds.midY - 32
        } else {
            circleMenuX = view.bounds.midX - 32
            circleMenuY = safeArea.top + 8
        }
        circleMenu = CircleMenu(frame: CGRect(x: circleMenuX, y: circleMenuY, width: 64, height: 64), normalIcon: "menu-large", selectedIcon: "close-large")
        circleMenu.buttonsCount = 4
        circleMenu.delegate = self
        view.addSubview(circleMenu)
        if graphView.x > graphView.y {
            circleMenu.startAngle = 0
            circleMenu.endAngle = 180
        } else {
            circleMenu.startAngle = 90
            circleMenu.endAngle = 270
        }
        circleMenu.layer.cornerRadius = circleMenu.width / 2
        circleMenu.layer.borderWidth = 2
        circleMenu.duration = 0.5
        circleMenu.backgroundColor = .white
        circleMenu.distance *= 2
        
        let newButtonFrame: CGRect
        if graphView.x > graphView.y {
            let newButtonX = view.width - safeArea.right - 8 - 64
            newButtonFrame = CGRect(x: newButtonX, y: circleMenuY, width: 64, height: 64)
        } else {
            let newButtonY = view.height - safeArea.bottom - 8 - 64
            newButtonFrame = CGRect(x: circleMenuX, y: newButtonY, width: 64, height: 64)
        }
        newButton = UIButton(type: .custom)
        newButton.frame = newButtonFrame
        newButton.setImage(#imageLiteral(resourceName: "new-large"), for: .normal)
        newButton.layer.cornerRadius = newButton.width / 2
        newButton.layer.borderWidth = 2
        newButton.setImage(#imageLiteral(resourceName: "new-large").withRenderingMode(.alwaysTemplate), for: .highlighted)
        newButton.addTarget(self, action: #selector(newGraph), for: .touchUpInside)
        newButton.backgroundColor = .white
        newButton.tintColor = UIColor(hex: "d2d2d2")
        view.addSubview(newButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        repositionViews()
            showTutorial()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.repositionViews()
        }
    }
    
    func showTutorial() {
//        kamishibai.append(KamishibaiScene(scene: { [weak self] (scene) in
//            guard let `self` = self else { return }
//            scene.kamishibai?.focus.on(view: self.graphView, focus: Focus.Rect(frame: self.graphView.frame), completion: nil)
//            scene.kamishibai?.focus.addCustomView(view: GuideLabel("Welcome to KnottyLines!"), position: .center(self.graphView.center))
//            scene.fulfillWhenTapFocus()
//        }))
//        kamishibai.startStory()
    }
}

