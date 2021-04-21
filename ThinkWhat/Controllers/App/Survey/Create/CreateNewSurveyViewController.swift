//
//  CreateNewSurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CreateNewSurveyViewController: UIViewController {
    
    deinit {
        print("***CreateNewSurveyViewController deinit***")
    }
    
    //Sequence of stages to post new survey
    private enum Stage: Int {
        case Category, Anonymity, Privacy, Votes, Title, Question, Hyperlink, Images, Answers, Post
    }
    
    private var stage: Stage = .Category {
        didSet {
            maximumStage = stage
            moveToNextStage()
        }
    }
    
    private var maximumStage: Stage = .Category {
        didSet {
            maximumStage = stage.rawValue <= oldValue.rawValue ? oldValue : maximumStage//Stage(rawValue: maximumStage.rawValue + 1) ?? .Post
        }
    }
    
    private var isViewSetupCompleted = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    
    //MARK: - Category
    var category: SurveyCategory? {
        didSet {
            setTitle()
            if category != nil {
                categoryTitle.alpha = 1
                stage = .Anonymity
                categoryIcon.color = category!.tagColor ?? selectedColor
                categoryIcon.category = SurveyCategoryIcon.Category(rawValue: category!.ID) ?? .Null
                categoryTitle.text = category!.title.uppercased()
            }
        }
    }
    
    @IBOutlet weak var categoryTitle: UILabel! {
        didSet {
            categoryTitle.alpha = 0
            if category == nil {
                categoryTitle.text = "РАЗДЕЛ"
            }
        }
    }
    
    @IBOutlet weak var categoryIcon: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            categoryIcon.addGestureRecognizer(tap)
//            categoryIcon.icon.isFramed = false
            categoryIcon.icon.alpha = 0
            categoryIcon.state = .Off
            categoryIcon.color = selectedColor
            categoryIcon.text = "РАЗДЕЛ"
            categoryIcon.category = .Category_RU
        }
    }
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    //MARK: - Anon
    var isAnonymous = false {
        didSet {
            anonTitle.alpha = 1
            stage = .Privacy
            anonIcon.color = selectedColor
            anonIcon.category = isAnonymous ? SurveyCategoryIcon.Category.Anon : SurveyCategoryIcon.Category.AnonDisabled//SurveyCategoryIcon.Category(rawValue: category!.ID) ?? .Null
        }
    }
    
    @IBOutlet weak var anonTitle: UILabel! {
        didSet {
            anonTitle.alpha = 0
        }
    }
    
    @IBOutlet weak var anonIcon: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            anonIcon.addGestureRecognizer(tap)
            anonIcon.icon.alpha = 0
//            anonIcon.backgroundColor = .clear
            anonIcon.state      = .Off
            anonIcon.category   = .Anon
            anonIcon.color      = selectedColor
        }
    }
    
    @IBOutlet weak var anonLabel: UILabel! {
        didSet {
            anonLabel.alpha = 0
        }
    }
    
    
    
    
    //MARK: - Privacy
    var isPrivate = false {
        didSet {
            privacyTitle.alpha = 1
            stage = .Votes
        }
    }
    
    @IBOutlet weak var privacyTitle: UILabel! {
        didSet {
            privacyTitle.alpha = 0
        }
    }
    
    @IBOutlet weak var privacyIcon: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            privacyIcon.addGestureRecognizer(tap)
            privacyIcon.icon.alpha = 0
//            privacyIcon.backgroundColor = .clear
            privacyIcon.state       = .Off
            privacyIcon.category    = .Locked
            privacyIcon.color       = selectedColor
        }
    }
    
    @IBOutlet weak var privacyLabel: UILabel! {
        didSet {
            privacyLabel.alpha = 0
        }
    }
    
    
    //MARK: - Votes
    var votesCount = 100 {
        didSet {
            stage = .Title
        }
    }
    
    @IBOutlet weak var votesLabel: UILabel! {
        didSet {
            votesLabel.alpha = 0
        }
    }
    
    @IBOutlet weak var votesIcon: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            votesIcon.addGestureRecognizer(tap)
            votesIcon.icon.alpha = 0
