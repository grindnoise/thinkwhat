//
//  TopicsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class TopicsController: UIViewController, TintColorable {
    
    enum Mode {
        case Search, Default, Topic//Parent, Child, List, Search
    }

    // MARK: - Public properties
    var controllerOutput: TopicsControllerOutput?
    var controllerInput: TopicsControllerInput?
    var mode: Mode = .Default {
        didSet {
            guard oldValue != mode else { return }
//            guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
            var imageName = ""
            switch mode {
            case .Search:
                navigationItem.title = ""
                let touch = UITapGestureRecognizer(target:self, action:#selector(TopicsController.hideKeyboard))
                view.addGestureRecognizer(touch)
                searchField.text = ""
                searchField.becomeFirstResponder()
                controllerOutput?.onSearchMode()
                //Clear previous fetch request
                controllerOutput?.onSearchCompleted([])
                imageName = "arrow.backward"
            case .Topic:
                guard let topic = topic else { return }
//                controllerOutput?.onTopicMode(topic)
                imageName = "arrow.backward"
//                navigationItem.title = topic.localized
            default:
                if let recognizer = view.gestureRecognizers?.first {
                    view.removeGestureRecognizer(recognizer)
                }
//                navigationItem.title = "topics".localized
                searchField.text = ""
                searchField.resignFirstResponder()
                controllerOutput?.onDefaultMode()
                imageName = "magnifyingglass"
            }
//            UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
//                let largeConfig = UIImage.SymbolConfiguration(pointSize: button.bounds.height * 0.55, weight: .semibold, scale: .medium)
//                let image = UIImage(systemName: imageName, withConfiguration: largeConfig)
//                self.searchField.alpha = self.mode == .Search ? 1 : 0
//                button.setImage(image, for: .normal)
//            } completion: { _ in }
        }
    }
    public var tintColor: UIColor = .clear {
        didSet {
            setNavigationBarTintColor(tintColor)
        }
    }
    
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //Logic
    private var topic: Topic? {
        didSet {
            guard !topic.isNil else { return }
            mode = .Topic
        }
    }
    //UI
    private lazy var gradient: CAGradientLayer = {
        let instance = CAGradientLayer()
        instance.type = .radial
        instance.colors = getGradientColors()
        instance.locations = [0, 0.5, 1.15]
        instance.setIdentifier("radialGradient")
        instance.startPoint = CGPoint(x: 0.5, y: 0.5)
        instance.endPoint = CGPoint(x: 1, y: 1)
        instance.publisher(for: \.bounds)
            .sink { rect in
                instance.cornerRadius = rect.height/2
            }
            .store(in: &subscriptions)
        
        return instance
    }()
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
//                var imageName = ""
//                switch self.mode {
//                case .Search:
//                    imageName = "arrow.backward"
//                default:
//                    imageName = "magnifyingglass"
//                }
//
//                button.cornerRadius = rect.height/2
//                let largeConfig = UIImage.SymbolConfiguration(pointSize: rect.height * 0.45, weight: .semibold, scale: .medium)
//                let image = UIImage(systemName: imageName, withConfiguration: largeConfig)
//                button.setImage(image, for: .normal)
//            }
//            .store(in: &subscriptions)
//
//        button.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
//        button.accessibilityIdentifier = "button"
//        button.backgroundColor = .clear//traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
////        button.imageView?.contentMode = .center
//        button.imageView?.tintColor = .white
//        button.addEquallyTo(to: instance)
//
//        return instance
//    }()
    private lazy var searchField: InsetTextField = {
        let instance = InsetTextField()
        instance.placeholder = "search".localized
        instance.alpha = 0
        instance.delegate = self
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
        instance.addTarget(self, action: #selector(TopicsController.textFieldDidChange(_:)), for: .editingChanged)
        instance.returnKeyType = .done
        instance.publisher(for: \.bounds, options: .new)
            .sink { rect in
                instance.cornerRadius = rect.height/2.25
                
                guard instance.insets == .zero else { return }
                
                instance.insets = UIEdgeInsets(top: instance.insets.top,
                                               left: rect.height/2.25,
                                               bottom: instance.insets.top,
                                               right: rect.height/2.25)
            }
            .store(in: &subscriptions)
        
        return instance
    }()
    private var textFieldIsSetup = false
    private var isSearching = false //{
//        didSet {
//            searchField.isShowingSpinner = isSearching
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = TopicsModel()
               
        self.controllerOutput = view as? TopicsView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
//        title = "topics".localized
        ProtocolSubscriptions.subscribe(self)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        barButton.alpha = 1
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        self.navigationController?.navigationBar.alpha = 1
        navigationController?.navigationBar.prefersLargeTitles = false//true
        navigationItem.largeTitleDisplayMode = .never//.always
//        controllerOutput?.onWillAppear()
        if mode == .Search {
            searchField.alpha = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        barButton.alpha = 0
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) { [weak self] in
            guard let self = self else { return }

            self.navigationController?.navigationBar.alpha = 0
        }
        if mode == .Search {
            searchField.alpha = 0
            searchField.resignFirstResponder()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
//        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        searchField.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
        searchField.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
//        barButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        gradient.colors = getGradientColors()
//        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray)
    }
}

private extension TopicsController {
    func setupUI() {
        navigationItem.title = ""
//        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
//        navigationBar.addSubview(barButton)
        navigationBar.addSubview(searchField)
//        barButton.translatesAutoresizingMaskIntoConstraints = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                searchField.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
                searchField.heightAnchor.constraint(equalToConstant: 40),
                searchField.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 10),
                searchField.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -10)
        ])
        setBarItems()
