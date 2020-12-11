//
//  CreateNewSurveyViewController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 27.10.2020.
//  Copyright © 2020 Pavel Bukharov. All rights reserved.
//

import UIKit

class CreateNewSurveyViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
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
            let tap = UITapGestureRecognizer(target: self, action: #selector(CreateNewSurveyViewController.iconTapped(gesture:)))
            titleLabel.addGestureRecognizer(tap)
        }
    }
    
    
    @IBOutlet weak var titleVerticalSpacingConstraint: NSLayoutConstraint!
    @IBInspectable var lineWidth: CGFloat = 5
    
    private var subviewVerticalSpacing: CGFloat = 0 {
        didSet {
            if oldValue != subviewVerticalSpacing {
                titleVerticalSpacingConstraint.constant = subviewVerticalSpacing
                titleSubview.setNeedsLayout()
                titleSubview.layoutIfNeeded()
            }
        }
    }
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.isShadowed = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if subviewVerticalSpacing == 0 {
            subviewVerticalSpacing = CGPointDistance(from: votesSubview.convert(votesIcon.center, to: contentView), to: categorySubview.convert(categoryIcon.center, to: contentView))
            
        }
        scrollView.contentSize.height = 1000
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
                    performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: nil)
                }
            } else if v === titleLabel || v === titleIcon {
                performSegue(withIdentifier: Segues.App.NewSurveyToTypingViewController, sender: nil)
            }
        }
    }
    
    public func animateNextStage(startView: UIView, endView: UIView, completionHandler: Closure?) {
        if endView.alpha == 0, let startIcon = startView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon, let endIcon = endView.subviews.filter({ $0 is SurveyCategoryIcon }).first as? SurveyCategoryIcon {
            let line = Line()
            line.path = UIBezierPath()
            
            let startPoint = startIcon.convert(startIcon.center, to: contentView)// CGPoint(x: 0, y: yOffset)
            line.path.move(to: startPoint)
            
            let endPoint = endIcon.convert(endIcon.center, to: contentView)//CGPoint(x: frame.width, y: yOffset)
            line.path.addLine(to: endPoint)
            
            
            let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
            let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
            
            line.layer.strokeStart = 0.2
            line.layer.strokeEnd = 0.2
            line.layer.lineWidth = lineWidth
            line.layer.strokeColor = K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = .round
            
            line.layer.path = path.cgPath
            contentView.layer.insertSublayer(line.layer, at: 0)//, below: endView.layer)//.addSublayer(line.layer)
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
            
            if endIcon == titleIcon {
                groupAnimation.delegate = self
                let closure: Closure = {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                        self.scrollView.contentOffset.y = self.titleIcon.convert(self.titleIcon.frame.origin, to: self.contentView).y - self.titleIcon.bounds.height / 3
                    }) {
                        _ in
                        self.animateNextStage(startView: self.titleIcon, endView: self.titleLabel) {
                            self.titleLabel.animate()
                        }
                    }
//                    delay(seconds: 0.5) {
//                        self.titleLabel.animate()
//                        UIView.animate(withDuration: 0.3) {
//                            self.titleLabel.alpha = 1
//                        }
//                    }
                }
                groupAnimation.setValue(closure, forKey: "completionHandler")
            }
            
            line.layer.add(groupAnimation, forKey: "animEnd")
            endView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: lineAnimationDuration, delay: lineAnimationDuration * 0.5, options: [.curveEaseInOut], animations:
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
//            if endIcon == titleIcon {
//                UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut], animations: {
//                    self.scrollView.contentOffset.y = self.titleIcon.convert(self.titleIcon.frame.origin, to: self.contentView).y - self.titleIcon.bounds.height / 2
//                })
//                
//                delay(seconds: 2) {
//                    self.titleLabel.animate()
//                }
//                UIView.animate(withDuration: 0.3) {
//                    self.titleLabel.alpha = 1
//                }
//            }
        } else if startView == titleIcon, let label = endView as? BorderedLabel, label.alpha == 0 {
            let line = Line()
            line.path = UIBezierPath()
            
            endView.setNeedsLayout()
            endView.layoutIfNeeded()
            
            let startPoint = startView.convert(startView.center, to: contentView)// CGPoint(x: 0, y: yOffset)
            line.path.move(to: startPoint)
            
            let endPoint = CGPoint(x: startPoint.x, y: scrollView.convert(endView.frame.origin, to: contentView).y + lineWidth)//CGPoint(x: frame.width, y: yOffset)
            line.path.addLine(to: endPoint)
            
            
            let interfaceDirection = UIView.userInterfaceLayoutDirection(for: UISemanticContentAttribute.unspecified)
            let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path
            
            line.layer.strokeStart = 0.2
            line.layer.strokeEnd = 0.2
            line.layer.lineWidth = lineWidth
            line.layer.strokeColor = K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = .square
            
            line.layer.path = path.cgPath
            contentView.layer.insertSublayer(line.layer, at: 0)//, below: endView.layer)//.addSublayer(line.layer)
            let strokeEndAnimation   = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: lineAnimationDuration / 3)
            strokeEndAnimation.setValue(completionHandler, forKey: "completionHandler")
            strokeEndAnimation.delegate = self
            line.layer.add(strokeEndAnimation, forKey: "animEnd")
            UIView.animate(withDuration: lineAnimationDuration, delay: lineAnimationDuration / 2, options: [.curveEaseInOut], animations:
                {
                    endView.alpha = 1
            })
            line.layer.strokeEnd = 1
            
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
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = navigationController as? NavigationControllerPreloaded {
            nc.duration = 0.25
            nc.transitionStyle = .Icon
            if segue.identifier == Segues.App.NewSurveyToCategorySelection, let destinationVC = segue.destination as? CategorySelectionViewController {
                destinationVC.category = category
//                destinationVC.delegate = self
            } else if segue.identifier == Segues.App.NewSurveyToTypingViewController {
                nc.transitionStyle = .Default
            } else if segue.identifier == Segues.App.NewSurveyToVotesCountViewController, let destionationVC = segue.destination as? VotesCountViewController {
                destionationVC.votesCount = votesCount
            }/*else if segue.identifier == Segues.App.NewSurveyToAnonimitySelection || segue.identifier == Segues.App.NewSurveyToPrivacySelection {
                nc.duration = 0.4
                nc.transitionStyle = .Icon
            }*/
            
        }
    }
}

@IBDesignable
class BorderedLabel: UILabel {
    let line = Line()
    var lineWidth: CGFloat = 5
    var isAnimated = false
    
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
