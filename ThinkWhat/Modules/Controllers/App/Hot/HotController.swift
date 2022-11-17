//
//  HotController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 10.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine



class HotController: UIViewController, TintColorable {

    
    
    // MARK: - Public properties
    var controllerOutput: HotControllerOutput?
    var controllerInput: HotControllerInput?
    var shouldSkipCurrentCard = false
    var tintColor: UIColor = .clear {
        didSet {
            setNavigationBarTintColor(tintColor)
        }
    }
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private var isOnScreen = true
    private var isViewLayedOut = false
//    private lazy var logo: AppLogoWithText = {
//        let instance = AppLogoWithText(color: Colors.Logo.Flame.main,
//                                       minusToneColor: Colors.Logo.Flame.minusTone)
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 6/1).isActive = true
//        instance.isOpaque = false
//
//        let constraint = instance.heightAnchor.constraint(equalToConstant: 0)
//        constraint.isActive = true
//
//        navigationController?.navigationBar.publisher(for: \.bounds)
//            .sink { rect in
//                constraint.constant = rect.height * 0.75
//            }
//            .store(in: &subscriptions)
//
//        return instance
//    }()
//    private lazy var gradient: CAGradientLayer = {
//        let instance = CAGradientLayer()
//        instance.type = .radial
//        instance.colors = getGradientColors()
//        instance.locations = [0, 0.5, 1.15]
//        instance.setIdentifier("radialGradient")
//        instance.startPoint = CGPoint(x: 0.5, y: 0.5)
//        instance.endPoint = CGPoint(x: 1, y: 1)
//        instance.publisher(for: \.bounds)
//            .sink { rect in
//                instance.cornerRadius = rect.height/2
//            }
//            .store(in: &subscriptions)
//
//        return instance
//    }()
//    private lazy var barButton: UIView = {
//        let instance = UIView()
//        instance.layer.masksToBounds = false
//        instance.clipsToBounds = false
//        instance.backgroundColor = .clear
//        instance.accessibilityIdentifier = "shadow"
//        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
//        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
//        instance.layer.shadowRadius = 7
//        instance.layer.shadowOffset = .zero
//        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
//        instance.layer.addSublayer(gradient)
//        instance.publisher(for: \.bounds, options: .new)
//            .sink { rect in
//                instance.layer.shadowPath = UIBezierPath(ovalIn: rect).cgPath
//
//                guard rect != .zero,
//                      let layer = instance.layer.getSublayer(identifier: "radialGradient"),
//                      layer.bounds != rect
//                else { return }
//
//                layer.frame = rect
//            }
//            .store(in: &subscriptions)
//
//        let button = UIButton()
//        button.publisher(for: \.bounds, options: .new)
//            .sink { [weak self] rect in
//                guard let self = self else { return }
//
//                button.cornerRadius = rect.height/2
//                let largeConfig = UIImage.SymbolConfiguration(pointSize: rect.height * 0.45, weight: .semibold, scale: .medium)
//                let image = UIImage(systemName: "plus", withConfiguration: largeConfig)
//                button.setImage(image, for: .normal)
//            }
//            .store(in: &subscriptions)
//
//        button.addTarget(self, action: #selector(self.addSurvey), for: .touchUpInside)
//        button.accessibilityIdentifier = "button"
//        button.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
////        button.imageView?.contentMode = .center
//        button.imageView?.tintColor = .white
//        button.addEquallyTo(to: instance)
//
//        return instance
//    }()
//    private lazy var titleStack: UIStackView = {
//        let horizontalStack = UIStackView(arrangedSubviews: [
//            titleLabel,
//            barButton
//        ])
//        horizontalStack.axis = .horizontal
//
//        let opaque = UIView()
//        opaque.backgroundColor = .clear
//
//        logo.placeInCenter(of: opaque,
//                           heightMultiplier: 0.75)
//
//        let instance = UIStackView(arrangedSubviews: [
//            opaque,
//            horizontalStack
//        ])
//        instance.axis = .vertical
//        instance.distribution = .fillEqually
//        instance.spacing = 8
//
//        return instance
//    }()
//    private lazy var titleLabel: UILabel = {
//       let instance = UILabel()
//        instance.font = UIFont(name: Fonts.Bold,
//                               size: 32)
//        instance.textAlignment = .left
//        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .label
//        instance.text = "hot".localized
//
//        return instance
//    }()
    private var isNetworking = false
    private var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = HotModel()
               
        self.controllerOutput = view as? HotView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        setTasks()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        titleStack.alpha = 1
        
        self.navigationController?.navigationBar.alpha = 1
        navigationItem.largeTitleDisplayMode = .never
        view.setNeedsLayout()
        view.layoutIfNeeded()
        controllerOutput?.onDidLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        controllerOutput?.onDidAppear()
        if shouldSkipCurrentCard {
            delayAsync(delay: 0.3) { [weak self] in
                guard let self = self else { return }
                
                self.controllerOutput?.skipCard()
                self.shouldSkipCurrentCard = false
            }
        }
        
        guard let navigationBar = navigationController?.navigationBar,
              let tabBarController = tabBarController as? MainController
        else { return }

        tabBarController.setLogoInitialFrame(size: navigationBar.bounds.size,
                                             y: abs(navigationBar.center.y))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0) { [weak self] in
            guard let self = self else { return }

            self.navigationController?.navigationBar.alpha = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopTimer()
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
//        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray)
////        barButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
////        gradient.colors = getGradientColors()
////        titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .label
//    }
    
    
    
    
//    private let barButton: UIImageView = {
//        let v = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
//        v.contentMode = .scaleAspectFill
//        v.isUserInteractionEnabled = true
//        return v
//    }()
    ///Indicates that request is in progress, so another one shouldn't be fired
    
}

