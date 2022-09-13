//
//  TopicsController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit

class TopicsController: UIViewController {
    
    enum Mode {
        case Search, Default, Topic//Parent, Child, List, Search
    }

    // MARK: - Properties
    var controllerOutput: TopicsControllerOutput?
    var controllerInput: TopicsControllerInput?
    var mode: Mode = .Default {
        didSet {
            guard oldValue != mode else { return }
            guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
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
                navigationItem.title = topic.title
            default:
                if let recognizer = view.gestureRecognizers?.first {
                    view.removeGestureRecognizer(recognizer)
                }
                navigationItem.title = "topics".localized
                searchField.text = ""
                searchField.resignFirstResponder()
                controllerOutput?.onDefaultMode()
                imageName = "magnifyingglass"
            }
            UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
                let largeConfig = UIImage.SymbolConfiguration(pointSize: button.bounds.height * 0.55, weight: .semibold, scale: .medium)
                let image = UIImage(systemName: imageName, withConfiguration: largeConfig)
                self.searchField.alpha = self.mode == .Search ? 1 : 0
                button.setImage(image, for: .normal)
            } completion: { _ in }
        }
    }
            
    private var topic: Topic? {
        didSet {
            guard !topic.isNil else { return }
            mode = .Topic
        }
    }
    private var observers: [NSKeyValueObservation] = []
    private lazy var barButton: UIView = {
        let instance = UIView()
        instance.layer.masksToBounds = false
        instance.clipsToBounds = false
        instance.backgroundColor = .clear
        instance.accessibilityIdentifier = "shadow"
        instance.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        instance.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        instance.layer.shadowRadius = 7
        instance.layer.shadowOffset = .zero
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 1/1).isActive = true
        observers.append(instance.observe(\UIView.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            view.layer.shadowPath = UIBezierPath(ovalIn: newValue).cgPath
        })
        
        let button = UIButton()
        observers.append(button.observe(\UIButton.bounds, options: .new) { [weak self] view, change in
            guard let self = self,
                  let newValue = change.newValue
            else { return }
            
            var imageName = ""
            switch self.mode {
            case .Search:
                imageName = "arrow.backward"
            default:
                imageName = "magnifyingglass"
            }
            
            view.cornerRadius = newValue.size.height/2
            let largeConfig = UIImage.SymbolConfiguration(pointSize: newValue.size.height * 0.55, weight: .semibold, scale: .medium)
            let image = UIImage(systemName: imageName, withConfiguration: largeConfig)
            view.setImage(image, for: .normal)
        })
        button.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
        button.accessibilityIdentifier = "button"
        button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
//        button.imageView?.contentMode = .center
        button.imageView?.tintColor = .white
        button.addEquallyTo(to: instance)

        return instance
    }()
    private lazy var searchField: InsetTextField = {
        let instance = InsetTextField()
        instance.placeholder = "search".localized
        instance.alpha = 0
        instance.delegate = self
        instance.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        instance.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
        instance.addTarget(self, action: #selector(TopicsController.textFieldDidChange(_:)), for: .editingChanged)
        instance.returnKeyType = .done
        observers.append(instance.observe(\InsetTextField.bounds, options: .new) { view, change in
            guard let newValue = change.newValue else { return }
            
            view.cornerRadius = newValue.size.height/2.25
            guard view.insets == .zero else { return }
            view.insets = UIEdgeInsets(top: view.insets.top,
                                       left: newValue.size.height/2.25,
                                       bottom: view.insets.top,
                                       right: newValue.size.height/2.25)
        })
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
        
        title = "topics".localized
        ProtocolSubscriptions.subscribe(self)
        setObservers()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barButton.alpha = 1
        tabBarController?.setTabBarVisible(visible: true, animated: true)
//        controllerOutput?.onWillAppear()
        if mode == .Search {
            searchField.alpha = 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barButton.alpha = 0
        if mode == .Search {
            searchField.alpha = 0
            searchField.resignFirstResponder()
        }
    }

    private func setObservers() {
//        let names = [Notifications.System.UpdateStats]
//        names.forEach { NotificationCenter.default.addObserver(view, selector: #selector(TopicsView.updateStats), name: $0, object: nil) }
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = deviceType == .iPhoneSE ? false : true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(barButton)
        navigationBar.addSubview(searchField)
        barButton.translatesAutoresizingMaskIntoConstraints = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchField.rightAnchor.constraint(equalTo: barButton.leftAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            searchField.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            searchField.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            searchField.leftAnchor.constraint(equalTo: navigationBar.leftAnchor, constant: UINavigationController.Constants.ImageRightMargin),
            barButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            barButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            barButton.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            barButton.widthAnchor.constraint(equalTo: barButton.heightAnchor)
        ])
    }
    
    
    @objc private func handleTap() {
        switch mode {
        case .Topic:
            mode = .Default
        case .Search:
            mode = .Default
        case .Default:
            mode = .Search
        }
        
        
//        guard mode == .Search else {
//            mode = .Search
//            return
//        }
//        mode = .Default
//        if mode == .Child {
//            mode = .Parent
//        } else if mode == .List {
//            mode = .Child
//        } else if mode == .Parent {
//            mode = .Search
//        } else if mode == .Search {
//            mode = .Parent
//        } else {
//            mode = .List
//        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        searchField.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
        searchField.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .tertiarySystemBackground : .secondarySystemBackground
        barButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0 : 1
        guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
        button.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
    }
}

// MARK: - View Input
extension TopicsController: TopicsViewInput {
    func onDataSourceRequest() {
        guard let topic = topic else { return }
        controllerInput?.onDataSourceRequest(topic)
    }
    
    func onTopicSelected(_ instance: Topic) {
        topic = instance
    }
    
    func onSurveyTapped(_ instance: SurveyReference) {
        if let nav = navigationController as? CustomNavigationController {
            nav.transitionStyle = .Default
            nav.duration = 0.5
//            nav.isShadowed = traitCollection.userInterfaceStyle == .light ? true : false
        }
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
        guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
        UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: self.barButton.bounds.height * 0.55, weight: .semibold, scale: .medium)
            let image = UIImage(systemName: "arrow.backward", withConfiguration: largeConfig)
            button.setImage(image, for: .normal)
        } completion: { _ in }
    }
    
    private func onParentMode() {
        guard let button = barButton.getSubview(type: UIButton.self, identifier: "button") else { return }
        UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: self.barButton.bounds.height * 0.55, weight: .semibold, scale: .medium)
            let image = UIImage(systemName: "magnifyingglass", withConfiguration: largeConfig)
            button.setImage(image, for: .normal)
        } completion: { _ in }
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
