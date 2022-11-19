//
//  TopicsView.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TopicsView: UIView {
    
    // MARK: - Public properties
    weak var viewInput: (TopicsViewInput & UIViewController)?
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Logic
    private lazy var surveysCollectionView: SurveysCollectionView = {
        let instance = SurveysCollectionView(category: .Search)
        instance.alpha = 0
        return instance
    }()
    private var touchLocation: CGPoint = .zero
    private lazy var collectionView: TopicsCollectionView = {
        let instance = TopicsCollectionView(callbackDelegate: self)
        
        instance.touchSubject.sink { [weak self] in
            guard let self = self,
                  let dict = $0,
                  let point = dict.values.first,
                  let topic = dict.keys.first
            else { return }
            
            self.viewInput?.onTopicSelected(topic)
            self.viewInput?.setNavigationBarTintColor(topic.tagColor)
            self.touchLocation = point
            self.surveysCollectionView.topic = topic
            self.surveysCollectionView.alpha = 1
            self.surveysCollectionView.backgroundColor = self.background.backgroundColor
            self.reveal(present: true, location: point, view: self.surveysCollectionView, fadeView: self.collectionView, duration: 0.4)//, animateOpacity: false)
        }.store(in: &subscriptions)
        
        return instance
    }()
    private lazy var background: UIView = {
        let instance = UIView()
        instance.accessibilityIdentifier = "bg"
        instance.layer.masksToBounds = true
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.cornerRadius = rect.width * 0.05
            }
            .store(in: &subscriptions)
        
        collectionView.addEquallyTo(to: instance)
        surveysCollectionView.addEquallyTo(to: instance)
        
        return instance
    }()
    private lazy var shadowView: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        instance.layer.shadowRadius = 5
        instance.layer.shadowOffset = .zero
        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.width*0.05).cgPath
            }
            .store(in: &subscriptions
            )
        background.place(inside: instance)
        
        return instance
    }()
    
    
    
    // MARK: - IB outlets
    @IBOutlet var contentView: UIView!
    
    // MARK: - Destructor
    deinit {
        observers.forEach { $0.invalidate() }
        tasks.forEach { $0?.cancel() }
        subscriptions.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
#if DEBUG
        print("\(String(describing: type(of: self))).\(#function)")
#endif
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    // MARK: - Private methods
    private func setupUI() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        
        let zeroSized = UIView()
        zeroSized.backgroundColor = .clear
        zeroSized.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        addSubview(contentView)
        contentView.addSubview(zeroSized)
        contentView.addSubview(shadowView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        zeroSized.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            zeroSized.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            zeroSized.topAnchor.constraint(equalTo: contentView.topAnchor),
            zeroSized.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            shadowView.topAnchor.constraint(equalTo: zeroSized.bottomAnchor, constant: 10),
            shadowView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            shadowView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            shadowView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }
   
    func reveal(present: Bool, location: CGPoint = .zero, view revealView: UIView, fadeView: UIView, duration: TimeInterval, animateOpacity: Bool = true) {

        let circlePathLayer = CAShapeLayer()

        var circleFrameTouchPosition: CGRect {
            return CGRect(origin: location, size: .zero)
        }

        var circleFrameTopLeft: CGRect {
            return CGRect.zero
        }

        func circlePath(_ rect: CGRect) -> UIBezierPath {
            return UIBezierPath(ovalIn: rect)
        }

        circlePathLayer.frame = revealView.bounds
        circlePathLayer.path = circlePath(location == .zero ? circleFrameTopLeft : circleFrameTouchPosition).cgPath
        revealView.layer.mask = circlePathLayer

        let radiusInset =  sqrt(revealView.bounds.height*revealView.bounds.height + revealView.bounds.width*revealView.bounds.width + location.x*location.x + location.y*location.y)

        let outerRect = circleFrameTouchPosition.insetBy(dx: -radiusInset, dy: -radiusInset)

        let toPath = UIBezierPath(ovalIn: outerRect).cgPath

        let fromPath = circlePathLayer.path

        let anim = Animations.get(property: .Path, fromValue: present ? fromPath as Any : toPath, toValue: !present ? fromPath as Any : toPath, duration: duration, delay: 0, repeatCount: 0, autoreverses: false, timingFunction: present ? .easeInEaseOut : .easeOut, delegate: self, isRemovedOnCompletion: true, completionBlocks: [{
            revealView.layer.mask = nil
            if !present {
//                circlePathLayer.path = CGPath(rect: .zero, transform: nil)
                revealView.layer.opacity = 0
//////                animatedView.alpha = 0
////                            animatedView.layer.mask = nil
            }
        }])

        circlePathLayer.add(anim, forKey: "path")
        circlePathLayer.path = !present ? fromPath : toPath
        
        let grayLayer = CALayer()
        grayLayer.frame = fadeView.layer.bounds
        grayLayer.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.black.cgColor : UIColor.systemGray.cgColor
        grayLayer.opacity = present ? 0 : 1
        
        fadeView.layer.addSublayer(grayLayer)
        
        let opacityAnim = Animations.get(property: .Opacity, fromValue: present ? 0 : 1, toValue: present ? 1 : 0, duration: duration, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, completionBlocks: [{
            grayLayer.removeFromSuperlayer()
        }])
        grayLayer.add(opacityAnim, forKey: nil)
        grayLayer.opacity = !present ? 0 : 1
    }
    
    // MARK: - Overrriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionView.backgroundColor = .clear
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
}