private extension HotController {
    private func setupUI() {
        
        navigationItem.title = ""
//        navigationItem.titleView = logo
//        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray)
        navigationItem.setRightBarButton(UIBarButtonItem(title: nil,
                                                         image: UIImage(systemName: "megaphone.fill",
                                                                        withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                                         primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            self.navigationController?.pushViewController(SurveyCreationController(), animated: true)
            self.tabBarController?.setTabBarVisible(visible: false, animated: true)
        }),
                                                         menu: nil),
                                         animated: true)
//        titleStack.place(inside: navigationBar,
        //                         insets: UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10))
//        guard let navigationBar = navigationController?.navigationBar,
//              let tabBarController = tabBarController as? MainController
//        else { return }
//
////        guard let keyWindow = UIApplication.shared.connectedScenes
////            .filter({$0.activationState == .foregroundActive})
////            .compactMap({$0 as? UIWindowScene})
////            .first?.windows
////            .filter({$0.isKeyWindow}).first,
////              let instance = keyWindow.viewByClassName(className: "_UIBarBackground")
////        guard let window = appDelegate.window,
////              let instance = window.viewByClassName(className: "_UIBarBackground")
////        else {
////            tabBarController.setLogoInitialFrame(size: navigationBar.bounds.size,
////                                                 y: 59)
////
////            return
////        }
////
//        tabBarController.setLogoInitialFrame(size: navigationBar.bounds.size,
//                                             y: 59)//abs(navigationBar.convert(navigationBar.center, to: UIScreen.main as! UICoordinateSpace).y))
    }
    
//    @objc
//    private func addSurvey() {
////        if let nav = navigationController as? CustomNavigationController {
////            nav.transitionStyle = .Default
////            nav.duration = 0.5
//////            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
////        }
//        let backItem = UIBarButtonItem()
//            backItem.title = ""
//            navigationItem.backBarButtonItem = backItem
//        navigationController?.pushViewController(SurveyCreationController(), animated: true)
//        tabBarController?.setTabBarVisible(visible: false, animated: true)
//    }
    
    private func setTasks() {
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.System.Tab) {
                guard let self = self,
                      let tab = notification.object as? Tab
                else { return }
                
                self.isOnScreen = tab == .Hot
            }
        })
    }
    
    func getGradientColors() -> [CGColor] {
        return [
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.lighter(0.2).cgColor : K_COLOR_RED.lighter(0.2).cgColor,
        ]
    }
}

// MARK: - View Input
extension HotController: HotViewInput {
    func onReject(_ survey: Survey) {
        controllerInput?.reject(survey)
    }
    
    func onClaim(survey: Survey, reason: Claim) {
        controllerInput?.claim(survey: survey, reason: reason)
    }
    
    func onVote(survey: Survey) {
//        if let nav = navigationController as? CustomNavigationController {
//            nav.transitionStyle = .Default
//            nav.duration = 0.5
////            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
//        }
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(PollController(surveyReference: survey.reference, showNext: true), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onEmptyStack() {
        startTimer()
    }
}

// MARK: - Model Output
extension HotController: HotModelOutput {
    func onClaimCallback(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
#if DEBUG
            print("")
#endif
        case .failure(let error):
#if DEBUG
            print(error.localizedDescription)
#endif
        }
    }
    
    func onRequestCompleted() {
        isNetworking = false
    }
}

extension HotController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        controllerOutput?.populateStack()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HotController.populateStack),
                                               name: Notifications.Surveys.SwitchHot,
                                               object: nil)
    }
}

// MARK: - Observers
extension HotController {
    @objc
    private func populateStack() {
        controllerOutput?.populateStack()
        stopTimer()
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(HotController.requestSurveys), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc
    private func requestSurveys() {
        guard isOnScreen, !isNetworking else { return }
        
        isNetworking = true
        controllerInput?.loadSurveys()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

