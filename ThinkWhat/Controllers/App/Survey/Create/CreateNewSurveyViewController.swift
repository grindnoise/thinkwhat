//
//  CreateNewSurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CreateNewSurveyViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView! //{
//        didSet {
//            scrollView.delegate = self
//        }
//    }
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var upperView: UIView!
//    @IBOutlet weak var lowerView: UIView!
    
    @IBOutlet weak var categoryTitle: UILabel! {
        didSet {
            if category == nil {
                categoryTitle.text = "КАТЕГОРИЯ"
            }
        }
    }
    @IBOutlet weak var anonTitle: UILabel!
    @IBOutlet weak var privacyTitle: UILabel!
    @IBOutlet weak var categoryIcon: SurveyCategoryIcon! {
        didSet {
            categoryIcon.layer.zPosition = 10
            if category == nil {
                categoryIcon.tagColor = K_COLOR_RED
                categoryIcon.text = "?"
                categoryIcon.categoryID = .Text
                if category != nil {
                    categoryTitle.text = "КАТЕГОРИЯ"
                }
            }
        }
    }
    @IBOutlet weak var anonIcon: SurveyCategoryIcon! {
        didSet {
            anonIcon.categoryID = .Anon
            anonIcon.tagColor   = K_COLOR_RED
        }
    }
    @IBOutlet weak var privacyIcon: SurveyCategoryIcon! {
        didSet {
            privacyIcon.categoryID = .Eye
            privacyIcon.tagColor   = K_COLOR_RED
        }
    }
    @IBOutlet weak var votesIcon: SurveyCategoryIcon! {
        didSet {
            votesIcon.categoryID = .Text
            votesIcon.tagColor   = Colors.UpperButtons.Avocado
            votesIcon.text = "100"
        }
    }
    @IBOutlet weak var titleIcon: SurveyCategoryIcon! {
        didSet {
            titleIcon.accessibilityIdentifier = "titleIcon"
            titleIcon.tagColor = K_COLOR_RED
            titleIcon.categoryID = .Text
            titleIcon.text = "ТИТУЛ"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            titleIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var categorySubview: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            categorySubview.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var anonSubview: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            anonSubview.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var privacySubview: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            privacySubview.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var votesSubview: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            votesSubview.addGestureRecognizer(tap)
//            if let label = votesSubview.subviews.filter( {$0 is UILabel } ).first as? UILabel {
//                label.backgroundColor = UIColor.white.withAlphaComponent(0.5)
//            }
        }
    }
    @IBOutlet weak var titleSubview: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            titleSubview.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var titleLabel: BorderedLabel! {
        didSet {
            titleLabel.alpha = 0
            titleLabel.accessibilityIdentifier = "Title"
            titleLabel.isUserInteractionEnabled = true
            titleLabel.layer.zPosition = 100
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
//            tap.numberOfTouchesRequired = 1
//            tap.cancelsTouchesInView = false
            titleLabel.addGestureRecognizer(tap)
        }
    }
