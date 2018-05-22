import UIKit
import CircleMenu
import SCLAlertView_Objective_C
import Kamishibai
import MYBlurIntroductionView
import NYXImagesKit
import SwiftyJSON
import GoogleMobileAds

class ViewController: UIViewController {

    @IBOutlet var graphView: GraphView!
    @IBOutlet var circleMenu: CircleMenu!
    @IBOutlet var newButton: UIButton!
    
    var graph : Graph!
    var solutionGraph: Graph!
    var solved = false
    var cover: UIVisualEffectView!
    var introView: MYBlurIntroductionView!
    
    let items: [(icon: String, color: UIColor)] = [
        ("restart", UIColor(red: 0.19, green: 0.57, blue: 1, alpha: 1)),
        ("options", UIColor(red: 0.22, green: 0.74, blue: 0, alpha: 1)),
        ("solution", UIColor(red: 0.96, green: 0.23, blue: 0.21, alpha: 1)),
        ("help", UIColor(red: 0.51, green: 0.15, blue: 1, alpha: 1)),
        ]
    
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let nodeView = NodeView(frame: CGRect(x: 100, y: 100, width: 30, height: 30))
//        nodeView.backgroundColor = .clear
//        addObserver(self, forKeyPath: "", options: [.new], context: nil)
//        self.view.addSubview(nodeView)
        
        if !loadGraph() {
            newGraph()
        }
        self.graphView.delegate = self
//        self.graphView.syncDrawing()
        
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
        
        interstitial = AdHelper.getInterstitial(delegate: self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if self.traitCollection.horizontalSizeClass == .regular &&
            self.traitCollection.verticalSizeClass == .regular {
            return .all
        } else {
            return .portrait
        }
    }
    
    @IBAction func newGraph() {
        circleMenu?.hideButtons(circleMenu.duration)
        
        if arc4random_uniform(10) == 0 && interstitial?.isReady ?? false {
            interstitial.present(fromRootViewController: self)
        }
        
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
    
    func loadGraph() -> Bool {
        guard let json = try? JSON(data: UserDefaults.standard.data(forKey: "lastPlayed") ?? Data(bytes: [])) else { return false }
        guard let solutionJSON = try? JSON(data: UserDefaults.standard.data(forKey: "lastPlayedSolution") ?? Data(bytes: [])) else { return false }
        guard let graph = Graph.fromJSON(json) else { return false }
        guard let solutionGraph = Graph.fromJSON(solutionJSON) else { return false }
        DispatchQueue.main.async {
            [weak self] in
            self?.graph = graph
            self?.solutionGraph = solutionGraph
            self?.graphView.graph = graph
            self?.solved = false
        }
        return true
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
        if !UserDefaults.standard.bool(forKey: "tutorialCompleted") {
            showTutorial()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.repositionViews()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? SettingsController {
            vc.delegate = self
        }
    }
    
    func showTutorial() {
        if cover == nil {
            cover = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            cover.frame = view.bounds
        }
        view.addSubview(cover)
        let panel1 = MYIntroductionPanel(frame: cover.bounds, title: "Welcome!".localized, description: "Knotty Lines is a simple puzzle game for killing time. Swipe left to go to the next page for how to play!".localized, image: #imageLiteral(resourceName: "tutorial-appicon").scale(toFit: cover.frame.insetBy(dx: 30, dy: 30).size))!
        let panel2 = MYIntroductionPanel(frame: cover.bounds, title: "How to Play".localized, description: "The puzzle starts off like this, with these little yellow dots called \"nodes\" that are connected by lines. The lines intersect each other.".localized, image: #imageLiteral(resourceName: "tutorial-originalpuzzle").scale(toFit: cover.frame.insetBy(dx: 30, dy: 30).size))!
        let panel3 = MYIntroductionPanel(frame: cover.bounds, title: "How to Play".localized, description: "You need to move the nodes so that no line intersect any other lines, just like this:".localized, image: #imageLiteral(resourceName: "tutorial-finishedpuzzle").scale(toFit: cover.frame.insetBy(dx: 30, dy: 30).size))!
        let panel4 = MYIntroductionPanel(frame: cover.bounds, title: "New Puzzle".localized, description: "You can tap on this button to randomly generate a new puzzle!".localized, image: #imageLiteral(resourceName: "tutorial-newbutton"))!
        let panel5 = MYIntroductionPanel(frame: cover.bounds, title: "Menu".localized, description: "This is the menu button. Tap on it and more buttons will show up. They will be explained in the next page!".localized, image: #imageLiteral(resourceName: "tutorial-menubutton"))!
        let panel6 = MYIntroductionPanel(frame: cover.bounds, title: "Menu".localized, description: "From bottom left to top right:\nRestart the puzzle\nSettings\nShow a solution\nShow this tutorial".localized, image: #imageLiteral(resourceName: "tutorial-menubuttons").scale(toFit: cover.frame.insetBy(dx: 30, dy: 30).size))!
        let panel7 = MYIntroductionPanel(frame: cover.bounds, title: "Have Fun!".localized, description: "That's it! Have fun playing with the naughty lines!".localized, image: #imageLiteral(resourceName: "tutorial-appicon").scale(toFit: cover.frame.insetBy(dx: 30, dy: 30).size))!
        
        introView = MYBlurIntroductionView(frame: cover.bounds)
        introView.buildIntroduction(withPanels: [panel1, panel2, panel3, panel4, panel5, panel6, panel7])
        introView.rightSkipButton.setTitle("Skip".localized, for: .normal)
        introView.delegate = self
        cover.contentView.addSubview(introView)
    }
}

extension ViewController: CircleMenuDelegate {
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        switch atIndex {
        case 0:
            let originalGraph = graph.createCopy()
            originalGraph.shuffle(within: graphView.bounds)
            graphView.animate(to: originalGraph, frameCount: 30)
        case 1:
            performSegue(withIdentifier: "showSettings", sender: nil)
        case 2:
            let insettedRect = self.graphView.bounds.insetBy(dx: UserSettings.nodeSizeHalf.f, dy: UserSettings.nodeSizeHalf.f)
            let graphCopy = solutionGraph.createCopy()
            graphCopy.scale(toFit: insettedRect)
            self.graphView.animate(to: graphCopy, frameCount: 120)
            self.solved = true
        case 3:
            showTutorial()
        default:
            break
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
}

extension ViewController: GraphViewDelegate {
    func graphViewDidStartDragging(nodeView: NodeView) {
        graphView.syncDrawing()
        circleMenu?.hideButtons(circleMenu.duration)
    }
    
    func graphViewDidEndDragging(nodeView: NodeView) {
        graphView.unsyncDrawing()
        if !solved && !graph.checkIntersections().values.contains(true) {
            solved = true
            
            SCLAlertView().showSuccess(self, title: "Congratulations!".localized, subTitle: "You completed the puzzle! Tap \"NEW\" to do another one!".localized, closeButtonTitle: "OK".localized, duration: 0)
        }
    }
    
}

extension ViewController: MYIntroductionDelegate {
    func introduction(_ introductionView: MYBlurIntroductionView!, didFinishWith finishType: MYFinishType) {
        cover.removeFromSuperview()
        
        UserDefaults.standard.set(true, forKey: "tutorialCompleted")
    }
}

extension ViewController: SettingsControllerDelegate {
    func didChangeImportantSetting() {
        graphView.redrawAllNodes()
    }
}

extension ViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = AdHelper.getInterstitial(delegate: self)
    }
}