//        setNavigationBarTintColor(traitCollection.userInterfaceStyle == .dark ? .systemBlue : .darkGray)
    }
    
    @objc
    func handleTap() {
        switch mode {
        case .Topic:
            mode = .Default
        case .Search:
            mode = .Default
        case .Default:
            mode = .Search
        }
    }
    
    func getGradientColors() -> [CGColor] {
        return [
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.cgColor : K_COLOR_RED.cgColor,
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue.lighter(0.2).cgColor : K_COLOR_RED.lighter(0.2).cgColor,
        ]
    }
    
    @MainActor
    func setBarItems(zeroSubscriptions: Bool = false) {
        var rightButton: UIBarButtonItem!

        switch mode {
        case .Default:
            rightButton = UIBarButtonItem(title: nil,
                                          image: UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                          primaryAction: nil,
                                          menu: nil)
            navigationItem.setRightBarButton(rightButton, animated: true)
            navigationItem.setLeftBarButton(nil, animated: true)
            
            //            guard let leading = titleLabel.getConstraint(identifier: "leading") else { return }
            //
            //            let _ = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.15,
            //                                                                   delay: 0) { [weak self] in
            //                guard let self = self,
            //                      let navigationBar = self.navigationController?.navigationBar
            //                else { return }
            //
            //                navigationBar.setNeedsLayout()
            //                leading.constant = 10
            //                navigationBar.layoutIfNeeded()
            //            }
        case .Search:
            rightButton = UIBarButtonItem(title: nil,
                                          image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                          primaryAction: nil,
                                          menu: nil)
            navigationItem.setRightBarButton(rightButton, animated: true)
            navigationItem.setLeftBarButton(nil, animated: true)
        default:
            rightButton = UIBarButtonItem(title: nil,
                                          image: UIImage(systemName: "arrow.counterclockwise", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                                          primaryAction: nil,
                                          menu: nil)
            navigationItem.setRightBarButton(rightButton, animated: true)
            navigationItem.setLeftBarButton(nil, animated: true)
        }
    }
}

extension TopicsController: TopicsViewInput {
    func onDataSourceRequest() {
        guard let topic = topic else { return }
        controllerInput?.onDataSourceRequest(topic)
    }
    
    func onTopicSelected(_ instance: Topic) {
        topic = instance
    }
    
    func onSurveyTapped(_ instance: SurveyReference) {
//        if let nav = navigationController as? CustomNavigationController {
//            nav.transitionStyle = .Default
//            nav.duration = 0.5
////            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
//        }
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(PollController(surveyReference: instance, showNext: false), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func onDataSourceRequest(_ topic: Topic) {
        controllerInput?.onDataSourceRequest(topic)
    }
    
    private func onChildMode() {
        setBarItems()
//        guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
//        UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
//            let largeConfig = UIImage.SymbolConfiguration(pointSize: self.barButton.bounds.height * 0.55, weight: .semibold, scale: .medium)
//            let image = UIImage(systemName: "arrow.backward", withConfiguration: largeConfig)
//            button.setImage(image, for: .normal)
//        } completion: { _ in }
    }
    
    private func onParentMode() {
        setBarItems()
//        guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
//        UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
//            let largeConfig = UIImage.SymbolConfiguration(pointSize: self.barButton.bounds.height * 0.55, weight: .semibold, scale: .medium)
//            let image = UIImage(systemName: "magnifyingglass", withConfiguration: largeConfig)
//            button.setImage(image, for: .normal)
//        } completion: { _ in }
    }
}

// MARK: - Model Output
extension TopicsController: TopicsModelOutput {
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        switch result {
        case .success:
            controllerOutput?.onRequestCompleted(result)
        case .failure(let error):
#if DEBUG
            error.printLocalized(class: type(of: self), functionName: #function)
#endif
        }
    }
    
    func onSearchCompleted(_ instances: [SurveyReference]) {
        controllerOutput?.onSearchCompleted(instances)
        isSearching = false
    }
}

extension TopicsController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension TopicsController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let recognizers = view.gestureRecognizers, recognizers.isEmpty {
            let touch = UITapGestureRecognizer(target:self, action:#selector(TopicsController.hideKeyboard))
            view.addGestureRecognizer(touch)
        }
        return !isSearching
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        guard !isSearching, let text = textField.text, text.count > 3 else {
            isSearching = false
            return
        }
        controllerOutput?.beginSearchRefreshing()
        isSearching = true
        controllerInput?.search(substring: text, excludedIds: [])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let recognizer = view.gestureRecognizers?.first {
            view.removeGestureRecognizer(recognizer)
        }
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func hideKeyboard() {
        if let recognizer = view.gestureRecognizers?.first {
            view.removeGestureRecognizer(recognizer)
        }
        if mode == .Search {
            searchField.resignFirstResponder()
        }
    }
    
//    private func setupTextField(textField: UnderlinedSignTextField) {
//        guard !textFieldIsSetup else { return }
//        textFieldIsSetup = true
//        textField.delegate = self
//        textField.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
//        textField.activeLineColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
//        textField.line.layer.strokeColor = UIColor.systemGray.cgColor
//        textField.color = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
//        textField.addTarget(self, action: #selector(TopicsController.textFieldDidChange(_:)), for: .editingChanged)
//    }
}