//    @IBOutlet weak var questionSubview: UIView!
    @IBOutlet weak var questionIcon: SurveyCategoryIcon! {
        didSet {
            questionIcon.accessibilityIdentifier = "questionIcon"
            questionIcon.tagColor = K_COLOR_RED
            questionIcon.categoryID = .Text
            questionIcon.text = "ВОПРОС"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            questionIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var questionLabel: BorderedLabel! {
        didSet {
            questionLabel.alpha = 0
            questionLabel.accessibilityIdentifier = "Question"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            questionLabel.isUserInteractionEnabled = true
            questionLabel.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var hyperlinkIcon: SurveyCategoryIcon! {
        didSet {
//            hyperlinkIcon.accessibilityIdentifier = "questionIcon"
            hyperlinkIcon.tagColor = K_COLOR_RED
            hyperlinkIcon.categoryID = .Text
            hyperlinkIcon.text = "ССЫЛКА"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            hyperlinkIcon.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var hyperlinkLabel: BorderedLabel! {
        didSet {
            hyperlinkLabel.alpha = 0
            hyperlinkLabel.accessibilityIdentifier = "Hyperlink"
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            hyperlinkLabel.isUserInteractionEnabled = true
            hyperlinkLabel.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var titleVerticalSpacingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var questionVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabelHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var hyperlinkVerticalSpacingConstraint: NSLayoutConstraint!
    @IBInspectable var lineWidth: CGFloat = 5
    
    private var subviewVerticalSpacing: CGFloat = 0 {
        didSet {
            if oldValue != subviewVerticalSpacing {
                titleVerticalSpacingConstraint.constant = subviewVerticalSpacing
                titleSubview.setNeedsLayout()
                titleSubview.layoutIfNeeded()
//                questionVerticalSpacingConstraint.constant = subviewVerticalSpacing
//                questionIcon.setNeedsLayout()
//                questionIcon.layoutIfNeeded()
//                hyperlinkVerticalSpacingConstraint.constant = subviewVerticalSpacing
//                hyperlinkIcon.setNeedsLayout()
//                hyperlinkIcon.layoutIfNeeded()
            }
        }
    }
//    var isNavigationBarHidden = false
    private var lastContentOffset: CGFloat = 0
    private var lineAnimationDuration = 0.3
//    var delegate: CallbackDelegate?
//    var childColor: UIColor?
    var category: SurveyCategory? {
        didSet {
            if category != nil {
                categoryIcon.tagColor = category!.tagColor ?? K_COLOR_RED
                categoryIcon.categoryID = SurveyCategoryIcon.CategoryID(rawValue: category!.ID) ?? .Null
                categoryTitle.text = category!.title.uppercased()
                if oldValue == nil {
                    self.animateNextStage(startView: self.categorySubview, endView: self.anonSubview, completionHandler: {
                        self.performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
                    })
                }
            }
        }
    }
    var isAnonymous = false {
        didSet {
            animateNextStage(startView: anonSubview, endView: privacySubview, completionHandler: {
                self.performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
            })
        }
    }
    var isPrivate = false {
        didSet {
            animateNextStage(startView: privacySubview, endView: votesSubview, completionHandler: {
                self.performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
            })
        }
    }
    var votesCount = 100 {
        didSet {
            animateNextStage(startView: votesSubview, endView: titleSubview, completionHandler: nil)
        }
    }
    var questionTitle = "" {
        didSet {
            if oldValue.isEmpty, !questionTitle.isEmpty {
                animateNextStage(startView: titleLabel, endView: questionIcon, completionHandler: nil)
            }
            titleLabel.text = questionTitle
        }
    }
    var question = "" {
        didSet {
            if oldValue.isEmpty, !question.isEmpty {
                animateNextStage(startView: questionLabel, endView: hyperlinkIcon, completionHandler: nil)
            }
            questionLabel.text = question
        }
    }
    var hyperlink: URL? {
        didSet {
            animateNextStage(startView: hyperlinkLabel, endView: hyperlinkIcon, completionHandler: nil)
        }
    }
    
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
        if subviewVerticalSpacing == 0 {
            subviewVerticalSpacing = CGPointDistance(from: votesSubview.convert(votesIcon.center, to: contentView), to: categorySubview.convert(categoryIcon.center, to: contentView))
            
        }
        
        scrollView.contentSize.height = 1500
    }

    @objc fileprivate func iconTapped(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended, let v = gesture.view {
            if let icon = v.subviews.filter({ $0 is SurveyCategoryIcon}).first as? SurveyCategoryIcon {
                if icon === categoryIcon {
                    performSegue(withIdentifier: Segues.App.NewSurveyToCategorySelection, sender: nil)
                } else if icon === anonIcon {
                    performSegue(withIdentifier: Segues.App.NewSurveyToAnonimitySelection, sender: nil)
                } else if icon === privacyIcon {
                    performSegue(withIdentifier: Segues.App.NewSurveyToPrivacySelection, sender: nil)
                } else if icon === votesIcon {
                    performSegue(withIdentifier: Segues.App.NewSurveyToVotesCountViewController, sender: nil)
                } else if icon === titleIcon {
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: icon)
                }
            } else if v === titleLabel || v === titleIcon {
                performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: titleIcon)
            } else if v === questionLabel || v === questionIcon {
                performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: questionIcon)
            }
        }
    }
    
    public func animateNextStage(startView: UIView, endView: UIView, completionHandler: Closure?) {

        func drawLine(fromView: UIView, toView: UIView, lineCap: CAShapeLayerLineCap) -> Line {
            let line = Line()
            line.path = UIBezierPath()
            
            let startPoint = fromView.convert(fromView.center, to: contentView)// CGPoint(x: 0, y: yOffset)
            line.path.move(to: startPoint)
            
            let endPoint = toView.convert(toView.center, to: contentView)//CGPoint(x: frame.width, y: yOffset)
            line.path.addLine(to: endPoint)
            
            
            let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
            let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
            
            line.layer.strokeStart = 0
            line.layer.strokeEnd = 0
            line.layer.lineWidth = lineWidth
            line.layer.strokeColor = K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = lineCap
            
            line.layer.path = path.cgPath
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
            line.layer.strokeColor = K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = lineCap
            
            line.layer.path = path.cgPath
            return line
        }
        
        func createLineAnimation(line: Line) -> CAAnimationGroup {
            let strokeEndAnimation      = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration)
            let strokeWidthAnimation    = CAKeyframeAnimation(keyPath:"lineWidth")
            strokeWidthAnimation.values   = [lineWidth * 3, lineWidth]
            strokeWidthAnimation.keyTimes = [0, 1]
            strokeWidthAnimation.duration = lineAnimationDuration
            let pathFillColorAnim      = CAKeyframeAnimation(keyPath:"strokeColor")
            pathFillColorAnim.values   = [K_COLOR_RED.cgColor, K_COLOR_RED.withAlphaComponent(0.1).cgColor]
            pathFillColorAnim.keyTimes = [0, 1]
            pathFillColorAnim.duration = lineAnimationDuration
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [strokeEndAnimation, strokeWidthAnimation, pathFillColorAnim]
            groupAnimation.duration = lineAnimationDuration
            
            return groupAnimation
        }
        
        func getLabelAnimation(startView: UIView, endView: BorderedLabel, segueIdentifier: String) -> Closure {
            return {
//                let navigationBarHeight: CGFloat! = self.isNavigationBarHidden ? self.navigationController?.navigationBar.frame.height : 0
                UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                    //Focus on label
                    if self.scrollView.contentOffset.y == 0 {
                        self.scrollView.contentOffset.y = startView.convert(startView.frame.origin, to: self.contentView).y - startView.bounds.height / 4.25// - navigationBarHeight / 2.5
                    } else {
                        self.scrollView.contentOffset.y = self.contentView.convert(startView.frame.origin, to: self.scrollView).y - startView.bounds.height / 4.25// - navigationBarHeight / 2.5
                    }
                }) {
                    _ in
                    self.animateNextStage(startView: startView, endView: endView) {
                        endView.animate()
                        delay(seconds: 0.6) {
                            self.performSegue(withIdentifier: segueIdentifier, sender: startView)
                        }
                    }
                }
            }
        }
        
        if endView.alpha == 0, let startIcon = startView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let endIcon = endView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let line = drawLine(fromView: startIcon, toView: endIcon, lineCap: .round) as? Line, let groupAnimation = createLineAnimation(line: line) as? CAAnimationGroup {
            contentView.layer.insertSublayer(line.layer, at: 0)
            groupAnimation.delegate = self
            if endIcon == titleIcon {
                groupAnimation.setValue(getLabelAnimation(startView: titleIcon, endView: titleLabel, segueIdentifier: Segues.App.NewSurveyToTypingViewController), forKey: "completionHandler")
            } else if endIcon == questionIcon {
                groupAnimation.setValue(getLabelAnimation(startView: questionIcon, endView: questionLabel, segueIdentifier: Segues.App.NewSurveyToTypingViewController), forKey: "completionHandler")
            } else if endIcon == hyperlinkIcon {
                let closure: Closure = {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                        self.scrollView.contentOffset.y = self.hyperlinkIcon.convert(self.hyperlinkIcon.frame.origin, to: self.contentView).y - self.hyperlinkIcon.bounds.height / 3
                    }) {
                        _ in
//                        self.animateNextStage(startView: self.hyperlinkIcon, endView: self.hyperlinkLabel) {
//                            self.titleLabel.animate()
//                            delay(seconds: 0.6) {
////                                self.performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: self.titleIcon)
//                            }
//                        }
                    }
                }
                groupAnimation.setValue(closure, forKey: "completionHandler")
            }
            
            line.layer.add(groupAnimation, forKey: "animEnd")
            endView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: lineAnimationDuration, delay: lineAnimationDuration * 0.75, options: [.curveEaseInOut], animations:
                {
                    endView.alpha = 1
                    endView.transform = .identity
            }) {
                _ in
                if completionHandler != nil {
                    completionHandler!()
                }
            }
            
            line.layer.strokeEnd = 1
            
        } else if startView == titleIcon, let label = endView as? BorderedLabel, label.alpha == 0 {

            let fromPoint = titleIcon!.convert(titleIcon!.center, to: contentView)// CGPoint(x: 0, y: yOffset)
            let endPoint = CGPoint(x: fromPoint.x, y: scrollView.convert(label.frame.origin, to: contentView).y + lineWidth)//CGPoint(x: frame.width, y: yOffset)
            
            let line = drawLine(fromPoint: fromPoint, endPoint: endPoint, lineCap: .square)
            
            contentView.layer.insertSublayer(line.layer, at: 0)//, below: endView.layer)//.addSublayer(line.layer)
            let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration / 3)
            strokeEndAnimation.setValue(completionHandler, forKey: "completionHandler")
            strokeEndAnimation.delegate = self
            line.layer.add(strokeEndAnimation, forKey: "animEnd")
            UIView.animate(withDuration: lineAnimationDuration, delay: lineAnimationDuration / 2, options: [.curveEaseInOut], animations: {
                endView.alpha = 1
            })
            line.layer.strokeEnd = 1
            
            //Transition from label to icon
        } else if startView == questionIcon, let label = endView as? BorderedLabel, label.alpha == 0 {
            
            let fromPoint = scrollView.convert(questionIcon.center, to: contentView)
            let endPoint = CGPoint(x: fromPoint.x, y: scrollView.convert(label.frame.origin, to: contentView).y + lineWidth)//CGPoint(x: frame.width, y: yOffset)
            
            let line = drawLine(fromPoint: fromPoint, endPoint: endPoint, lineCap: .square)
            
            contentView.layer.insertSublayer(line.layer, at: 0)//, below: endView.layer)//.addSublayer(line.layer)
            let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration / 3)
            strokeEndAnimation.setValue(completionHandler, forKey: "completionHandler")
            strokeEndAnimation.delegate = self
            line.layer.add(strokeEndAnimation, forKey: "animEnd")
            UIView.animate(withDuration: lineAnimationDuration, delay: lineAnimationDuration / 2, options: [.curveEaseInOut], animations: {
                endView.alpha = 1
            })
            line.layer.strokeEnd = 1
            
            //Transition from label to icon
        } else if startView == hyperlinkIcon, let label = endView as? BorderedLabel, label.alpha == 0 {
            
            let fromPoint = scrollView.convert(hyperlinkIcon.center, to: contentView)
            let endPoint = CGPoint(x: fromPoint.x, y: scrollView.convert(label.frame.origin, to: contentView).y + lineWidth)//CGPoint(x: frame.width, y: yOffset)
            
            let line = drawLine(fromPoint: fromPoint, endPoint: endPoint, lineCap: .square)
            
            contentView.layer.insertSublayer(line.layer, at: 0)//, below: endView.layer)//.addSublayer(line.layer)
            let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration / 3)
            strokeEndAnimation.setValue(completionHandler, forKey: "completionHandler")
            strokeEndAnimation.delegate = self
            line.layer.add(strokeEndAnimation, forKey: "animEnd")
            UIView.animate(withDuration: lineAnimationDuration, delay: lineAnimationDuration / 2, options: [.curveEaseInOut], animations: {
                endView.alpha = 1
            })
            line.layer.strokeEnd = 1
            
            //Transition from label to icon
        } else if let borderedLabel = startView as? BorderedLabel, let _endView = endView as? SurveyCategoryIcon {
            var label: BorderedLabel!
            if borderedLabel.accessibilityIdentifier == "Title" {
                label = titleLabel
            } else if borderedLabel.accessibilityIdentifier == "Question" {
                label = questionLabel
            } else if borderedLabel.accessibilityIdentifier == "Hyperlink" {
                label = hyperlinkLabel
            }
            let nextLabel: BorderedLabel? = view.viewWithTag(endView.tag + 1) as? BorderedLabel
            let fromPoint = scrollView.convert(CGPoint(x: label!.frame.midX, y: label!.frame.maxY), to: contentView)
            let endPoint =  scrollView.convert(_endView.center, to: contentView)
            let line = drawLine(fromPoint: fromPoint, endPoint: endPoint, lineCap: .square)
            contentView.layer.insertSublayer(line.layer, at: 0)

            let groupAnimation = createLineAnimation(line: line)

            line.layer.add(groupAnimation, forKey: "animEnd")
            endView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: lineAnimationDuration, delay: lineAnimationDuration * 0.75, options: [.curveEaseInOut], animations: {
                endView.alpha = 1
                endView.transform = .identity
            }) {
                _ in
                if nextLabel != nil {
                    getLabelAnimation(startView: endView, endView: nextLabel!, segueIdentifier: //Segues.App.NewSurveyToHyperlinkViewController)()
                }
            }
            line.layer.strokeEnd = 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.duration = 0.25
            nc.transitionStyle = .Icon
            if segue.identifier == Segues.App.NewSurveyToCategorySelection, let destinationVC = segue.destination as? CategorySelectionViewController {
                destinationVC.category = category
                //                destinationVC.delegate = self
            } else if segue.identifier == Segues.App.NewSurveyToTypingViewController, let destinationVC = segue.destination as? TextViewController {
                if let icon = sender as? SurveyCategoryIcon {
                    if icon === titleIcon {
                        destinationVC.titleString = "Титул"
                        destinationVC.charactersLimit = DjangoVariables.FieldRestrictions.surveyTitleLength
                        destinationVC.textContent = questionTitle.isEmpty ? titleLabel.text! : questionTitle
                        //                    destinationVC.placeholder = "Введите титул.."
                        destinationVC.delegate = self
                        destinationVC.font = titleLabel.font
                        destinationVC.textColor = titleLabel.textColor
                        destinationVC.textCentered = true
                        destinationVC.accessibilityIdentifier = "Title"
                    } else if icon === questionIcon {
                        destinationVC.titleString = "Вопрос"
                        destinationVC.charactersLimit = DjangoVariables.FieldRestrictions.surveyQuestionLength
                        destinationVC.textContent = question.isEmpty ? "" : question
                        destinationVC.delegate = self
                        destinationVC.font = StringAttributes.getFont(name: StringAttributes.Fonts.Style.Regular, size: 13)
                        destinationVC.textColor = questionLabel.textColor
                        destinationVC.accessibilityIdentifier = "Question"
                    }
                }
                nc.duration = 0.2
                nc.transitionStyle = .Blur
                //                if titleLabel.gestureRecognizers == nil {
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
//                    titleLabel.isUserInteractionEnabled = true
//                    titleLabel.addGestureRecognizer(tap)
//                }
            } else if segue.identifier == Segues.App.NewSurveyToVotesCountViewController, let destinationVC = segue.destination as? VotesCountViewController {
                destinationVC.votesCount = votesCount
            } else if segue.identifier == Segues.App.NewSurveyToVotesCountViewController, let destinationVC = segue.destination as? HyperlinkSelectionViewController {
                if hyperlink != nil {
                    destinationVC.hyperlink = hyperlink
                }
            }
            /*else if segue.identifier == Segues.App.NewSurveyToAnonimitySelection || segue.identifier == Segues.App.NewSurveyToPrivacySelection {
             nc.duration = 0.4
             nc.transitionStyle = .Icon
             }*/
            
        }
    }
}

