//
//  PollCreationView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 26.05.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class PollCreationView: UIView {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        setupUI()
        setObservers()
    }
    
    override func layoutSubviews() {
        
    }
    
    // MARK: - Properties
    weak var viewInput: PollCreationViewInput?
    private var newInstance: Survey?
    private var topic: Topic! {
        didSet {
            guard oldValue != topic else { return }
            Task {
                try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
                await MainActor.run {
                    let destinationPath = (topicButton.icon.getLayer(Icon.Category(rawValue: topic.id) ?? .Null) as! CAShapeLayer).path!
                    let pathAnim = Animations.get(property: .Path,
                                                  fromValue: (topicButton.icon.icon as! CAShapeLayer).path as Any,
                                                  toValue: destinationPath as Any,
                                                  duration: 0.3,
                                                  delay: 0,
                                                  repeatCount: 0,
                                                  autoreverses: false,
                                                  timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                  delegate: nil,
                                                  isRemovedOnCompletion: true)
                    topicButton.icon.icon.add(pathAnim, forKey: nil)
                    (topicButton.icon.icon as! CAShapeLayer).path = destinationPath
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        self.setText()
                        self.topicButton.color = self.topic.tagColor
                    } completion: { _ in
                        self.color = self.topic.tagColor
                        self.viewInput?.onStageCompleted()
                    }
                }
            }
        }
    }
    private var option: PollCreationController.Option = .Null {
        didSet {
            guard oldValue != option else { return }
            Task {
                try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
                await MainActor.run {
                    var destinationPath: CGPath!
                    switch option{
                    case .Private:
                        destinationPath = (optionsButton.icon.getLayer(Icon.Category.Locked) as! CAShapeLayer).path!
                    case .Ordinary:
                        destinationPath = (optionsButton.icon.getLayer(Icon.Category.ManFace) as! CAShapeLayer).path!
                    case .Anon:
                        destinationPath = (optionsButton.icon.getLayer(Icon.Category.Anon) as! CAShapeLayer).path!
                    default:
                        destinationPath = (topicButton.icon.icon as! CAShapeLayer).path
                    }
                    let pathAnim = Animations.get(property: .Path,
                                                  fromValue: (topicButton.icon.icon as! CAShapeLayer).path as Any,
                                                  toValue: destinationPath as Any,
                                                  duration: 0.3,
                                                  delay: 0,
                                                  repeatCount: 0,
                                                  autoreverses: false,
                                                  timingFunction: CAMediaTimingFunctionName.easeInEaseOut,
                                                  delegate: nil,
                                                  isRemovedOnCompletion: true)
                    optionsButton.icon.icon.add(pathAnim, forKey: nil)
                    (optionsButton.icon.icon as! CAShapeLayer).path = destinationPath
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        self.setText()
                    } completion: { _ in
//                        self.viewInput?.onStageCompleted()
                    }
                }
                try await Task.sleep(nanoseconds: UInt64(0.25 * 1_000_000_000))
                await MainActor.run {
                    viewInput?.onStageCompleted()
                }
            }
        }
    }
    var imageItems: [ImageItem] = []
    
    // MARK: - UI Properties
    private var fontSize: CGFloat = .zero
    private var color: UIColor = .systemGray {
        didSet {
            guard oldValue != color else { return }
            lines.forEach { $0.layer.strokeColor = color.withAlphaComponent(0.3).cgColor }
            guard !scrollContentView.isNil, oldValue != color else { return }
            scrollContentView.get(all: [CircleButton.self]).forEach {
                guard let v =  $0 as? CircleButton else { return }
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    v.color = self.color
                }
            }
            scrollContentView.get(all: [UITextView.self]).forEach {
                guard let v =  $0 as? UITextView else { return }
                v.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            }
            pollURLSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollImagesSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            if #available(iOS 14, *) {
                guard let v = imagesContainer as? ImageSelectionCollectionView else { return }
                v.color = color
            } else {
                // Fallback on earlier versions
            }
        }
    }
    private var lines: [Line] = []
    private var lineWidth: CGFloat = .zero
    private var lineAnimationDuration = 0.3
    private var observers: [NSKeyValueObservation] = []
//    private var pollTitleObserver: NSKeyValueObservation?
//    private var pollDescriptionObserver: NSKeyValueObservation?
//    private var pollQuestionObserver: NSKeyValueObservation?
//    private var pollURLObserver: NSKeyValueObservation?
//    private var pollImagesObserver: NSKeyValueObservation?
//    private var pollChoicesObserver: NSKeyValueObservation?
//    private var pollURLTextFieldObserver: NSKeyValueObservation?
    private var isTextFieldEditingEnabled = true
    private var imagesContainer: (UIView & ImageSelectionProvider)!
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    ///Topic
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicStaticLabel: ArcLabel!
    @IBOutlet weak var topicLabel: ArcLabel!
    @IBOutlet weak var topicButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            topicButton.addGestureRecognizer(tap)
