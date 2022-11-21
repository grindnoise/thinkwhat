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
    //UI
    private lazy var filterView: UIView = {
       let instance = UIView()
        instance.backgroundColor = .clear
//        instance.alpha = 0
//        instance.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            periodButton
        ])
        stack.axis = .horizontal
        stack.spacing = 4
        
        instance.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: instance.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: instance.centerYAnchor),
        ])
        
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
//        constraint.identifier = "height"
//        constraint.isActive = true
        
        return instance
    }()
    private lazy var titleLabel: UILabel = {
       let instance = UILabel()
        instance.numberOfLines = 1
        instance.textAlignment = .center
        instance.numberOfLines = 1
        instance.text = "publications".localized.capitalized
        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .label : .darkGray
        instance.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Bold.rawValue, forTextStyle: .title3)
        instance.adjustsFontSizeToFitWidth = true
        
        let constraint = instance.widthAnchor.constraint(equalToConstant: instance.text!.width(withConstrainedHeight: 100, font: instance.font))
        constraint.identifier = "width"
        constraint.isActive = true
        
        return instance
    }()
    private lazy var periodButton: UIButton = {
        let instance = UIButton()
        instance.titleLabel?.numberOfLines = 1
        instance.showsMenuAsPrimaryAction = true
        instance.menu = prepareMenu()
        
        if #available(iOS 15, *) {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .medium
            config.image = UIImage(systemName: "chevron.down.square.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
            config.imagePlacement = .trailing
            config.imagePadding = 4
            config.contentInsets.leading = 4
            config.contentInsets.trailing = 4
            config.contentInsets.top = 0
            config.contentInsets.bottom = 0
            config.title = "per_\(period.rawValue.lowercased())".localized.lowercased()
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [weak self] incoming in
                guard let self = self,
                      let viewInput = self.viewInput
                else { return incoming }
                
                var outcoming = incoming
                outcoming.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .title3)
                outcoming.foregroundColor = .systemGray//viewInput.tintColor//UIColor.secondaryLabel
                return outcoming
            }
//            config.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
//                guard let self = self,
//                      let viewIput = self.viewInput
//                else { return .systemGray }
//
//                return viewIput.tintColor
//            }
            config.buttonSize = .large
            config.baseBackgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
            config.baseForegroundColor = .label

            instance.configuration = config
        } else {
            let attrString = NSMutableAttributedString(string: "Мужчина", attributes: [
                NSAttributedString.Key.font: UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .title3) as Any,
                NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel,
            ])
            instance.setAttributedTitle(attrString, for: .normal)
            instance.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            instance.setImage(UIImage(systemName: "chevron.down.square.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
            instance.imageView?.contentMode = .scaleAspectFit
            instance.imageEdgeInsets.left = 10
            instance.imageEdgeInsets.top = 2
            instance.imageEdgeInsets.bottom = 2
            instance.imageEdgeInsets.right = 2
            instance.semanticContentAttribute = .forceRightToLeft
            instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground

            let constraint = instance.widthAnchor.constraint(equalToConstant: "Мужчина".width(withConstrainedHeight: instance.bounds.height, font: UIFont.scaledFont(fontName: Fonts.OpenSans.Semibold.rawValue, forTextStyle: .subheadline)!))
            constraint.identifier = "width"
            constraint.isActive = true
        }
        
        instance.publisher(for: \.bounds, options: .new).sink { rect in
            instance.cornerRadius = rect.height * 0.15
        }.store(in: &subscriptions)
        
        return instance
    }()
    private lazy var surveysCollectionView: SurveysCollectionView = {
        let instance = SurveysCollectionView(category: .Search)
        instance.alpha = 0
        
        instance.scrollPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.toggleDateFilter(on: !$0)
            }
            .store(in: &subscriptions)
        
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
            self.toggleDateFilter(on: true)
            self.setBackgroundColor(self.traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground)
            self.surveysCollectionView.alpha = 1
            self.surveysCollectionView.backgroundColor = self.background.backgroundColor
            self.reveal(present: true, location: point, view: self.surveysCollectionView, color: self.surveysCollectionView.topic!.tagColor, fadeView: self.collectionView, duration: 0.5)//, animateOpacity: false)
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
    private lazy var filterViewHeight: CGFloat = .zero
    //Logic
    private var period: Period = .AllTime {
        didSet {
            guard oldValue != period else { return }
            
            surveysCollectionView.period = period
            
            periodButton.menu = prepareMenu()
        }
    }
    
    
    
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
    
    
    
    // MARK: - Overrriden methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionView.backgroundColor = .clear
        shadowView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        background.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground
    }
}