extension CreateNewSurveyViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionHandler = anim.value(forKey: "completionHandler") as? Closure {
            completionHandler()
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

@IBDesignable
class BorderedLabel: UILabel {
    let line = Line()
    var lineWidth: CGFloat = 5
    var isAnimated = false
    var isCentered = true {
        didSet {
            
        }
    }
    
//    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        return CGRect(origin: .zero, size: CGSize(width: bounds.width - lineWidth * 2, height: bounds.height - lineWidth * 2))
//    }

    override func drawText(in rect: CGRect) {
        let border = lineWidth * 2
        let insets = UIEdgeInsets(top: border, left: border, bottom: border, right: border)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLine()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLine()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        calculateLine()
    }
    
    fileprivate func configureLine() {
//        let path = UIBezierPath()
//        let point_1 = CGPoint(x: frame.midX - lineWidth / 2, y: frame.minY + lineWidth / 2)
//        path.move(to: point_1)
//
//        let point_2 = CGPoint(x: frame.maxX - lineWidth / 2, y: frame.minY + lineWidth / 2)
//        path.addLine(to: point_2)
//        let point_3 = CGPoint(x: frame.maxX - lineWidth / 2, y: frame.maxY - lineWidth / 2)
//        path.addLine(to: point_3)
//        let point_4 = CGPoint(x: frame.minX + lineWidth / 2, y: frame.maxY - lineWidth / 2)
//        path.addLine(to: point_4)
//        let point_5 = CGPoint(x: frame.minX + lineWidth / 2, y: frame.minY + lineWidth / 2)
//        path.addLine(to: point_5)
//        let point_6 = CGPoint(x: frame.midX + lineWidth / 2, y: frame.minY + lineWidth / 2)
//        path.addLine(to: point_6)
        line.layer.lineWidth = lineWidth
        line.layer.strokeColor = K_COLOR_RED.withAlphaComponent(0.1).cgColor
        line.layer.fillColor = UIColor.clear.cgColor
        line.layer.lineCap = .square
//        line.layer.path = path.cgPath
//        line.layer.strokeEnd = isAnimated ? 1 : 0
//        layer.insertSublayer(line.layer, at: 0)
        layer.addSublayer(line.layer)
    }
    