//            topicButton.icon.alpha = 0
            topicButton.state = .On
            topicButton.color = color
            topicButton.text = "РАЗДЕЛ"
            topicButton.category = .QuestionMark
        }
    }
    
    ///Options
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var optionsStaticLabel: ArcLabel!
    @IBOutlet weak var optionsLabel: ArcLabel!
    @IBOutlet weak var optionsButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            optionsButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            optionsButton.state = .On
            optionsButton.color = color
            optionsButton.text = "РАЗДЕЛ"
            optionsButton.category = .QuestionMark
        }
    }
    
    ///Poll title
    @IBOutlet weak var pollTitleView: UIView!
    @IBOutlet weak var pollTitleStaticLabel: ArcLabel!
    @IBOutlet weak var pollTitleButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollTitleButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollTitleButton.state = .On
            pollTitleButton.color = color
            pollTitleButton.text = "РАЗДЕЛ"
            pollTitleButton.category = .Abc
        }
    }
    @IBOutlet weak var pollTitleBg: UIView!
    @IBOutlet weak var pollTitleTextView: UITextView! {
        didSet {
            pollTitleTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
            pollTitleTextView.delegate = self
            pollTitleTextView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollTitleTextView.text = ""
        }
    }
    
    ///Poll description
    @IBOutlet weak var pollDescriptionView: UIView!
    @IBOutlet weak var pollDescriptionStaticLabel: ArcLabel!
    @IBOutlet weak var pollDescriptionButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollDescriptionButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollDescriptionButton.state = .On
            pollDescriptionButton.color = color
            pollDescriptionButton.category = .Paragraph
        }
    }
    @IBOutlet weak var pollDescriptionBg: UIView!
    @IBOutlet weak var pollDescriptionTextView: UITextView! {
        didSet {
            pollDescriptionTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
            pollDescriptionTextView.delegate = self
            pollDescriptionTextView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollDescriptionTextView.text = ""
            pollDescriptionTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }

    ///Poll question
    @IBOutlet weak var pollQuestionView: UIView!
    @IBOutlet weak var pollQuestionStaticLabel: ArcLabel!
    @IBOutlet weak var pollQuestionButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollQuestionButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollQuestionButton.state = .On
            pollQuestionButton.color = color
            pollQuestionButton.category = .QuestionMark
        }
    }
    @IBOutlet weak var pollQuestionBg: UIView!
    @IBOutlet weak var pollQuestionTextView: UITextView! {
        didSet {
            pollQuestionTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
            pollQuestionTextView.delegate = self
            pollQuestionTextView.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
            pollQuestionTextView.text = ""
            pollQuestionTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    
    ///Poll URL
    @IBOutlet weak var pollURLView: UIView!
    @IBOutlet weak var pollURLStaticLabel: ArcLabel!
    @IBOutlet weak var pollURLButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollURLButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollURLButton.state = .On
            pollURLButton.color = color
            pollURLButton.category = .Hyperlink
        }
    }
    @IBOutlet weak var pollURLBg: UIView!
    @IBOutlet weak var pollURLContainerView: UIView! {
        didSet {
            pollURLContainerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var pollURLTextField: InsetTextField! {
        didSet {
            pollURLTextField.delegate = self
            pollURLTextField.placeholder = "url_placeholder".localized
            pollURLTextField.textColor = .systemBlue
        }
    }
    @IBOutlet weak var pollURLSkip: UIImageView! {
        didSet {
            pollURLSkip.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollURLSkip.addGestureRecognizer(tap)
            pollURLSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    
    
    ///Poll images
    @IBOutlet weak var pollImagesView: UIView!
    @IBOutlet weak var pollImagesStaticLabel: ArcLabel!
    @IBOutlet weak var pollImagesButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollImagesButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollImagesButton.state = .On
            pollImagesButton.color = color
            pollImagesButton.category = .Picture
        }
    }
    @IBOutlet weak var pollImagesBg: UIView!
    @IBOutlet weak var pollImagesFg: UIView! {
        didSet {
            pollImagesFg.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    @IBOutlet weak var pollImagesTemp: UIView!
    @IBOutlet weak var pollImagesContainerView: UIView!
    @IBOutlet weak var pollImagesSkip: UIImageView! {
        didSet {
            pollImagesSkip.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollImagesSkip.addGestureRecognizer(tap)
            pollImagesSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
    }
    
    
    ///Poll description
    @IBOutlet weak var pollChoicesView: UIView!
    @IBOutlet weak var pollChoicesStaticLabel: ArcLabel!
    @IBOutlet weak var pollChoicesButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            pollChoicesButton.addGestureRecognizer(tap)
//            optionsButton.icon.alpha = 0
            pollChoicesButton.state = .On
            pollChoicesButton.color = color
            pollChoicesButton.category = .QuestionMark
        }
    }
    @IBOutlet weak var pollChoicesBg: UIView!
    @IBOutlet weak var pollChoicesContainerView: UIView! {
        didSet {
            pollChoicesContainerView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        }
    }
    
    ///Limits
    @IBOutlet weak var limitsView: UIView!
    @IBOutlet weak var limitsStaticLabel: ArcLabel!
    @IBOutlet weak var limitsLabel: ArcLabel!
    @IBOutlet weak var limitsButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            limitsButton.addGestureRecognizer(tap)
//            limitsButton.icon.alpha = 0
            limitsButton.state = .On
            limitsButton.color = color
            limitsButton.text = "РАЗДЕЛ"
            limitsButton.category = .QuestionMark
        }
    }
    
    ///Comments
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsStaticLabel: ArcLabel!
    @IBOutlet weak var commentsLabel: ArcLabel!
    @IBOutlet weak var commentsButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            commentsButton.addGestureRecognizer(tap)
//            topicButton.icon.alpha = 0
            commentsButton.state = .On
            commentsButton.color = color
            commentsButton.text = "РАЗДЕЛ"
            commentsButton.category = .QuestionMark
        }
    }
    
    ///Hot option
    @IBOutlet weak var hotOptionView: UIView!
    @IBOutlet weak var hotOptionStaticLabel: ArcLabel!
    @IBOutlet weak var hotOptionLabel: ArcLabel!
    @IBOutlet weak var hotOptionButton: CircleButton! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            hotOptionButton.addGestureRecognizer(tap)