//            votesIcon.backgroundColor = .clear
            votesIcon.state       = .Off
            votesIcon.category    = .Text
            votesIcon.color       = selectedColor
            votesIcon.text        = "100"
        }
    }
    
    @IBOutlet weak var votesTitle: UILabel! {
        didSet {
            votesTitle.alpha = 0
        }
    }
    

    //MARK: - Title
    var questionTitle = "" {
        didSet {
            stage = .Question
        }
    }
    
    @IBOutlet weak var titleIcon: CircleButton! {
        didSet {
            titleIcon.icon.alpha = 0
//            titleIcon.backgroundColor = .clear
            titleIcon.accessibilityIdentifier   = "titleIcon"
            titleIcon.state                     = .Off
            titleIcon.color                     = selectedColor
            titleIcon.category                  = .Title_RU
//            titleIcon.text                      = "ТИТУЛ"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            titleIcon.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.backgroundColor = .clear
            titleLabel.textColor = .white
            titleLabel.alpha = 0
            titleLabel.accessibilityIdentifier = "Title"
            titleLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            titleLabel.addGestureRecognizer(tap)
        }
    }
    
    
    //MARK: - Question
    var question = "" {
        didSet {
            stage = .Hyperlink
        }
    }
    
    @IBOutlet weak var questionIcon: CircleButton! {
        didSet {
            questionIcon.icon.alpha = 0
//            questionIcon.backgroundColor = .clear
            questionIcon.accessibilityIdentifier    = "questionIcon"
            questionIcon.state                      = .Off
            questionIcon.color                      = selectedColor
            questionIcon.category                   = .Details_RU
//            questionIcon.text                       = "ВОПРОС"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            questionIcon.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var questionLabel: UILabel! {
        didSet {
            questionLabel.alpha = 0
            questionLabel.textColor = .white
            questionLabel.accessibilityIdentifier = "Question"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            questionLabel.isUserInteractionEnabled = true
            questionLabel.addGestureRecognizer(tap)
        }
    }
    

    //MARK: - Hyperlink
    var hyperlink: URL? {
        didSet {
//            stage = .Images
        }
    }
    
    @IBOutlet weak var hyperlinkIcon: CircleButton! {
        didSet {
            hyperlinkIcon.icon.alpha = 0
//            hyperlinkIcon.backgroundColor = .clear
            hyperlinkIcon.state     = .Off
            hyperlinkIcon.color     = selectedColor
            hyperlinkIcon.category  = .Hyperlink_RU
//            hyperlinkIcon.text      = "ССЫЛКА"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            hyperlinkIcon.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var hyperlinkLabel: UILabel! {
        didSet {
            hyperlinkLabel.alpha = 0
            hyperlinkLabel.textColor = .white
            hyperlinkLabel.accessibilityIdentifier = "Hyperlink"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            hyperlinkLabel.isUserInteractionEnabled = true
            hyperlinkLabel.addGestureRecognizer(tap)
            hyperlinkLabel.text = "Вставьте ссылку"
        }
    }
    
  
    //MARK: - Images
    var images: [[UIImage: String]] = [] {
        didSet {
            stage = .Answers
        }
    }
    
    @IBOutlet weak var imagesHeaderIcon: CircleButton! {
        didSet {
            imagesHeaderIcon.icon.alpha = 0
//            imagesHeaderIcon.backgroundColor = .clear
            imagesHeaderIcon.state      = .Off
            imagesHeaderIcon.color      = selectedColor
            imagesHeaderIcon.category   = .ImagesHeaderWithCount
            imagesHeaderIcon.text       = "0/3"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            imagesHeaderIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var imagesLabel: UILabel!
    

    //MARK: - Interface properties
    @IBInspectable var lineWidth: CGFloat = 5 {
        didSet {
            NotificationCenter.default.post(name: Notifications.UI.LineWidth, object: lineWidth)
        }
    }

    @IBInspectable private var lastContentOffset: CGFloat = 0

    @IBInspectable private var lineAnimationDuration = 0.5

//    var isNavigationBarHidden = false
    
    //Color based on selected category
    var selectedColor = K_COLOR_RED {
        didSet {
            anonIcon.color                  = selectedColor
            privacyIcon.color               = selectedColor
            votesIcon.color                 = selectedColor
            titleIcon.color                 = selectedColor
            titleLabel.backgroundColor      = selectedColor.withAlphaComponent(0.2)
            titleLabel.textColor            = .darkGray//selectedColor
            questionIcon.color              = selectedColor
            questionLabel.backgroundColor   = selectedColor.withAlphaComponent(0.2)
            questionLabel.textColor         = .darkGray//selectedColor
            hyperlinkIcon.color             = selectedColor
            hyperlinkLabel.backgroundColor  = selectedColor.withAlphaComponent(0.2)
            hyperlinkLabel.textColor        = .darkGray//selectedColor
            imagesHeaderIcon.color          = selectedColor
//            //TODO: Continue coloring
//            anonIcon.setNeedsDisplay()
//            privacyIcon.setNeedsDisplay()
//            votesIcon.setNeedsDisplay()
//            titleIcon.setNeedsDisplay()
//            questionIcon.setNeedsDisplay()
//            hyperlinkIcon.setNeedsDisplay()
//            imagesHeaderIcon.setNeedsDisplay()
            lines.map({$0.layer.strokeColor = selectedColor.withAlphaComponent(0.2).cgColor})
        }
    }
    
    //Array of colored lines between stages
    private var lines: [Line] = []
    
    //Corner for labels
    private var cornerRadius: CGFloat! {
        didSet {
            titleLabel.layer.cornerRadius = cornerRadius
            questionLabel.layer.cornerRadius = cornerRadius
            hyperlinkLabel.layer.cornerRadius = cornerRadius
        }
    }
    //Get-only color
    var color: UIColor {
        get {
            return selectedColor
        }
    }

    
    //MARK: - VC Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = true
//            if isNavigationBarHidden {
//                nc.setNavigationBarHidden(true, animated: true)
//            }
        }
        
        if !isViewSetupCompleted {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            lineWidth = categoryIcon.bounds.height / 11.75//0.75
            
            isViewSetupCompleted = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if cornerRadius == nil {
            cornerRadius = view.frame.width / 20
        }
        scrollView.contentSize.height = 1500
        
        if category == nil {
            categoryIcon.present(completionBlocks: [{
                self.categoryIcon.state = .On
                }])
        }
        
////        delay(seconds: 3){
//            let icon = self.categoryIcon.icon.copyView() as! SurveyCategoryIcon
//            self.contentView.addSubview(icon)
////
////        }
////
//
//        let toValue = (icon.getLayer(SurveyCategoryIcon.Category.Computers)  ! CAShapeLayer).path
//        delay(seconds: 0.5){
//
//
//            let pathAnim        = CABasicAnimation(keyPath: "path")
//            pathAnim.fromValue  = (icon.icon as! CAShapeLayer).path
//            pathAnim.toValue    = toValue
//            pathAnim.duration = 0.3
//            pathAnim.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
//
//            icon.icon.add(pathAnim, forKey: nil)
//            (icon.icon as! CAShapeLayer).path = toValue
//        }
        
    }
    
    //MARK: - UI Functions
    private func moveToNextStage() {
        
        var initialIcon:            CircleButton!
        var destinationIcon:        CircleButton!
        //lineCompletionBlocks - used in animationDidStop()
        var lineCompletionBlocks:   [Closure] = []
        var animationBlocks:        [Closure] = []
        var completionBlocks:       [Closure] = []
        
        func animateTransition(initialIcon: CircleButton, destinationIcon: CircleButton, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], animationDuration: TimeInterval?) {
            
            let line     = drawLine(fromView: initialIcon, toView: destinationIcon, lineCap: .round)
            let lineAnim = getLineAnimation(line: line)
            let duration = animationDuration ?? lineAnimationDuration
            
            contentView.layer.insertSublayer(line.layer, at: 0)
            lineAnim.delegate = self
            lineAnim.setValue(lineCompletionBlocks, forKey: "completionBlocks")
            line.layer.add(lineAnim, forKey: "animEnd")
            destinationIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIView.animate(withDuration: duration, delay: lineAnimationDuration * 0.55, options: [.curveEaseInOut], animations:
                {
                    animations.map { $0() }
                    destinationIcon.alpha = 1
                    destinationIcon.transform = .identity
            }) {
                _ in
                completion.map({ $0() })
            }
            
            line.layer.strokeEnd = 1
            
        }
        
        func animateTransition(lineStart: CGPoint, lineEnd: CGPoint, initialIcon: CircleButton, destinationIcon: CircleButton, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], animationDuration: TimeInterval?) {
            
            let line     = drawLine(fromPoint: lineStart, endPoint: lineEnd, lineCap: .square)
            let lineAnim = getLineAnimation(line: line)
            let duration = animationDuration ?? lineAnimationDuration
            
            contentView.layer.insertSublayer(line.layer, at: 0)
            lineAnim.delegate = self
            lineAnim.setValue(lineCompletionBlocks, forKey: "completionBlocks")
            line.layer.add(lineAnim, forKey: "animEnd")
//            destinationIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIView.animate(withDuration: duration, delay: lineAnimationDuration * 0.55, options: [.curveEaseInOut], animations:
                {
                    animations.map { $0() }
//                    destinationIcon.alpha = 1
//                    destinationIcon.transform = .identity
            }) {
                _ in
                completion.map({ $0() })
            }
            
            line.layer.strokeEnd = 1
            
        }
        
        func drawLine(fromView: UIView, toView: UIView, lineCap: CAShapeLayerLineCap) -> Line {
            let line = Line()
            line.path = UIBezierPath()
            
            let startPoint = contentView.convert(fromView.center, to: view)//fromView.convert(fromView.center, to: contentView)
            line.path.move(to: startPoint)
            
            let endPoint = contentView.convert(toView.center, to: view)//toView.convert(toView.center, to: contentView)
            line.path.addLine(to: endPoint)
            
            
            let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
            let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
            
            line.layer.strokeStart = 0
            line.layer.strokeEnd = 0
            line.layer.lineWidth = lineWidth
            line.layer.strokeColor = selectedColor.withAlphaComponent(0.2).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = lineCap
            
            line.layer.path = path.cgPath
            lines.append(line)
            return line
        }
        
        func drawLine(fromPoint: CGPoint, endPoint: CGPoint, lineCap: CAShapeLayerLineCap) -> Line {
            let line = Line()
            line.path = UIBezierPath()
            
            line.path.move(to: fromPoint)
            line.path.addLine(to: endPoint)
            
            let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
            let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
            
            line.layer.strokeStart = 0
            line.layer.strokeEnd = 0
            line.layer.lineWidth = lineWidth
            line.layer.strokeColor = selectedColor.withAlphaComponent(0.2).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = lineCap
            
            line.layer.path = path.cgPath
            lines.append(line)
            return line
        }
        
        func getLineAnimation(line: Line) -> CAAnimationGroup {
            let strokeEndAnimation      = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration)
//            let strokeWidthAnimation    = CAKeyframeAnimation(keyPath:"lineWidth")
//            strokeWidthAnimation.values   = [lineWidth * 2, lineWidth]
//            strokeWidthAnimation.keyTimes = [0, 1]
//            strokeWidthAnimation.duration = lineAnimationDuration
//            let pathFillColorAnim      = CAKeyframeAnimation(keyPath:"strokeColor")
//            pathFillColorAnim.values   = [selectedColor.withAlphaComponent(0.8).cgColor, selectedColor.withAlphaComponent(0.2).cgColor]
//            pathFillColorAnim.keyTimes = [0, 1]
//            pathFillColorAnim.duration = lineAnimationDuration
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [strokeEndAnimation]//, strokeWidthAnimation, pathFillColorAnim]
            groupAnimation.duration = lineAnimationDuration
            
            return groupAnimation
        }
        
        func reveal(view animatedView: UIView, duration: TimeInterval, completionBlocks: [Closure]) {
            
            let circlePathLayer = CAShapeLayer()
            
            func circleFrameTopCenter() -> CGRect {
                var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
                let circlePathBounds = circlePathLayer.bounds
                circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
                circleFrame.origin.y = circlePathBounds.minY - circleFrame.minY
                return circleFrame
            }
            
            func circleFrameTop() -> CGRect {
                var circleFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
                let circlePathBounds = circlePathLayer.bounds
                circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
                circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
                return circleFrame
            }
            
            func circlePath() -> UIBezierPath {
                return UIBezierPath(ovalIn: circleFrameTopCenter())
            }
            
            circlePathLayer.frame = animatedView.bounds
            circlePathLayer.path = circlePath().cgPath
            animatedView.layer.mask = circlePathLayer
            animatedView.alpha = 1
            
            let center = CGPoint(x: animatedView.bounds.midX, y: animatedView.bounds.midY)
            
            let finalRadius = sqrt((center.x*center.x) + (center.y*center.y))
            
            let radiusInset = finalRadius
            
            let outerRect = circleFrameTop().insetBy(dx: -radiusInset, dy: -radiusInset)
            
            let toPath = UIBezierPath(ovalIn: outerRect).cgPath
            
            let fromPath = circlePathLayer.path
            
            let maskLayerAnimation = CABasicAnimation(keyPath: "path")
            
            maskLayerAnimation.fromValue = fromPath
            maskLayerAnimation.toValue = toPath
            maskLayerAnimation.duration = duration
            maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            maskLayerAnimation.isRemovedOnCompletion = false
            if !completionBlocks.isEmpty {
                maskLayerAnimation.delegate = self
                maskLayerAnimation.setValue(completionBlocks, forKey: "maskCompletionBlocks")
            }
            
            circlePathLayer.add(maskLayerAnimation, forKey: "path")
            circlePathLayer.path = toPath
            
        }
        
        guard stage.rawValue >= maximumStage.rawValue else { return }
        
        switch stage {
        case .Category:
            
            print("Do nothing")
            
        case .Anonymity:
            
            initialIcon     = categoryIcon
            destinationIcon = anonIcon
            animationBlocks.append {
                self.anonLabel.alpha = 1
            }
            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 4)
            startPoint.x -= delta
            startPoint.y += delta//initialIcon.frame.size.height / 2
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            endPoint.x += delta
            endPoint.y -= delta
            delay(seconds: lineAnimationDuration * 0.5) {
                self.anonIcon.present(completionBlocks: [{
                    self.anonIcon.state = .On
//                    self.performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
                    }])
            }
            completionBlocks.append {
                delay(seconds: 0.2) { self.performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil) }
            }
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
//            animateTransition(initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
        
        case .Privacy:
            
            initialIcon     = anonIcon
            destinationIcon = privacyIcon
            animationBlocks.append {
                self.privacyLabel.alpha = 1
            }

            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 2)
            startPoint.x += delta
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            delay(seconds: lineAnimationDuration * 0.5) {
                self.privacyIcon.present(completionBlocks: [{
                    self.privacyIcon.state = .On
//                    self.performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
                    }])
            }
            completionBlocks.append {
                delay(seconds: 0.2) { self.performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil) }
            }
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: lineAnimationDuration * 1.3)
            
        case .Votes:
            
            initialIcon     = privacyIcon
            destinationIcon = votesIcon
            animationBlocks.append {
                self.votesTitle.alpha = 1
                self.votesLabel.alpha = 1
            }
            
            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 4)
            startPoint.x -= delta
            startPoint.y += delta//initialIcon.frame.size.height / 2
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            endPoint.x += delta
            endPoint.y -= delta
            delay(seconds: lineAnimationDuration * 0.5) {
                self.votesIcon.present(completionBlocks: [{
                    self.votesIcon.state = .On
//                    self.performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
                    }])
            }
            completionBlocks.append {
                delay(seconds: 0.2) { self.performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil) }
            }
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Title:
            
            initialIcon     = votesIcon
            destinationIcon = titleIcon

            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25// - navigationBarHeight / 2.5
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [{ reveal(view: self.titleLabel, duration: 0.3, completionBlocks: []) }])
            }
            delay(seconds: lineAnimationDuration * 0.4) {
                self.titleIcon.present(completionBlocks: [{ self.titleIcon.state = .On }])
            }
            
            completionBlocks.append {
                delay(seconds: 1) { self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.titleIcon) }
            }

            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 2)
            startPoint.y += delta
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            endPoint.y -= delta
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Question:
            
            initialIcon     = titleIcon
            destinationIcon = questionIcon
            
            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25// - navigationBarHeight / 2.5
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [{ reveal(view: self.questionLabel, duration: 0.3, completionBlocks: []) }])
            }
            delay(seconds: lineAnimationDuration * 0.4) {
                self.questionIcon.present(completionBlocks: [{ self.questionIcon.state = .On }])
            }
            
            completionBlocks.append {
                delay(seconds: 1.25) { self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.questionIcon) }
            }
            
            let startPoint = CGPoint(x: contentView.frame.width/2, y: contentView.convert(titleLabel.frame.origin, to: scrollView).y + titleLabel.frame.height + lineWidth/2)
            let delta = (initialIcon.frame.size.height / 2)
            var endPoint = contentView.convert(destinationIcon.center, to: scrollView)
            endPoint.y -= delta
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Hyperlink:
            
            initialIcon     = questionIcon
            destinationIcon = hyperlinkIcon
            
            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25// - navigationBarHeight / 2.5
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [{ reveal(view: self.hyperlinkLabel, duration: 0.3, completionBlocks: []) }])
            }
            delay(seconds: lineAnimationDuration * 0.4) {
                self.hyperlinkIcon.present(completionBlocks: [{ self.questionIcon.state = .On }])
            }
            
            completionBlocks.append {
                delay(seconds: 1.25) { self.performSegue(withIdentifier: Segues.App.NewSurveyToHyperlinkViewController, sender: nil) }
            }
            
            let startPoint = CGPoint(x: contentView.frame.width/2, y: contentView.convert(questionLabel.frame.origin, to: scrollView).y + questionLabel.frame.height + lineWidth/2)
            let delta = (initialIcon.frame.size.height / 2)
            var endPoint = contentView.convert(destinationIcon.center, to: scrollView)
            endPoint.y -= delta
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Images:
            print("Do nothing")
        case .Answers:
            print("Do nothing")
        case .Post:
            print("Do nothing")
        }
    }
    
    @objc fileprivate func iconTapped(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let v = gesture.view {
            if let icon = v as? CircleButton {
                if icon === categoryIcon {
//                    currentStage = .Category
                    performSegue(withIdentifier: Segues.App.NewSurveyToCategorySelection, sender: nil)
                } else if icon === anonIcon {
//                    currentStage = .Anonymity
                    performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
                } else if icon === privacyIcon {
//                    currentStage = .Privacy
                    performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
                } else if icon === votesIcon {
//                    currentStage = .Votes
                    performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
                } else if icon === titleIcon {
//                    currentStage = .Title
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
                } else if icon === questionIcon {
//                    currentStage = .Question
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
                } else if icon === hyperlinkIcon {
//                    currentStage = .Hyperlink
                    performSegue(withIdentifier: Segues.App.NewSurveyToHyperlinkViewController, sender: nil)
                }
            } else if let label = v as? UILabel {
                if label === titleLabel {
//                    currentStage = .Title
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: titleIcon)
                } else if label === questionLabel {
//                    currentStage = .Question
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: questionIcon)
                } else if label === hyperlinkLabel {
//                    currentStage = .Hyperlink
                    performSegue(withIdentifier: Segues.App.NewSurveyToHyperlinkViewController, sender: nil)
                }
            }
        }
    }
    
    private func setTitle() {
        let navTitle = UILabel()
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        let attrString = NSMutableAttributedString()
        attrString.append(NSAttributedString(string: title!, attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Bold, size: 19), foregroundColor: .black, backgroundColor: .clear)))
        if category != nil {
            //TODO - Fatal error when parent is nil
            attrString.append(NSAttributedString(string: "\n\(category!.parent!.title)", attributes: StringAttributes.getAttributes(font: StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 13), foregroundColor: .darkGray, backgroundColor: .clear)))
        }
        navTitle.attributedText = attrString
        navigationItem.titleView = navTitle
    }
    
    func scrollToPoint(y: CGFloat, duration: TimeInterval = 0.5, delay: TimeInterval = 0, completionBlocks: [Closure]) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut], animations: {
            self.scrollView.contentOffset.y = y
        }) {
            _ in
            completionBlocks.map({ $0() })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.duration = 0.55
            nc.transitionStyle = .Icon
            if segue.identifier == Segues.App.NewSurveyToCategorySelection, let destinationVC = segue.destination as? CategorySelectionViewController {
                nc.duration = 0.6
//                destinationVC.category = category
//                destinationVC.lineWidth = lineWidth
                destinationVC.actionButtonHeight = categoryIcon.frame.height
            } else if segue.identifier == Segues.App.NewSurveyToTypingViewController, let destinationVC = segue.destination as? TextInputViewController {
                if let icon = sender as? CircleButton {
                    if icon === titleIcon {
                        destinationVC.titleString = "Титул"
                        destinationVC.charactersLimit = DjangoVariables.FieldRestrictions.surveyTitleLength
                        destinationVC.textContent = questionTitle.isEmpty ? "" : questionTitle
                        //                    destinationVC.placeholder = "Введите титул.."
                        destinationVC.delegate = self
                        destinationVC.font = titleLabel.font
                        destinationVC.textColor = .darkGray//selectedColor//titleLabel.textColor
                        destinationVC.textCentered = true
                        destinationVC.accessibilityIdentifier = "Title"
                    } else if icon === questionIcon {
                        destinationVC.titleString = "Вопрос"
                        destinationVC.charactersLimit = DjangoVariables.FieldRestrictions.surveyQuestionLength
                        destinationVC.textContent = question.isEmpty ? "" : question
                        destinationVC.delegate = self
                        destinationVC.font = StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 13)
                        destinationVC.textColor = .darkGray//selectedColor//questionLabel.textColor
                        destinationVC.accessibilityIdentifier = "Question"
                    }
                }
                destinationVC.cornerRadius = titleLabel.cornerRadius
                destinationVC.color = selectedColor
//                nc.transitionStyle = .Blur
            } else if segue.identifier == Segues.App.NewSurveyToAnonimitySelection, let destinationVC = segue.destination as? BinarySelectionViewController {
                destinationVC.color = selectedColor
                destinationVC.selectionType = .Anonimity
//                destinationVC.lineWidth = lineWidth
            } else if segue.identifier == Segues.App.NewSurveyToPrivacySelection, let destinationVC = segue.destination as? BinarySelectionViewController {
                destinationVC.color = selectedColor
                destinationVC.selectionType = .Privacy
//                destinationVC.lineWidth = lineWidth
            } else if segue.identifier == Segues.App.NewSurveyToVotesCountViewController, let destinationVC = segue.destination as? VotesCountViewController {
                destinationVC.votesCount = votesCount
//                destinationVC.actionButton.lineWidth = lineWidth
                destinationVC.actionButtonWidthConstant = votesIcon.frame.width
                destinationVC.color = selectedColor
            } else if segue.identifier == Segues.App.NewSurveyToHyperlinkViewController, let destinationVC = segue.destination as? HyperlinkSelectionViewController {
                destinationVC.color = selectedColor
//                destinationVC.lineWidth = lineWidth
                nc.transitionStyle = .Icon
                if hyperlink != nil {
                    destinationVC.hyperlink = hyperlink
                }
                destinationVC.color = selectedColor
                destinationVC._labelHeight = hyperlinkLabel.frame.height
            } else if segue.identifier == Segues.App.NewSurveyToImagesViewController, let destinationVC = segue.destination as? ImagesSelectionViewController {
                destinationVC.images = images
            }
        }
    }
}

extension CreateNewSurveyViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.map{ $0() }
        } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
            completionBlocks.map{ $0() }
        }
    }
}

extension CreateNewSurveyViewController: CallbackDelegate {
    func callbackReceived(_ sender: AnyObject) {
        if let _category = sender as? SurveyCategory {
            category = _category
        } else if let textView = sender as? UITextView, let accessibilityIdentifier = textView.accessibilityIdentifier {
            if accessibilityIdentifier == "Title" {
                questionTitle = textView.text
            } else if accessibilityIdentifier == "Question"{
                question = textView.text
            }
        }
    }
}