// MARK: - Controller Output
extension TopicsView: TopicsControllerOutput {
    func beginSearchRefreshing() {
        surveysCollectionView.beginSearchRefreshing()
    }
    
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        surveysCollectionView.endRefreshing()
    }
    
//    func onTopicMode(_ instance: Topic) {
//        surveysCollectionView.topic = instance
//        surveysCollectionView.alpha = 1
//        surveysCollectionView.backgroundColor = background.backgroundColor
//        reveal(view: surveysCollectionView, duration: 0.3)
//    }
    
    func onDefaultMode() {
        surveysCollectionView.alpha = 1
        collectionView.backgroundColor = background.backgroundColor
        reveal(present: false, location: touchLocation, view: surveysCollectionView, fadeView: collectionView, duration: 0.35)
    }
    
    func onSearchMode() {
        surveysCollectionView.category = .Search
        surveysCollectionView.alpha = 1
//        surveysCollectionView.layer.mask = nil
        surveysCollectionView.backgroundColor = background.backgroundColor
        touchLocation = CGPoint(x: bounds.maxX, y: bounds.minY)
        reveal(present: true, location: touchLocation, view: surveysCollectionView, fadeView: collectionView, duration: 0.4)
    }
    
    func onSearchCompleted(_ instances: [SurveyReference]) {
        surveysCollectionView.endSearchRefreshing()
        surveysCollectionView.fetchResult = instances
    }
}

// MARK: - CallbackObservable
extension TopicsView: CallbackObservable {
    func callbackReceived(_ sender: Any) {
        if let instance = sender as? Topic {
            viewInput?.onTopicSelected(instance)
        } else if sender is SurveysCollectionView {
            viewInput?.onDataSourceRequest()
        } else if let instance = sender as? SurveyReference {
            viewInput?.onSurveyTapped(instance)
        }
    }
}

extension TopicsView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let completionBlocks = anim.value(forKey: "completionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        } else if let completionBlocks = anim.value(forKey: "maskCompletionBlocks") as? [Closure] {
            completionBlocks.forEach{ $0() }
        } else if let initialLayer = anim.value(forKey: "layer") as? CAShapeLayer, let path = anim.value(forKey: "destinationPath") {
            initialLayer.path = path as! CGPath
            if let completionBlock = anim.value(forKey: "completionBlock") as? Closure {
                completionBlock()
            }
        }
    }
}