// MARK: - Private
private extension TopicsView {
    @MainActor
    func setupUI() {
        guard let contentView = self.fromNib() else { fatalError("View could not load from nib") }
        
//        let zeroSized = UIView()
//        zeroSized.backgroundColor = .clear
//        zeroSized.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        addSubview(contentView)
//        contentView.addSubview(zeroSized)
        contentView.addSubview(filterView)
        contentView.addSubview(shadowView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
//        zeroSized.translatesAutoresizingMaskIntoConstraints = false
        filterView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            filterView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            filterView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            filterView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
//            zeroSized.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            zeroSized.topAnchor.constraint(equalTo: contentView.topAnchor),
//            zeroSized.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            shadowView.topAnchor.constraint(equalTo: zeroSized.bottomAnchor, constant: 10),
//            shadowView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 10),
            shadowView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            shadowView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            shadowView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
        
        let topConstraint = shadowView.topAnchor.constraint(equalTo: filterView.bottomAnchor, constant: 0)
        topConstraint.identifier = "top"
        topConstraint.isActive = true
        
        setNeedsLayout()
        layoutIfNeeded()
        filterViewHeight = periodButton.bounds.height
        let constraint = filterView.heightAnchor.constraint(equalToConstant: 0)
        constraint.identifier = "height"
        constraint.isActive = true
        
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
//        constraint.identifier = "height"
//        constraint.isActive = true
        filterView.alpha = 0
        filterView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
    }
   
    func reveal(present: Bool, location: CGPoint = .zero, view revealView: UIView, color: UIColor, fadeView: UIView, duration: TimeInterval, animateOpacity: Bool = true) {

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

        let anim = Animations.get(property: .Path,
                                  fromValue: present ? fromPath as Any : toPath,
                                  toValue: !present ? fromPath as Any : toPath,
                                  duration: duration,
                                  delay: 0,
                                  repeatCount: 0,
                                  autoreverses: false,
                                  timingFunction: present ? .easeInEaseOut : .easeOut,
                                  delegate: self,
                                  isRemovedOnCompletion: true,
                                  completionBlocks: [{
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
        
        let colorLayer = CALayer()
        colorLayer.frame = fadeView.layer.bounds
        colorLayer.backgroundColor = color.cgColor
        colorLayer.opacity = present ? 0 : 1
        
        fadeView.layer.addSublayer(colorLayer)
        
        let opacityAnim = Animations.get(property: .Opacity, fromValue: present ? 0 : 1, toValue: present ? 1 : 0, duration: duration, timingFunction: CAMediaTimingFunctionName.easeInEaseOut, delegate: self, completionBlocks: [{
            colorLayer.removeFromSuperlayer()
        }])
        colorLayer.add(opacityAnim, forKey: nil)
        colorLayer.opacity = !present ? 0 : 1
        
        if #available(iOS 15, *) {
            if !periodButton.configuration.isNil {
                periodButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in return color }
                periodButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outcoming = incoming
                    outcoming.font = UIFont.scaledFont(fontName: Fonts.OpenSans.Regular.rawValue, forTextStyle: .title3)
                    outcoming.foregroundColor = color
                    return outcoming
                }
            }
        } else {
            periodButton.imageView?.tintColor = color
            periodButton.tintColor = color
        }
    }
    
    func setBackgroundColor(_ color: UIColor) {
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self = self else { return }
            
            self.background.backgroundColor = color
        }
    }
    
    @MainActor
    func toggleDateFilter(on: Bool) {
        guard let heightConstraint = filterView.getConstraint(identifier: "height"),
              let topConstraint = filterView.getConstraint(identifier: "top")
        else { return }
        
        setNeedsLayout()
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
        
            self.filterView.alpha = on ? 1 : 0
            self.filterView.transform = on ? .identity : CGAffineTransform(scaleX: 0.75, y: 0.75)
            topConstraint.constant = on ? 10 : 0
            heightConstraint.constant = on ? self.filterViewHeight : 0
            self.layoutIfNeeded()
        }
    }
    
    @MainActor
    func prepareMenu(zeroSubscriptions: Bool = false) -> UIMenu {
        let perDay: UIAction = .init(title: "per_\(Period.PerDay.rawValue)".localized.lowercased(),
                                     image: nil,
                                     identifier: nil,
                                     discoverabilityTitle: nil,
                                     attributes: .init(),
                                     state: period == .PerDay ? .on : .off,
                                     handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .PerDay
        })
        
        let perWeek: UIAction = .init(title: "per_\(Period.PerWeek.rawValue)".localized.lowercased(),
                                      image: nil,
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .init(),
                                      state: period == .PerWeek ? .on : .off,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .PerWeek
        })
        
        let perMonth: UIAction = .init(title: "per_\(Period.PerMonth.rawValue)".localized.lowercased(),
                                       image: nil,
                                       identifier: nil,
                                       discoverabilityTitle: nil,
                                       attributes: .init(),
                                       state: period == .PerMonth ? .on : .off,
                                       handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .PerMonth
        })
        
        let allTime: UIAction = .init(title: "per_\(Period.AllTime.rawValue)".localized.lowercased(),
                                      image: nil,
                                      identifier: nil,
                                      discoverabilityTitle: nil,
                                      attributes: .init(),
                                      state: period == .AllTime ? .on : .off,
                                      handler: { [weak self] _ in
            guard let self = self else { return }
            
            self.period = .AllTime
        })
        
        return UIMenu(title: "",//"publications_per".localized,
                      image: nil,
                      identifier: nil,
                      options: .init(),
                      children: [
                        perDay,
                        perWeek,
                        perMonth,
                        allTime
                      ])
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
    
    func onDefaultMode(color: UIColor? = nil) {
        surveysCollectionView.alpha = 1
        collectionView.backgroundColor = background.backgroundColor
        reveal(present: false, location: touchLocation, view: surveysCollectionView, color: color ?? surveysCollectionView.topic!.tagColor, fadeView: collectionView, duration: 0.3)
        setBackgroundColor(self.traitCollection.userInterfaceStyle == .dark ? .secondarySystemBackground : .white)
        toggleDateFilter(on: false)
    }
    
    func onSearchMode() {
        surveysCollectionView.category = .Search
        surveysCollectionView.alpha = 1
//        surveysCollectionView.layer.mask = nil
        surveysCollectionView.backgroundColor = background.backgroundColor
        touchLocation = CGPoint(x: bounds.maxX, y: bounds.minY)
        reveal(present: true, location: touchLocation, view: surveysCollectionView, color: .white, fadeView: collectionView, duration: 0.5)
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