    fileprivate func calculateLine() {
        let path = UIBezierPath()
        let point_1 = CGPoint(x: bounds.width/2 + lineWidth, y: 0 + lineWidth)
        path.move(to: point_1)
        
        let point_2 = CGPoint(x: bounds.width - lineWidth, y: 0 + lineWidth)
        path.addLine(to: point_2)
        let point_3 = CGPoint(x: bounds.width - lineWidth, y: bounds.height - lineWidth)
        path.addLine(to: point_3)
        let point_4 = CGPoint(x: 0 + lineWidth, y: bounds.height - lineWidth)
        path.addLine(to: point_4)
        let point_5 = CGPoint(x: 0 + lineWidth, y: 0 + lineWidth)
        path.addLine(to: point_5)
        let point_6 = CGPoint(x: bounds.width/2 - lineWidth, y: 0 + lineWidth)
        path.addLine(to: point_6)
        line.layer.strokeEnd = isAnimated ? 1 : 0
        line.layer.path = path.cgPath
    }
    
    func animate() {
        let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: 0.65)
//        let strokeEndAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
//        strokeEndAnimation.fromValue = line.layer.strokeEnd
//        strokeEndAnimation.toValue = 1
        strokeEndAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeIn)
//        strokeEndAnimation.duration = 1.5
        line.layer.add(strokeEndAnimation, forKey: "animEnd")
//        line.layer.strokeEnd = 1
        isAnimated = true
    }
}
