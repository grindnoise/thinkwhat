//
//  CreateNewSurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CreateNewSurveyViewController: UIViewController {

//    @IBOutlet weak var test: CircleButton! {
//        didSet {
//            test.state = .Off
//            test.color = K_COLOR_GRAY
//            test.category = .Anon
//        }
//    }
    
    deinit {
        print("***CreateNewSurveyViewController deinit***")
    }
    
    //Sequence of stages to post new survey
    private enum Stage: Int {
        case Category, Anonymity, Privacy, Votes, Title, Question, Hyperlink, Images, Answers, Post
    }
    
    private var currentStage: Stage = .Category {
        didSet {
            maximumStage = currentStage
            moveToNextStage()
        }
    }
    
    private var maximumStage: Stage = .Category {
        didSet {
            maximumStage = currentStage.rawValue <= oldValue.rawValue ? oldValue : maximumStage//Stage(rawValue: maximumStage.rawValue + 1) ?? .Post
        }
    }
        
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    
    //MARK: - Category
    var category: SurveyCategory? {
        didSet {
            setTitle()
            if category != nil {
                categoryTitle.alpha = 1
                currentStage = .Anonymity
                categoryIcon.color = category!.tagColor ?? K_COLOR_RED
                categoryIcon.category = SurveyCategoryIcon.CategoryID(rawValue: category!.ID) ?? .Null
//                categoryIcon.isGradient = false
//                categoryIcon.tagColor = category!.tagColor ?? K_COLOR_RED
//                categoryIcon.categoryID = SurveyCategoryIcon.CategoryID(rawValue: category!.ID) ?? .Null
//                selectedColor = categoryIcon.tagColor!//.withAlphaComponent(0.5)
                categoryTitle.text = category!.title.uppercased()
//                if oldValue == nil {
//                    self.animateNextStage(startView: self.categoryIcon, endView: self.anonIcon, completionHandler: {
//                        self.performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
//                    })
//                }
            }
        }
    }
    
    @IBOutlet weak var categoryTitle: UILabel! {
        didSet {
            categoryTitle.alpha = 0
            if category == nil {
                categoryTitle.text = "КАТЕГОРИЯ"
            }
        }
    }
    
    @IBOutlet weak var categoryIcon: CircleButton! {
        didSet {
            categoryIcon.backgroundColor = .clear
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            categoryIcon.addGestureRecognizer(tap)
            if category == nil {
                categoryIcon.state = .Off
                categoryIcon.color = K_COLOR_RED
                categoryIcon.text = "РАЗДЕЛ"
                categoryIcon.category = .Text
//                categoryIcon.isGradient = false
//                categoryIcon.tagColor = K_COLOR_RED
//                categoryIcon.text = "?"
//                categoryIcon.categoryID = .Text
                if category != nil {
                    categoryTitle.text = "КАТЕГОРИЯ"
                }
            }
        }
    }
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    //MARK: - Anon
    var isAnonymous = false {
        didSet {
            anonTitle.alpha = 1
            currentStage = .Privacy
        }
    }
    
    @IBOutlet weak var anonTitle: UILabel! {
        didSet {
            anonTitle.alpha = 0
        }
    }
    
    @IBOutlet weak var anonIcon: SurveyCategoryIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            anonIcon.addGestureRecognizer(tap)
            anonIcon.alpha = 0
            anonIcon.backgroundColor = .clear
            anonIcon.categoryID = .Anon
            anonIcon.tagColor   = K_COLOR_RED
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
            currentStage = .Votes
        }
    }
    
    @IBOutlet weak var privacyTitle: UILabel! {
        didSet {
            privacyTitle.alpha = 0
        }
    }
    
    @IBOutlet weak var privacyIcon: SurveyCategoryIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            privacyIcon.addGestureRecognizer(tap)
            privacyIcon.alpha = 0
            privacyIcon.backgroundColor = .clear
            privacyIcon.categoryID = .Privacy
            privacyIcon.tagColor   = K_COLOR_RED
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
            currentStage = .Title
        }
    }
    
    @IBOutlet weak var votesLabel: UILabel! {
        didSet {
            votesLabel.alpha = 0
        }
    }
    
    @IBOutlet weak var votesIcon: SurveyCategoryIcon! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            votesIcon.addGestureRecognizer(tap)
            votesIcon.alpha = 0
            votesIcon.backgroundColor = .clear
            votesIcon.categoryID = .Text
            votesIcon.tagColor   = selectedColor
            votesIcon.text = "100"
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
            currentStage = .Question
        }
    }
    
    @IBOutlet weak var titleIcon: SurveyCategoryIcon! {
        didSet {
            titleIcon.alpha = 0
            titleIcon.backgroundColor = .clear
            titleIcon.accessibilityIdentifier = "titleIcon"
            titleIcon.tagColor = K_COLOR_RED
            titleIcon.categoryID = .Text
            titleIcon.text = "ТИТУЛ"
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
            currentStage = .Hyperlink
        }
    }
    
    @IBOutlet weak var questionIcon: SurveyCategoryIcon! {
        didSet {
            questionIcon.alpha = 0
            questionIcon.backgroundColor = .clear
            questionIcon.accessibilityIdentifier = "questionIcon"
            questionIcon.tagColor = K_COLOR_RED
            questionIcon.categoryID = .Text
            questionIcon.text = "ВОПРОС"
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
            currentStage = .Images
        }
    }
    
    @IBOutlet weak var hyperlinkIcon: SurveyCategoryIcon! {
        didSet {
            hyperlinkIcon.alpha = 0
            hyperlinkIcon.backgroundColor = .clear
            hyperlinkIcon.tagColor = K_COLOR_RED
            hyperlinkIcon.categoryID = .Text
            hyperlinkIcon.text = "ССЫЛКА"
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
        }
    }
    
  
    //MARK: - Images
    var images: [[UIImage: String]] = [] {
        didSet {
            currentStage = .Answers
        }
    }
    
    @IBOutlet weak var imagesHeaderIcon: SurveyCategoryIcon! {
        didSet {
            imagesHeaderIcon.alpha = 0
            imagesHeaderIcon.backgroundColor = .clear
            imagesHeaderIcon.tagColor = K_COLOR_RED
            imagesHeaderIcon.categoryID = .ImagesHeaderWithCount
            imagesHeaderIcon.text = "0/3"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            imagesHeaderIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var imagesLabel: UILabel!
    

    //MARK: - Interface properties
    @IBInspectable var lineWidth: CGFloat = 5

    @IBInspectable private var lastContentOffset: CGFloat = 0

    @IBInspectable private var lineAnimationDuration = 0.3

//    var isNavigationBarHidden = false
    
    //Color based on selected category
    var selectedColor = K_COLOR_RED {
        didSet {
            anonIcon.tagColor               = selectedColor
            privacyIcon.tagColor            = selectedColor
            votesIcon.tagColor              = selectedColor
            titleIcon.tagColor              = selectedColor
            titleLabel.backgroundColor      = selectedColor.withAlphaComponent(0.25)
            titleLabel.textColor            = selectedColor
            questionIcon.tagColor           = selectedColor
            questionLabel.backgroundColor   = selectedColor.withAlphaComponent(0.25)
            questionLabel.textColor         = selectedColor
            hyperlinkIcon.tagColor          = selectedColor
            hyperlinkLabel.backgroundColor  = selectedColor.withAlphaComponent(0.25)
            hyperlinkLabel.textColor        = selectedColor
            imagesHeaderIcon.tagColor       = selectedColor
            //TODO: Continue coloring
            anonIcon.setNeedsDisplay()
            privacyIcon.setNeedsDisplay()
            votesIcon.setNeedsDisplay()
            titleIcon.setNeedsDisplay()
            questionIcon.setNeedsDisplay()
            hyperlinkIcon.setNeedsDisplay()
            imagesHeaderIcon.setNeedsDisplay()
            lines.map({$0.layer.strokeColor = selectedColor.withAlphaComponent(0.25).cgColor})
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
    }

    
    //MARK: - UI Functions
    private func moveToNextStage() {
        
        var initialIcon:            SurveyCategoryIcon!
        var destinationIcon:        SurveyCategoryIcon!
        //lineCompletionBlocks - used in animationDidStop()
        var lineCompletionBlocks:   [Closure] = []
        var animationBlocks:        [Closure] = []
        var completionBlocks:       [Closure] = []
        
        func animateTransition(initialIcon: SurveyCategoryIcon, destinationIcon: SurveyCategoryIcon, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], animationDuration: TimeInterval?) {
            
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
        
        func animateTransition(lineStart: CGPoint, lineEnd: CGPoint, initialIcon: SurveyCategoryIcon, destinationIcon: SurveyCategoryIcon, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], animationDuration: TimeInterval?) {
            
            let line     = drawLine(fromPoint: lineStart, endPoint: lineEnd, lineCap: .square)
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
            line.layer.strokeColor = selectedColor.withAlphaComponent(0.25).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
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
            line.layer.strokeColor = selectedColor.withAlphaComponent(0.25).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
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
//            pathFillColorAnim.values   = [selectedColor.withAlphaComponent(0.8).cgColor, selectedColor.withAlphaComponent(0.25).cgColor]
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
        
        guard currentStage.rawValue >= maximumStage.rawValue else { return }
        
        switch currentStage {
        case .Category:
            
            print("Do nothing")
            
        case .Anonymity:
            
            initialIcon     = categoryIcon
            destinationIcon = anonIcon
            animationBlocks.append {
                self.anonLabel.alpha = 1
            }
            completionBlocks.append {
                self.performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
            }
            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 4)
            startPoint.x -= delta
            startPoint.y += delta//initialIcon.frame.size.height / 2
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            endPoint.x += delta
            endPoint.y -= delta
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
//            animateTransition(initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
        
        case .Privacy:
            
            initialIcon     = anonIcon
            destinationIcon = privacyIcon
            animationBlocks.append {
                self.privacyLabel.alpha = 1
            }
            completionBlocks.append {
                self.performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
            }
            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 2)
            startPoint.x += delta
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            endPoint.x -= delta
            
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Votes:
            
            initialIcon     = privacyIcon
            destinationIcon = votesIcon
            animationBlocks.append {
                self.votesTitle.alpha = 1
                self.votesLabel.alpha = 1
            }
            completionBlocks.append {
                self.performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
            }
            
            
            var startPoint = contentView.convert(initialIcon.center, to: view)
            let delta = (initialIcon.frame.size.height / 4)
            startPoint.x -= delta
            startPoint.y += delta//initialIcon.frame.size.height / 2
            var endPoint = contentView.convert(destinationIcon.center, to: view)
            endPoint.x += delta
            endPoint.y -= delta
            
            animateTransition(lineStart: startPoint, lineEnd: endPoint, initialIcon: initialIcon, destinationIcon: destinationIcon, lineCompletionBlocks: lineCompletionBlocks, animationBlocks: animationBlocks, completionBlocks: completionBlocks, animationDuration: nil)
            
        case .Title:
            
            initialIcon     = votesIcon
            destinationIcon = titleIcon

            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25// - navigationBarHeight / 2.5
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [])
            }
            
            completionBlocks.append {
                reveal(view: self.titleLabel, duration: 0.3, completionBlocks: [
                    {
                        self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.titleIcon)
                    }])
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
//            if self.scrollView.contentOffset.y == 0 {
                //                            self.scrollView.contentOffset.y = startView.convert(startView.frame.origin, to: self.contentView).y - startView.bounds.height / 4.25// - navigationBarHeight / 2.5
                //                        } else {
                //                            self.scrollView.contentOffset.y = self.contentView.convert(startView.frame.origin, to: self.scrollView).y - startView.bounds.height / 4.25// - navigationBarHeight / 2.5
                //                        }
            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [])
            }
            
            completionBlocks.append {
                reveal(view: self.questionLabel, duration: 0.3, completionBlocks: [
                    {
                        self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.questionIcon)
                    }])
            }
            
            animateTransition(lineStart: CGPoint(x: contentView.convert(titleLabel.center, to: view).x,
                                                 y: contentView.convert(titleLabel.frame.origin, to: scrollView).y + titleLabel.frame.height + lineWidth/2),
                              lineEnd: contentView.convert(questionIcon.center, to: scrollView),
                              initialIcon: initialIcon,
                              destinationIcon: destinationIcon,
                              lineCompletionBlocks: lineCompletionBlocks,
                              animationBlocks: animationBlocks,
                              completionBlocks: completionBlocks,
                              animationDuration: 0.6)
            
        case .Hyperlink:
            initialIcon     = questionIcon
            destinationIcon = hyperlinkIcon
            let scrollPoint = contentView.convert(destinationIcon.frame.origin, to: scrollView).y - initialIcon.bounds.height / 4.25
            
            lineCompletionBlocks.append {
                self.scrollToPoint(y: scrollPoint, duration: 0.3, delay: 0, completionBlocks: [])
            }
            
            completionBlocks.append {
                reveal(view: self.questionLabel, duration: 0.3, completionBlocks: [
                    {
                        self.performSegue(withIdentifier: Segues.App.NewSurveyToHyperlinkViewController, sender: self.questionIcon)
                    }])
            }
            
            animateTransition(lineStart: CGPoint(x: contentView.convert(questionLabel.center, to: view).x,
                                                 y: contentView.convert(questionLabel.frame.origin, to: scrollView).y + questionLabel.frame.height + lineWidth/2),
                              lineEnd: contentView.convert(hyperlinkIcon.center, to: scrollView),
                              initialIcon: initialIcon,
                              destinationIcon: destinationIcon,
                              lineCompletionBlocks: lineCompletionBlocks,
                              animationBlocks: animationBlocks,
                              completionBlocks: completionBlocks,
                              animationDuration: 0.6)
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
            if let icon = v as? SurveyCategoryIcon {
                if icon === categoryIcon {
                    currentStage = .Category
                    performSegue(withIdentifier: Segues.App.NewSurveyToCategorySelection, sender: nil)
                } else if icon === anonIcon {
                    currentStage = .Anonymity
                    performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
                } else if icon === privacyIcon {
                    currentStage = .Privacy
                    performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
                } else if icon === votesIcon {
                    currentStage = .Votes
                    performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
                } else if icon === titleIcon {
                    currentStage = .Title
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
                } else if icon === questionIcon {
                    currentStage = .Question
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
                } else if icon === hyperlinkIcon {
                    currentStage = .Hyperlink
                    performSegue(withIdentifier: Segues.App.NewSurveyToHyperlinkViewController, sender: nil)
                }
            } else if let label = v as? UILabel {
                if label === titleLabel {
                    currentStage = .Title
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: titleIcon)
                } else if label === questionLabel {
                    currentStage = .Question
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: questionIcon)
                } else if label === hyperlinkLabel {
                    currentStage = .Hyperlink
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
            nc.duration = 0.28
            nc.transitionStyle = .Icon
            if segue.identifier == Segues.App.NewSurveyToCategorySelection, let destinationVC = segue.destination as? CategorySelectionViewController {
                destinationVC.category = category
                //                destinationVC.delegate = self
            } else if segue.identifier == Segues.App.NewSurveyToTypingViewController, let destinationVC = segue.destination as? TextInputViewController {
                if let icon = sender as? SurveyCategoryIcon {
                    if icon === titleIcon {
                        destinationVC.titleString = "Титул"
                        destinationVC.charactersLimit = DjangoVariables.FieldRestrictions.surveyTitleLength
                        destinationVC.textContent = questionTitle.isEmpty ? "" : questionTitle
                        //                    destinationVC.placeholder = "Введите титул.."
                        destinationVC.delegate = self
                        destinationVC.font = titleLabel.font
                        destinationVC.textColor = selectedColor//titleLabel.textColor
                        destinationVC.textCentered = true
                        destinationVC.accessibilityIdentifier = "Title"
                    } else if icon === questionIcon {
                        destinationVC.titleString = "Вопрос"
                        destinationVC.charactersLimit = DjangoVariables.FieldRestrictions.surveyQuestionLength
                        destinationVC.textContent = question.isEmpty ? "" : question
                        destinationVC.delegate = self
                        destinationVC.font = StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 13)
                        destinationVC.textColor = selectedColor//questionLabel.textColor
                        destinationVC.accessibilityIdentifier = "Question"
                    }
                }
                destinationVC.cornerRadius = titleLabel.cornerRadius
                destinationVC.color = selectedColor
                nc.duration = 0.4
//                nc.transitionStyle = .Blur
            } else if segue.identifier == Segues.App.NewSurveyToAnonimitySelection, let destinationVC = segue.destination as? AnonimitySelectionViewController {
                destinationVC.color = selectedColor
            } else if segue.identifier == Segues.App.NewSurveyToPrivacySelection, let destinationVC = segue.destination as? PrivacySelectionViewController {
                destinationVC.color = selectedColor
            } else if segue.identifier == Segues.App.NewSurveyToVotesCountViewController, let destinationVC = segue.destination as? VotesCountViewController {
                destinationVC.votesCount = votesCount
                destinationVC.color = selectedColor
            } else if segue.identifier == Segues.App.NewSurveyToHyperlinkViewController, let destinationVC = segue.destination as? HyperlinkSelectionViewController {
                destinationVC.color = selectedColor
                nc.transitionStyle = .Icon
                nc.duration = 0.4
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

//func animateNextStage(startView: UIView, endView: UIView, completionHandler: Closure?) {
//
////    func drawLine(fromView: UIView, toView: UIView, lineCap: CAShapeLayerLineCap) -> Line {
////        let line = Line()
////        line.path = UIBezierPath()
////
////        let startPoint = fromView.convert(fromView.center, to: contentView)// CGPoint(x: 0, y: yOffset)
////        line.path.move(to: startPoint)
////
////        let endPoint = toView.convert(toView.center, to: contentView)//CGPoint(x: frame.width, y: yOffset)
////        line.path.addLine(to: endPoint)
////
////
////        let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
////        let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
////
////        line.layer.strokeStart = 0
////        line.layer.strokeEnd = 0
////        line.layer.lineWidth = lineWidth
////        line.layer.strokeColor = selectedColor.withAlphaComponent(0.25).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
////        line.layer.lineCap = lineCap
////
////        line.layer.path = path.cgPath
////        lines.append(line)
////        return line
////    }
////
////    func drawLine(fromPoint: CGPoint, endPoint: CGPoint, lineCap: CAShapeLayerLineCap) -> Line {
////        let line = Line()
////        line.path = UIBezierPath()
////
////        line.path.move(to: fromPoint)
////        line.path.addLine(to: endPoint)
////
////        let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
////        let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
////
////        line.layer.strokeStart = 0
////        line.layer.strokeEnd = 0
////        line.layer.lineWidth = lineWidth
////        line.layer.strokeColor = selectedColor.withAlphaComponent(0.25).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
////        line.layer.lineCap = lineCap
////
////        line.layer.path = path.cgPath
////        lines.append(line)
////        return line
////    }
////
////    func createLineAnimation(line: Line) -> CAAnimationGroup {
////        let strokeEndAnimation      = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration)
////        let strokeWidthAnimation    = CAKeyframeAnimation(keyPath:"lineWidth")
////        strokeWidthAnimation.values   = [lineWidth * 2, lineWidth]
////        strokeWidthAnimation.keyTimes = [0, 1]
////        strokeWidthAnimation.duration = lineAnimationDuration
////        let pathFillColorAnim      = CAKeyframeAnimation(keyPath:"strokeColor")
////        pathFillColorAnim.values   = [selectedColor.withAlphaComponent(0.8).cgColor, selectedColor.withAlphaComponent(0.25).cgColor]
////        pathFillColorAnim.keyTimes = [0, 1]
////        pathFillColorAnim.duration = lineAnimationDuration
////
////        let groupAnimation = CAAnimationGroup()
////        groupAnimation.animations = [strokeEndAnimation, strokeWidthAnimation, pathFillColorAnim]
////        groupAnimation.duration = lineAnimationDuration
////
////        return groupAnimation
////    }
////
////    func scrollToPointBlock(point: CGPoint, duration: TimeInterval = 0.5, delay: TimeInterval = 0, completionBlocks: [Closure]) -> Closure {
////        return {
////            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut], animations: {
////                self.scrollView.contentOffset.y = point.y
////            }) {
////                _ in
////                completionBlocks.map({ $0() })
////            }
////        }
////    }
//
//
//    func animateLabel(label: UILabel, labelParent: UIView) {
//        labelParent.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        labelParent.alpha = 0
//        labelParent.layer.cornerRadius = 1
//        label.layer.cornerRadius = 1
//        UIView.animate(withDuration: lineAnimationDuration * 2, delay: 0, options: [.curveEaseOut], animations: {
//            labelParent.alpha = 1
//            label.alpha = 1
//            labelParent.transform = .identity
//            labelParent.layer.cornerRadius = self.cornerRadius
//            label.layer.cornerRadius = self.cornerRadius
//        })
//    }
//
//    if endView.alpha == 0, let startIcon = startView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let endIcon = endView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let line = drawLine(fromView: startIcon, toView: endIcon, lineCap: .round) as? Line, let groupAnimation = createLineAnimation(line: line) as? CAAnimationGroup {
//        contentView.layer.insertSublayer(line.layer, at: 0)
//        groupAnimation.delegate = self
//        if endIcon == titleIcon {
//            groupAnimation.setValue(scrollToLabelMoveNext(startView: titleIcon, endView: titleLabel, segueIdentifier: Segues.App.NewSurveyToTypingViewController), forKey: "completionHandler")
//        } else if endIcon == questionIcon {
//            groupAnimation.setValue(scrollToLabelMoveNext(startView: questionIcon, endView: questionLabel, segueIdentifier: Segues.App.NewSurveyToTypingViewController), forKey: "completionHandler")
//        } else if endIcon == hyperlinkIcon {
//            let closure: Closure = {
//                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
//                    self.scrollView.contentOffset.y = self.hyperlinkIcon.convert(self.hyperlinkIcon.frame.origin, to: self.contentView).y - self.hyperlinkIcon.bounds.height / 3
//                }) {
//                    _ in
//                    //                        self.animateNextStage(startView: self.hyperlinkIcon, endView: self.hyperlinkLabel) {
//                    //                            self.titleLabel.animate()
//                    //                            delay(seconds: 0.6) {
//                    ////                                self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.titleIcon)
//                    //                            }
//                    //                        }
//                }
//            }
//            groupAnimation.setValue(closure, forKey: "completionHandler")
//        } else if endIcon == anonIcon {
//            UIView.animate(withDuration: 0.6) {
//                self.anonLabel.alpha = 1
//            }
//        } else if endIcon == privacyIcon {
//            UIView.animate(withDuration: 0.6) {
//                self.privacyLabel.alpha = 1
//            }
//        } else if endIcon == votesIcon {
//            UIView.animate(withDuration: 0.6) {
//                self.votesLabel.alpha = 1
//            }
//        }
//
//        line.layer.add(groupAnimation, forKey: "animEnd")
//        endView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        UIView.animate(withDuration: lineAnimationDuration, delay: lineAnimationDuration * 0.55, options: [.curveEaseInOut], animations:
//            {
//                endView.alpha = 1
//                endView.transform = .identity
//        }) {
//            _ in
//            if completionHandler != nil {
//                completionHandler!()
//            }
//        }
//
//        line.layer.strokeEnd = 1
//
//    } else if startView == titleIcon, endView == titleLabel, let parentView = endView.superview, endView.alpha == 0 {
//
//        let fromPoint = titleIcon!.convert(titleIcon!.center, to: contentView)// CGPoint(x: 0, y: yOffset)
//        let endPoint = CGPoint(x: fromPoint.x, y: scrollView.convert(parentView.center, to: contentView).y)// + lineWidth)//CGPoint(x: frame.width, y: yOffset)
//        let line = drawLine(fromPoint: fromPoint, endPoint: endPoint, lineCap: .square)
//
//        contentView.layer.insertSublayer(line.layer, at: 0)//, below: endView.layer)//.addSublayer(line.layer)
//        let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration / 3)
//        strokeEndAnimation.setValue(completionHandler, forKey: "completionHandler")
//        strokeEndAnimation.delegate = self
//        line.layer.add(strokeEndAnimation, forKey: "animEnd")
//        animateLabel(label: titleLabel, labelParent: parentView)
//        line.layer.strokeEnd = 1
//
//    } else if startView == questionIcon, endView == questionLabel, let parentView = endView.superview, endView.alpha == 0  {
//
//        let fromPoint = scrollView.convert(questionIcon.center, to: contentView)
//        let endPoint = CGPoint(x: fromPoint.x, y: scrollView.convert(parentView.center, to: contentView).y)// + lineWidth)//CGPoint(x: frame.width, y: yOffset)
//        let line = drawLine(fromPoint: fromPoint, endPoint: endPoint, lineCap: .square)
//
//        contentView.layer.insertSublayer(line.layer, at: 0)//, below: endView.layer)//.addSublayer(line.layer)
//        let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration / 3)
//        strokeEndAnimation.setValue(completionHandler, forKey: "completionHandler")
//        strokeEndAnimation.delegate = self
//        line.layer.add(strokeEndAnimation, forKey: "animEnd")
//        animateLabel(label: questionLabel, labelParent: parentView)
//        line.layer.strokeEnd = 1
//
//    } else if startView == hyperlinkIcon, endView == hyperlinkLabel, let parentView = endView.superview, endView.alpha == 0   {
//
//        let fromPoint = scrollView.convert(hyperlinkIcon.center, to: contentView)
//        let endPoint = CGPoint(x: fromPoint.x, y: scrollView.convert(parentView.center, to: contentView).y)// + lineWidth)//CGPoint(x: frame.width, y: yOffset)
//
//        let line = drawLine(fromPoint: fromPoint, endPoint: endPoint, lineCap: .square)
//
//        contentView.layer.insertSublayer(line.layer, at: 0)//, below: endView.layer)//.addSublayer(line.layer)
//        let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration / 3)
//        strokeEndAnimation.setValue(completionHandler, forKey: "completionHandler")
//        strokeEndAnimation.delegate = self
//        line.layer.add(strokeEndAnimation, forKey: "animEnd")
//        animateLabel(label: hyperlinkLabel, labelParent: parentView)
//        line.layer.strokeEnd = 1
//
//        //Transition from label to icon
//    } else if let borderedLabel = startView as? UILabel, let _endView = endView as? SurveyCategoryIcon, endView.alpha == 0 {
//        var label: UILabel!
//        var segue = ""
//        var fromPoint = CGPoint.zero//scrollView.convert(CGPoint(x: label!.frame.midX, y: label!.frame.maxY), to: contentView)
//        if borderedLabel.accessibilityIdentifier == "Title", let parentView = borderedLabel.superview {
//            label = titleLabel
//            fromPoint = scrollView.convert(CGPoint(x: parentView.frame.midX, y: parentView.frame.maxY), to: contentView)
//            segue = Segues.App.NewSurveyToTypingViewController
//        } else if borderedLabel.accessibilityIdentifier == "Question", let parentView = borderedLabel.superview {
//            label = questionLabel
//            fromPoint = scrollView.convert(CGPoint(x: parentView.frame.midX, y: parentView.frame.maxY), to: contentView)
//            segue = Segues.App.NewSurveyToHyperlinkViewController
//        } else if borderedLabel.accessibilityIdentifier == "Hyperlink", let parentView = borderedLabel.superview {
//            label = hyperlinkLabel
//            fromPoint = scrollView.convert(CGPoint(x: parentView.frame.midX, y: parentView.frame.maxY), to: contentView)
//            segue = Segues.App.NewSurveyToImagesViewController
//        }
//        //            } else if borderedLabel.accessibilityIdentifier == "Hyperlink" {
//        //                label = hyperlinkLabel
//        //                segue = Segues.App.NewSurveyToImagesViewController
//        //            }
//        let nextLabel: UILabel? = view.viewWithTag(endView.tag + 1) as? UILabel
//        if fromPoint == .zero {
//            fromPoint = scrollView.convert(CGPoint(x: label!.frame.midX, y: label!.frame.maxY), to: contentView)
//        }
//        let endPoint =  scrollView.convert(_endView.center, to: contentView)
//        let line = drawLine(fromPoint: fromPoint, endPoint: endPoint, lineCap: .square)
//        contentView.layer.insertSublayer(line.layer, at: 0)
//
//        let groupAnimation = createLineAnimation(line: line)
//
//        line.layer.add(groupAnimation, forKey: "animEnd")
//        endView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        UIView.animate(withDuration: lineAnimationDuration, delay: lineAnimationDuration * 0.55, options: [.curveEaseInOut], animations: {
//            endView.alpha = 1
//            endView.transform = .identity
//        }) {
//            _ in
//            if nextLabel != nil {
//                scrollToLabelMoveNext(startView: endView, endView: nextLabel!, segueIdentifier: segue)()
//            } else {
//                self.performSegue(withIdentifier: segue, sender: nil)
//            }
//        }
//        line.layer.strokeEnd = 1
//    }
//}
//extension CreateNewSurveyViewController: UIScrollViewDelegate {
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        lastContentOffset = scrollView.contentOffset.y
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if lastContentOffset < scrollView.contentOffset.y {
//            navigationController?.setNavigationBarHidden(true, animated: true)
//            isNavigationBarHidden = true
//        } else {
//            navigationController?.setNavigationBarHidden(false, animated: true)
//            isNavigationBarHidden = false
//        }
//    }
//}

//@IBDesignable
//class BorderedLabel: UILabel {
//    let line = Line()
//    var lineWidth: CGFloat = 5
//    var isAnimated = false
//    var isClosed = false
//    var isCentered = true {
//        didSet {
//
//        }
//    }
//    var rightInset: CGFloat = 0
//
////    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
////        return CGRect(origin: .zero, size: CGSize(width: bounds.width - lineWidth * 2, height: bounds.height - lineWidth * 2))
////    }
//
//    override func drawText(in rect: CGRect) {
//        let border = lineWidth * 2
//        let insets = UIEdgeInsets(top: border, left: border, bottom: border, right: border + rightInset)
//        super.drawText(in: rect.inset(by: insets))
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureLine()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        configureLine()
//    }
//
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        calculateLine()
//    }
//
//    fileprivate func configureLine() {
////        let path = UIBezierPath()
////        let point_1 = CGPoint(x: frame.midX - lineWidth / 2, y: frame.minY + lineWidth / 2)
////        path.move(to: point_1)
////
////        let point_2 = CGPoint(x: frame.maxX - lineWidth / 2, y: frame.minY + lineWidth / 2)
////        path.addLine(to: point_2)
////        let point_3 = CGPoint(x: frame.maxX - lineWidth / 2, y: frame.maxY - lineWidth / 2)
////        path.addLine(to: point_3)
////        let point_4 = CGPoint(x: frame.minX + lineWidth / 2, y: frame.maxY - lineWidth / 2)
////        path.addLine(to: point_4)
////        let point_5 = CGPoint(x: frame.minX + lineWidth / 2, y: frame.minY + lineWidth / 2)
////        path.addLine(to: point_5)
////        let point_6 = CGPoint(x: frame.midX + lineWidth / 2, y: frame.minY + lineWidth / 2)
////        path.addLine(to: point_6)
//        line.layer.lineWidth = lineWidth
//        line.layer.strokeColor = K_COLOR_RED.withAlphaComponent(0.1).cgColor
//        line.layer.fillColor = UIColor.clear.cgColor
//        line.layer.lineCap = .square
////        line.layer.path = path.cgPath
////        line.layer.strokeEnd = isAnimated ? 1 : 0
////        layer.insertSublayer(line.layer, at: 0)
//        layer.addSublayer(line.layer)
//    }
//
//    fileprivate func calculateLine() {
//        let path = UIBezierPath()
//        let point_1 = CGPoint(x: bounds.width/2 + (isClosed ? 0 : lineWidth), y: 0 + lineWidth)
//        path.move(to: point_1)
//
//        let point_2 = CGPoint(x: bounds.width - lineWidth, y: 0 + lineWidth)
//        path.addLine(to: point_2)
//        let point_3 = CGPoint(x: bounds.width - lineWidth, y: bounds.height - lineWidth)
//        path.addLine(to: point_3)
//        let point_4 = CGPoint(x: 0 + lineWidth, y: bounds.height - lineWidth)
//        path.addLine(to: point_4)
//        let point_5 = CGPoint(x: 0 + lineWidth, y: 0 + lineWidth)
//        path.addLine(to: point_5)
//        let point_6 = CGPoint(x: bounds.width/2 - (isClosed ? 0 : lineWidth), y: 0 + lineWidth)
//        path.addLine(to: point_6)
//        line.layer.strokeEnd = isAnimated ? 1 : 0
//        line.layer.path = path.cgPath
//    }
//
//    func animate(_ duration: TimeInterval = 0.3) {
//        let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: 0.5)
////        let strokeEndAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
////        strokeEndAnimation.fromValue = line.layer.strokeEnd
////        strokeEndAnimation.toValue = 1
//        strokeEndAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeIn)
////        strokeEndAnimation.duration = 1.5
//        line.layer.add(strokeEndAnimation, forKey: "animEnd")
////        line.layer.strokeEnd = 1
//        isAnimated = true
//    }
//}



//            func scrollToLabelMoveNext(startView: UIView, endView: UILabel, segueIdentifier: String) -> Closure {
//                return {
//                    //                let navigationBarHeight: CGFloat! = self.isNavigationBarHidden ? self.navigationController?.navigationBar.frame.height : 0
//                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
//                        //Focus on label
//                        if self.scrollView.contentOffset.y == 0 {
//                            self.scrollView.contentOffset.y = startView.convert(startView.frame.origin, to: self.contentView).y - startView.bounds.height / 4.25// - navigationBarHeight / 2.5
//                        } else {
//                            self.scrollView.contentOffset.y = self.contentView.convert(startView.frame.origin, to: self.scrollView).y - startView.bounds.height / 4.25// - navigationBarHeight / 2.5
//                        }
//                    }) {
//                        _ in
//                        self.animateNextStage(startView: startView, endView: endView) {
//
//                            //                        endView.animate()
//                            delay(seconds: 0.4) {
//                                self.performSegue(withIdentifier: segueIdentifier, sender: startView)
//                            }
//                        }
//                    }
//                }
//            }
//
//func animateMaskLayer(duration: TimeInterval, startingPoint: CGPoint, view animatedView: UIView) {
//    var durationMultiplier = 1
//    //Starting Path
//    let rect = CGRect(x: animatedView.bounds.midX,
//                      y: animatedView.bounds.midY,
//                      width: 0,
//                      height: 0)
//    let circleMaskPathInitial = UIBezierPath(ovalIn: rect)
//
//    //Destination Path
//    let extremePoint = CGPoint(x: animatedView.bounds.midX,
//                               y: animatedView.bounds.midY)
//    let radius = sqrt((extremePoint.x*extremePoint.x) +
//        (extremePoint.y*extremePoint.y))
//    //            durationMultiplier = Int(radius) / 200
//
//    let initialRect = animatedView.frame.insetBy(dx: -radius, dy: -radius)
//    let finalRect = CGRect(origin: initialRect.origin, size: CGSize(width: initialRect.width, height: initialRect.width))
//
//    let circleMaskPathFinal = UIBezierPath(ovalIn: finalRect)
//
//    //Actual mask layer
//    let maskLayer = CAShapeLayer()
//    maskLayer.path = circleMaskPathFinal.cgPath
//    animatedView.layer.mask = maskLayer
//    animatedView.alpha = 1
//
//    //Mask Animation
//    let maskLayerAnimation = CABasicAnimation(keyPath: "path")
//    maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
//    maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
//    //            maskLayerAnimation.delegate = self
//    maskLayerAnimation.duration = duration //* Double(durationMultiplier)
//    //        maskLayerAnimation.isRemovedOnCompletion = true
//    maskLayerAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//    maskLayer.add(maskLayerAnimation, forKey: "path")
//}