//            topicButton.icon.alpha = 0
            hotOptionButton.state = .On
            hotOptionButton.color = color
            hotOptionButton.text = "РАЗДЕЛ"
            hotOptionButton.category = .QuestionMark
        }
    }
}

// MARK: - Controller Output
extension PollCreationView: PollCreationControllerOutput {
    func onNextStage(_ stage: PollCreationController.Stage) {
        func animate(button: CircleButton, completionBlocks: [Closure]) {
            button.present(completionBlocks: completionBlocks)
            button.superview!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: 0.2) {
                button.superview!.alpha = 1
            }
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.55,
                initialSpringVelocity: 2.5,
                options: [.curveEaseInOut],
                animations: {
                    button.superview!.transform = .identity
                }) { _ in }
        }
        
        func animateTransition(lineStart: CGPoint, lineEnd: CGPoint, lineCompletionBlocks: [Closure], animationBlocks animations: [Closure], completionBlocks completion: [Closure], animationDuration: TimeInterval = 0) {
            let line     = drawLine(fromPoint: lineStart, endPoint: lineEnd, lineCap: .round)
            let lineAnim = getLineAnimation(line: line, duration: animationDuration)
            let duration = animationDuration
            
            scrollContentView.layer.insertSublayer(line.layer, at: 0)
//            lineAnim.delegate = self
            lineAnim.setValue(lineCompletionBlocks, forKey: "completionBlocks")
            line.layer.add(lineAnim, forKey: "animEnd")
            
            UIView.animate(withDuration: duration, delay: lineAnimationDuration , options: [.curveEaseInOut], animations:
                {
                    DispatchQueue.main.async {
                        animations.forEach { $0() }
                    }
            }) {
                _ in
                DispatchQueue.main.async {
                    completion.forEach { $0() }
                }
            }
            line.layer.strokeEnd = 1
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
            line.layer.strokeColor = color.withAlphaComponent(0.3).cgColor//K_COLOR_RED.withAlphaComponent(0.1).cgColor
            line.layer.lineCap = lineCap
            
            line.layer.path = path.cgPath
            lines.append(line)
            return line
        }
        
        func getLineAnimation(line: Line, duration: TimeInterval = 0) -> CAAnimationGroup {
            let strokeEndAnimation      = CABasicAnimation(path: #keyPath(CAShapeLayer.strokeEnd), fromValue: line.layer.strokeEnd, toValue: 1, duration: duration == 0 ? lineAnimationDuration : duration)
            //            let strokeWidthAnimation    = CAKeyframeAnimation(keyPath:"lineWidth")
            //            strokeWidthAnimation.values   = [lineWidth * 2, lineWidth]
            //            strokeWidthAnimation.keyTimes = [0, 1]
            //            strokeWidthAnimation.duration = lineAnimationDuration
            //            let pathFillColorAnim      = CAKeyframeAnimation(keyPath:"strokeColor")
            //            pathFillColorAnim.values   = [selectedColor.withAlphaComponent(0.8).cgColor, selectedColor.withAlphaComponent(0.3).cgColor]
            //            pathFillColorAnim.keyTimes = [0, 1]
            //            pathFillColorAnim.duration = lineAnimationDuration
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = [strokeEndAnimation]//, strokeWidthAnimation, pathFillColorAnim]
            groupAnimation.duration = duration == 0 ? lineAnimationDuration : duration
            
            return groupAnimation
        }
        
        func scrollToPoint(y: CGFloat, duration: TimeInterval = 0.5, delay: TimeInterval = 0, completionBlocks: [Closure]) {
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut], animations: {
                self.scrollView.contentOffset.y = y
            }) {
                _ in
                completionBlocks.forEach({ $0() })
            }
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
        
        switch stage {
        case .Topic:
            animate(button: topicButton, completionBlocks: [
                { [weak self] in guard let self = self else { return }; self.topicButton.state = .On},
                { [weak self] in guard let self = self else { return }
                    let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
                    if #available(iOS 14, *) {
                        banner.present(subview: TopicSelectionModernCollectionView(callbackDelegate: banner))
                    } else {
                        banner.present(subview: TopicSelection(isModal: true, callbackDelegate: banner))
                    }
                }
            ])
            
        case .Options:
            animate(button: optionsButton, completionBlocks: [
                { [weak self] in guard let self = self else { return }; self.optionsButton.state = .On},
                { [weak self] in guard let self = self else { return }; let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
                    banner.present(subview: OptionSelection(isModal: true, option: .Ordinary, callbackDelegate: banner))}
            ])
            var startPoint = topicView.superview!.convert(topicView.center, to: scrollContentView)
            startPoint.y += (topicView.bounds.height + lineWidth)/2//delta
            var endPoint = optionsView.superview!.convert(optionsView.center, to: scrollContentView)
            endPoint.y -= (optionsStaticLabel.bounds.height + lineWidth)/2//delta
            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Title:
            let scrollPoint = pollTitleView.superview!.convert(pollTitleView.frame.origin, to: scrollContentView)
            scrollToPoint(y: scrollPoint.y - 30, completionBlocks: [
                {
                    [weak self] in guard let self = self else { return }
                    animate(button: self.pollTitleButton, completionBlocks: [
                        
                    ])
                },
                {
                    [weak self] in guard let self = self else { return }
                    reveal(view: self.pollTitleBg, duration: 0.3, completionBlocks: [
                        {
                            [weak self] in guard let self = self else { return }
                            self.pollTitleTextView.becomeFirstResponder()
                        }
                    ])
                }
            ])
            
            var startPoint = optionsView.superview!.convert(optionsView.center, to: scrollContentView)
            startPoint.y += (optionsView.bounds.height + lineWidth)/2
            var endPoint = pollTitleView.superview!.convert(pollTitleView.center, to: scrollContentView)
            endPoint.y -= (pollTitleStaticLabel.bounds.height + lineWidth)/2
            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Description:
            let scrollPoint = pollDescriptionView.superview!.convert(pollDescriptionView.frame.origin, to: scrollContentView)
            scrollToPoint(y: scrollPoint.y - 30, completionBlocks: [
                {
                    [weak self] in guard let self = self else { return }
                    animate(button: self.pollDescriptionButton, completionBlocks: [
                        
                    ])
                },
                {
                    [weak self] in guard let self = self else { return }
                    reveal(view: self.pollDescriptionBg, duration: 0.3, completionBlocks: [
                        {
                            [weak self] in guard let self = self else { return }
                            self.pollDescriptionTextView.becomeFirstResponder()
                        }
                    ])
                }

            ])
            
            var startPoint = pollTitleBg.superview!.convert(pollTitleBg.center, to: scrollContentView)
            startPoint.y += (pollTitleBg.bounds.height + lineWidth + 30)/2
            var endPoint = pollDescriptionView.superview!.convert(pollDescriptionView.center, to: scrollContentView)
            endPoint.y -= (pollDescriptionStaticLabel.bounds.height + lineWidth)/2
            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Question:
            let scrollPoint = pollQuestionView.superview!.convert(pollQuestionView.frame.origin, to: scrollContentView)
            scrollToPoint(y: scrollPoint.y - 30, completionBlocks: [
                {
                    [weak self] in guard let self = self else { return }
                    animate(button: self.pollQuestionButton, completionBlocks: [
                        
                    ])
                },
                {
                    [weak self] in guard let self = self else { return }
                    reveal(view: self.pollQuestionBg, duration: 0.3, completionBlocks: [
                        {
                            [weak self] in guard let self = self else { return }
                            self.pollQuestionTextView.becomeFirstResponder()
                        }
                    ])
                }
            ])
            
            var startPoint = pollDescriptionBg.superview!.convert(pollDescriptionBg.center, to: scrollContentView)
            startPoint.y += (pollDescriptionBg.bounds.height + lineWidth + 30)/2
            var endPoint = pollQuestionView.superview!.convert(pollQuestionView.center, to: scrollContentView)
            endPoint.y -= (pollDescriptionStaticLabel.bounds.height + lineWidth)/2
            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Hyperlink:
            let scrollPoint = pollURLView.superview!.convert(pollURLView.frame.origin, to: scrollContentView)
            scrollToPoint(y: scrollPoint.y - 30, completionBlocks: [
                {
                    [weak self] in guard let self = self else { return }
                    animate(button: self.pollURLButton, completionBlocks: [
//                        {
//                            [weak self] in guard let self = self else { return }
//                            reveal(view: self.pollURLBg, duration: 0.2, completionBlocks: [])
//                        }
                    ])
                },
                {
                    [weak self] in guard let self = self else { return }
                    reveal(view: self.pollURLBg, duration: 0.3, completionBlocks: [
                        {
                            [weak self] in guard let self = self else { return }
                            self.pollURLTextField.becomeFirstResponder()
                        }
                    ])
                }
            ])
            
            var startPoint = pollQuestionBg.superview!.convert(pollQuestionBg.center, to: scrollContentView)
            startPoint.y += (pollQuestionBg.bounds.height + lineWidth + 30)/2
            var endPoint = pollURLView.superview!.convert(pollURLView.center, to: scrollContentView)
            endPoint.y -= (pollURLStaticLabel.bounds.height + lineWidth)/2
            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Images:
            let scrollPoint = pollImagesView.superview!.convert(pollImagesView.frame.origin, to: scrollContentView)
            scrollToPoint(y: scrollPoint.y - 30, completionBlocks: [
                {
                    [weak self] in guard let self = self else { return }
                    animate(button: self.pollImagesButton, completionBlocks: [
                        {
//                            [weak self] in guard let self = self else { return }
//                            reveal(view: self.pollImagesBg, duration: 0.2, completionBlocks: [])
                        }
                    ])
                },
                {
                    [weak self] in guard let self = self else { return }
                    reveal(view: self.pollImagesBg, duration: 0.3, completionBlocks: [])
                }
            ])
            
            var startPoint = pollURLBg.superview!.convert(pollURLBg.center, to: scrollContentView)
            startPoint.y += (pollURLBg.bounds.height + lineWidth + 30)/2
            var endPoint = pollImagesView.superview!.convert(pollImagesView.center, to: scrollContentView)
            endPoint.y -= (pollImagesStaticLabel.bounds.height + lineWidth)/2
            animateTransition(lineStart: startPoint, lineEnd: endPoint, lineCompletionBlocks: [], animationBlocks: [], completionBlocks: [])
        case .Ready:
            scrollView.isScrollEnabled = true
        default:
            fatalError()
        }
        
    }
    
    
    // Implement methods
    
}

// MARK: - UI Setup
extension PollCreationView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        pollTitleBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        pollTitleTextView.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        
        scrollContentView.get(all: [UITextView.self]).forEach {
            guard let v =  $0 as? UITextView else { return }
            v.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        }
        pollURLSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
        pollImagesSkip.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : color
    }
    
    private func setupUI() {
        setNeedsLayout()
        layoutIfNeeded()
        setText()
        setupInputViews()
        
        scrollContentView.subviews.forEach {
            $0.alpha = 0
            if let circle = $0 as? CircleButton { circle.state = .Off }
        }
        
        lineWidth = topicButton.lineWidth
        pollTitleTextView.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Bold,
                                                       size: pollTitleTextView.frame.width * 0.1)
        pollDescriptionTextView.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular,
                                                             size: pollDescriptionTextView.frame.width * 0.05)
        pollQuestionTextView.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Semibold,
                                                       size: pollQuestionTextView.frame.width * 0.075)
        pollURLTextField.font = StringAttributes.font(name: StringAttributes.Fonts.Style.Regular,
                                                       size: pollURLTextField.frame.height * 0.35)
        pollURLTextField.cornerRadius = pollURLTextField.frame.height / 2
        
        ///Disable till all stages are completed
        scrollView.isScrollEnabled = false
        if #available(iOS 14, *) {
            imagesContainer = ImageSelectionCollectionView(dataProvider: self, callbackDelegate: self, color: color)
            imagesContainer.addEquallyTo(to: pollImagesContainerView)
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func setObservers() {
        observers.append(pollTitleBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollTitleBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollTitleBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollTitleBg.bounds,
                                                             cornerRadius: self.pollTitleBg.frame.width * 0.05).cgPath
            self.pollTitleBg.layer.shadowRadius = 7
            self.pollTitleBg.layer.shadowOffset = .zero
        })
        observers.append(pollDescriptionBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollDescriptionBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollDescriptionBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollDescriptionBg.bounds,
                                                             cornerRadius: self.pollDescriptionBg.frame.width * 0.05).cgPath
            self.pollDescriptionBg.layer.shadowRadius = 7
            self.pollDescriptionBg.layer.shadowOffset = .zero
        })
        observers.append(pollQuestionBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollQuestionBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollQuestionBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollQuestionBg.bounds,
                                                             cornerRadius: self.pollQuestionBg.frame.width * 0.05).cgPath
            self.pollQuestionBg.layer.shadowRadius = 7
            self.pollQuestionBg.layer.shadowOffset = .zero
        })
        observers.append(pollURLBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollURLBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollURLBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollURLBg.bounds,
                                                             cornerRadius: self.pollURLBg.frame.width * 0.05).cgPath
            self.pollURLBg.layer.shadowRadius = 7
            self.pollURLBg.layer.shadowOffset = .zero
        })
        observers.append(pollImagesBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollImagesBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollImagesBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollImagesBg.bounds,
                                                              cornerRadius: self.pollImagesBg.frame.width * 0.05).cgPath
            self.pollImagesBg.layer.shadowRadius = 7
            self.pollImagesBg.layer.shadowOffset = .zero
        })
        observers.append(pollChoicesBg.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollChoicesBg.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.pollChoicesBg.layer.shadowPath = UIBezierPath(roundedRect: self.pollChoicesBg.bounds,
                                                               cornerRadius: self.pollChoicesBg.frame.width * 0.05).cgPath
            self.pollChoicesBg.layer.shadowRadius = 7
            self.pollChoicesBg.layer.shadowOffset = .zero
        })
        observers.append(pollURLTextField.observe(\InsetTextField.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            self.pollURLTextField.cornerRadius = self.pollURLTextField.frame.height / 2
        })
        observers.append(pollImagesTemp.observe(\UIView.bounds, options: [NSKeyValueObservingOptions.new]) { (view: UIView, change: NSKeyValueObservedChange<CGRect>) in
            guard let constraint = self.pollImagesTemp.getAllConstraints().filter({ $0.identifier == "height" }).first,
            let value = change.newValue else { return }
            self.pollImagesTemp.removeConstraint(constraint)
            let newConstraint = self.pollImagesTemp.heightAnchor.constraint(equalToConstant: value.height)
            newConstraint.identifier = "height"
            newConstraint.isActive = true
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    private func setupInputViews() {
        pollTitleTextView.layer.masksToBounds = true
        pollTitleTextView.layer.cornerRadius = pollTitleTextView.frame.width * 0.05
        pollTitleBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollDescriptionTextView.layer.masksToBounds = true
        pollDescriptionTextView.layer.cornerRadius = pollDescriptionTextView.frame.width * 0.05
        pollDescriptionBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollQuestionTextView.layer.masksToBounds = true
        pollQuestionTextView.layer.cornerRadius = pollQuestionTextView.frame.width * 0.05
        pollQuestionBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollURLContainerView.layer.masksToBounds = true
        pollURLContainerView.layer.cornerRadius = pollURLContainerView.frame.width * 0.05
        pollURLBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollImagesFg.layer.masksToBounds = true
        pollImagesFg.layer.cornerRadius = pollImagesContainerView.frame.width * 0.05
        pollImagesBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
        pollChoicesContainerView.layer.masksToBounds = true
        pollChoicesContainerView.layer.cornerRadius = pollChoicesContainerView.frame.width * 0.05
        pollChoicesBg.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        
    }
    
    @objc
    private func setText() {
        if fontSize == .zero { fontSize = topicStaticLabel.bounds.width * 0.1 }
        
        ///Topic
        let topicStaticString = NSMutableAttributedString()
        topicStaticString.append(NSAttributedString(string: "topic".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicStaticLabel.attributedText = topicStaticString
        
        let topicString = NSMutableAttributedString()
        topicString.append(NSAttributedString(string: topic.isNil ? "" : topic.title.localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label/*color*/, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        topicLabel.attributedText = topicString
        
        ///Options
        let optionsStaticString = NSMutableAttributedString()
        optionsStaticString.append(NSAttributedString(string: "options".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        optionsStaticLabel.attributedText = optionsStaticString
        
        let optionsString = NSMutableAttributedString()
        optionsString.append(NSAttributedString(string: option.rawValue.localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        optionsLabel.attributedText = optionsString
        
        ///Poll title
        let pollTitleStaticString = NSMutableAttributedString()
        pollTitleStaticString.append(NSAttributedString(string: "poll_title".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollTitleStaticLabel.attributedText = pollTitleStaticString
        
        ///Poll description
        let pollDescriptionStaticString = NSMutableAttributedString()
        pollDescriptionStaticString.append(NSAttributedString(string: "poll_description".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollDescriptionStaticLabel.attributedText = pollDescriptionStaticString
        
        ///Poll Question
        let pollQuestionStaticString = NSMutableAttributedString()
        pollQuestionStaticString.append(NSAttributedString(string: "poll_question".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollQuestionStaticLabel.attributedText = pollQuestionStaticString
        
        ///Poll URL
        let pollURLStaticString = NSMutableAttributedString()
        pollURLStaticString.append(NSAttributedString(string: "url".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: .label, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollURLStaticLabel.attributedText = pollURLStaticString
        
        ///Poll Images
        let pollImagesStaticString = NSMutableAttributedString()
        pollImagesStaticString.append(NSAttributedString(string: "images".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollImagesStaticLabel.attributedText = pollImagesStaticString
        
        ///Poll choices
        let pollChoicesStaticString = NSMutableAttributedString()
        pollChoicesStaticString.append(NSAttributedString(string: "poll_choices".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollChoicesStaticLabel.attributedText = pollChoicesStaticString
        
        ///Commenta
        let commentsStaticString = NSMutableAttributedString()
        commentsStaticString.append(NSAttributedString(string: "comments".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        commentsStaticLabel.attributedText = commentsStaticString
        
        let commentsString = NSMutableAttributedString()
        commentsString.append(NSAttributedString(string: "comments".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        commentsLabel.attributedText = commentsString
        
        ///Limits
        let limitsStaticString = NSMutableAttributedString()
        limitsStaticString.append(NSAttributedString(string: "voters_limit".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        limitsStaticLabel.attributedText = limitsStaticString
        
        let limitsString = NSMutableAttributedString()
        limitsString.append(NSAttributedString(string: "voters_limit".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        limitsLabel.attributedText = limitsString
        
        ///Hot start
        let hotOptionStaticString = NSMutableAttributedString()
        hotOptionStaticString.append(NSAttributedString(string: "hot_option".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        hotOptionStaticLabel.attributedText = hotOptionStaticString
        
        let hotOptionString = NSMutableAttributedString()
        hotOptionString.append(NSAttributedString(string: "hot_option".localized.uppercased(), attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Bold, size: fontSize), foregroundColor: traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : color, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        hotOptionLabel.attributedText = hotOptionString
        
        let urlPlaceholder = NSMutableAttributedString()
        urlPlaceholder.append(NSAttributedString(string: "url_placeholder".localized, attributes: StringAttributes.getAttributes(font: StringAttributes.font(name: StringAttributes.Fonts.Style.Regular, size: pollURLTextField.frame.height * 0.35), foregroundColor: .secondaryLabel, backgroundColor: .clear) as [NSAttributedString.Key : Any]))
        pollURLTextField.attributedPlaceholder = urlPlaceholder
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let v = recognizer.view else { return }
        if v == pollURLSkip, pollURLTextField.isFirstResponder {
            pollURLTextField.resignFirstResponder()
        } else if v == pollImagesSkip {
            guard let constraint = self.pollImagesTemp.getAllConstraints().filter({ $0.identifier == "height" }).first else { return }
            UIView.animate(withDuration: 0.25, animations: {
                self.pollImagesFg.setNeedsLayout()
                constraint.constant = 0
                self.pollImagesFg.layoutIfNeeded()
                self.pollImagesTemp.alpha = 0
//                self.pollImagesTemp.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }) { _ in
                //self.viewInput?.onStageCompleted()
            }
        }
    }
    
    @objc private func keyboardDidHide() {
        if let recognizer = gestureRecognizers?.filter({ $0.accessibilityValue == "hideKeyboard" }).first {
            gestureRecognizers?.remove(object: recognizer)
        }
    }
    
    @objc private func keyboardDidShow() {
        guard gestureRecognizers.isNil || gestureRecognizers!.filter({ $0.accessibilityValue == "hideKeyboard" }).isEmpty else { return }
        let touch = UITapGestureRecognizer(target:self, action: #selector(self.hideKeyboard))
        touch.accessibilityValue = "hideKeyboard"
        self.addGestureRecognizer(touch)
    }
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
}

extension PollCreationView: BannerObservable {
    func onBannerWillAppear(_ sender: Any) {}
    
    func onBannerWillDisappear(_ sender: Any) {}
    
    func onBannerDidAppear(_ sender: Any) {}
    
    func onBannerDidDisappear(_ sender: Any) {
        if let banner = sender as? Banner {
            if banner.accessibilityIdentifier == "isTextFieldEditingEnabled" {
                isTextFieldEditingEnabled = true
            }
            banner.removeFromSuperview()
        } else if let popup = sender as? Popup {
            popup.removeFromSuperview()
        }
    }
}

extension PollCreationView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let _topic = sender as? Topic {
            topic = _topic
        } else if let _option = sender as? PollCreationController.Option {
            option = _option
        } else if let imageItem = sender as? ImageItem {
            if let _existing = imageItems.filter({ $0.id == imageItem.id }).first {
                var existing = _existing
                guard imageItem.shouldBeDeleted else {
                    guard let index = imageItems.firstIndex(where: {$0.id == imageItem.id}) else { return }
                    imageItems[index].image = imageItem.image
                    imageItems[index].title = imageItem.title
                    imagesContainer.reload()
                    return
                }
                guard let index = imageItems.firstIndex(where: {$0.id == imageItem.id}) else { return }
                imageItems.remove(at: index)
                imagesContainer.delete(imageItem)
            } else {
                imageItems.append(imageItem)
                imagesContainer.append(imageItem)
            }
        }
    }
}

extension PollCreationView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach { $0() }
        } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
            completionBlocks.forEach { $0() }
        } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
            initialLayer.path = path as! CGPath
            if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
                completionBlock()
            }
        }
    }
}

extension PollCreationView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard isTextFieldEditingEnabled else { return false }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        var maxCharacters: Int = .max
                
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if textView === pollTitleTextView {
            maxCharacters = ModelProperties.shared.surveyTitleMaxLength
        } else if textView === pollDescriptionTextView {
            maxCharacters = ModelProperties.shared.surveyDescriptionMaxLength
        } else if textView === pollQuestionTextView {
            maxCharacters = ModelProperties.shared.surveyQuestionMaxLength
        }
        

        if updatedText.count > maxCharacters {
            if isTextFieldEditingEnabled {
                showBanner(bannerDelegate: self,
                           text: AppError.maximumCharactersExceeded(maxValue: maxCharacters).localizedDescription,
                           imageContent: ImageSigns.exclamationMark,
                           shouldDismissAfter: 0.5,
                           accessibilityIdentifier: "isTextFieldEditingEnabled")
                isTextFieldEditingEnabled = false
            }
        }
        return updatedText.count <= maxCharacters
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == pollTitleTextView {//|| textView == pollQuestionTextView {
            let space = textView.bounds.size.height - textView.contentSize.height
            let inset = max(0, space/2)
            textView.contentInset = UIEdgeInsets(top: inset, left: textView.contentInset.left, bottom: inset, right: textView.contentInset.right)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == pollTitleTextView {
            let space = textView.bounds.size.height - textView.contentSize.height
            let inset = max(0, space/2)
            textView.contentInset = UIEdgeInsets(top: inset, left: textView.contentInset.left, bottom: inset, right: textView.contentInset.right)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        var minCharacters = 0
        if textView === pollTitleTextView {
            minCharacters = ModelProperties.shared.surveyTitleMinLength
        } else if textView === pollDescriptionTextView {
            minCharacters = ModelProperties.shared.surveyDescriptionMinLength
        } else if textView === pollQuestionTextView {
            minCharacters = ModelProperties.shared.surveyQuestionMinLength
        }
        
        if textView.text.count < minCharacters {
            showBanner(bannerDelegate: self,
                       text: AppError.minimumCharactersExceeded(minValue: minCharacters).localizedDescription,
                       imageContent: ImageSigns.exclamationMark,
                       shouldDismissAfter: 0.5,
                       accessibilityIdentifier: "isTextFieldEditingEnabled")
            isTextFieldEditingEnabled = false
            return false
        }
        viewInput?.onStageCompleted()
        return true
    }
}

extension PollCreationView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard isTextFieldEditingEnabled else { return false }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === pollURLTextField, let text = textField.text {
            if !text.isEmpty {
                guard !text.isValidURL, isTextFieldEditingEnabled else {
                    pollURLTextField.resignFirstResponder()
                    UIView.animate(withDuration: 0.15) {
                        self.pollURLSkip.alpha = 0
                        self.pollURLSkip.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    }
                    viewInput?.onStageCompleted()
                    return true
                }
                showBanner(bannerDelegate: self,
                           text: AppError.invalidURL.localizedDescription,
                           imageContent: ImageSigns.exclamationMark,
                           shouldDismissAfter: 0.5,
                           accessibilityIdentifier: "isTextFieldEditingEnabled")
                isTextFieldEditingEnabled = false
                return false
            } else {
                pollURLTextField.resignFirstResponder()
                UIView.animate(withDuration: 0.15) {
                    self.pollURLSkip.alpha = 0
                    self.pollURLSkip.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                }
                viewInput?.onStageCompleted()
                return true
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField === pollURLTextField, let text = textField.text {
            if !text.isEmpty {
                guard !text.isValidURL, isTextFieldEditingEnabled else {
                    pollURLTextField.resignFirstResponder()
                    UIView.animate(withDuration: 0.15) {
                        self.pollURLSkip.alpha = 0
                        self.pollURLSkip.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    }
                    viewInput?.onStageCompleted()
                    return true
                }
                showBanner(bannerDelegate: self,
                           text: AppError.invalidURL.localizedDescription,
                           imageContent: ImageSigns.exclamationMark,
                           shouldDismissAfter: 0.5,
                           accessibilityIdentifier: "isTextFieldEditingEnabled")
                isTextFieldEditingEnabled = false
                return false
            } else {
                pollURLTextField.resignFirstResponder()
                UIView.animate(withDuration: 0.15) {
                    self.pollURLSkip.alpha = 0
                    self.pollURLSkip.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                }
                viewInput?.onStageCompleted()
                return true
            }
        }
        return true
    }
}

extension PollCreationView: ImageSelectionListener {
    func addImage() {
        guard imageItems.count < 3 else {
            showBanner(bannerDelegate: self,
                       text: AppError.maximumImages.localizedDescription,
                       imageContent: ImageSigns.exclamationMark,
                       shouldDismissAfter: 0.5)
            return
        }
        let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
        banner.present(subview: ImageSelectionPopup(controller: viewInput as? UIViewController, callbackDelegate: banner))
    }
    
    func deleteImage(_ imageItem: ImageItem) {
        imageItems.remove(object: imageItem)
    }
    
    func editImage(_ item: ImageItem) {
        let banner = Popup(frame: UIScreen.main.bounds, callbackDelegate: self, bannerDelegate: self, heightScaleFactor: deviceType == .iPhoneSE ? 0.8 : 0.6)
        banner.present(subview: ImageSelectionPopup(controller: viewInput as? UIViewController, callbackDelegate: banner, item: item))
    }
}

