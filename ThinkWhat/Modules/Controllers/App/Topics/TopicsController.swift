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
        case Parent, Child, List, Search
    }

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

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        controllerOutput?.onDidLayout()
//    }
    
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
        barButton.layer.cornerRadius = UINavigationController.Constants.ImageSizeForLargeState / 2
        barButton.clipsToBounds = true
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        barButton.translatesAutoresizingMaskIntoConstraints = false
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(TopicsController.handleTap))
        barButton.addGestureRecognizer(gesture)
        NSLayoutConstraint.activate([
            barButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            barButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            barButton.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            barButton.widthAnchor.constraint(equalTo: barButton.heightAnchor)
        ])
        navigationBar.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.rightAnchor.constraint(equalTo: barButton.leftAnchor, constant: -UINavigationController.Constants.ImageRightMargin),
            searchField.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: deviceType == .iPhoneSE ? 0 : -UINavigationController.Constants.ImageBottomMarginForLargeState/2),
            searchField.heightAnchor.constraint(equalToConstant: UINavigationController.Constants.ImageSizeForLargeState),
            searchField.leftAnchor.constraint(equalTo: navigationBar.leftAnchor, constant: UINavigationController.Constants.ImageRightMargin),
        ])
    }
    
    
    @objc private func handleTap() {
        if mode == .Child {
            mode = .Parent
        } else if mode == .List {
            mode = .Child
        } else if mode == .Parent {
            mode = .Search
        } else if mode == .Search {
            mode = .Parent
        } else {
            mode = .List
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        barButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .systemBlue : K_COLOR_RED
        searchField.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
        searchField.activeLineColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
        searchField.line.layer.strokeColor = UIColor.systemGray.cgColor
        searchField.color = traitCollection.userInterfaceStyle == .dark ? UIColor.systemYellow : K_COLOR_RED
    }

    // MARK: - Properties
    var controllerOutput: TopicsControllerOutput?
    var controllerInput: TopicsControllerInput?
    var mode: Mode = .Parent {
        didSet {
//            guard oldValue != mode else { return }
//            switch mode {
//            case .Parent:
//                navigationItem.title = "topics".localized
//                if oldValue == .Search {
//                    controllerOutput?.onSearchToParentMode()
//                    searchField.resignFirstResponder()
//                    UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
//                        self.searchField.alpha = 0
//                        self.barButton.image = ImageSigns.magnifyingGlassFilled.image
//                    } completion: { _ in }
//                } else {
//                    onParentMode()
//                    controllerOutput?.onParentMode()
//                }
//            case .Child:
//                navigationItem.title = "topics".localized
//                if oldValue == .List {
//                    controllerOutput?.onListToChildMode()
//                } else {
//                    onChildMode()
//                    controllerOutput?.onChildMode()
//                }
//            case .List:
//                if let topic = controllerOutput?.topic {
//                    navigationItem.title = topic.title
//                } else {
//                    navigationItem.title = "topics".localized
//                }
//                controllerOutput?.onListMode()
//            case .Search:
//                controllerOutput?.onSearchMode()
//                let touch = UITapGestureRecognizer(target:self, action:#selector(TopicsController.hideKeyboard))
//                view.addGestureRecognizer(touch)
//                setupTextField(textField: searchField)
//                searchField.text = ""
//                searchField.becomeFirstResponder()
//                navigationItem.title = ""
//                UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
//                    self.searchField.alpha = 1
//                    self.barButton.image = ImageSigns.arrowLeft.image
//                } completion: { _ in }
//            }
        }
    }
    
    private let barButton: UIImageView = {
        let v = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 32, height: 32)))
        v.contentMode = .scaleAspectFill
        v.image = ImageSigns.magnifyingGlassFilled.image
        v.isUserInteractionEnabled = true
        return v
    }()
    private let searchField: UnderlinedSignTextField = {
        let v = UnderlinedSignTextField()
        v.placeholder = "search".localized
        v.alpha = 0
        return v
    }()
    private var textFieldIsSetup = false
    private var isSearching = false {
        didSet {
            searchField.isShowingSpinner = isSearching
        }
    }
}

// MARK: - View Input
extension TopicsController: TopicsViewInput {
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
        UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.barButton.image = ImageSigns.arrowLeft.image
        } completion: { _ in }
    }
    
    private func onParentMode() {
        UIView.transition(with: barButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.barButton.image = ImageSigns.magnifyingGlassFilled.image
        } completion: { _ in }
    }
}

// MARK: - Model Output
extension TopicsController: TopicsModelOutput {
    func onSearchCompleted(_ instances: [SurveyReference]) {
        controllerOutput?.onSearchCompleted(instances)
        isSearching = false
    }
    
//    func onError(_: Error) {
//        func onError(_ error: Error) {
//            isSearching = false
//    #if DEBUG
//            print(error.localizedDescription)
//    #endif
//            controllerOutput?.onError()
//        }
//    }
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
        guard let textField = textField as? UnderlinedSignTextField else { return }
        if textField.text!.count > 3 {
            isSearching = true
            controllerInput?.search(substring: searchField.text!, excludedIds: [])
        } else {
            isSearching = false
        }
    }
    
    @objc private func hideKeyboard() {
        if let recognizer = view.gestureRecognizers?.first {
            view.removeGestureRecognizer(recognizer)
        }
        if mode == .Search {
            searchField.resignFirstResponder()
        }
    }
    
    private func setupTextField(textField: UnderlinedSignTextField) {
        guard !textFieldIsSetup else { return }
        textFieldIsSetup = true
        textField.delegate = self
        textField.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
        textField.activeLineColor = traitCollection.userInterfaceStyle == .dark ? UIColor.systemBlue : K_COLOR_RED
        textField.line.layer.strokeColor = UIColor.systemGray.cgColor
        textField.color = traitCollection.userInterfaceStyle == .dark ? .white : K_COLOR_RED
        textField.addTarget(self, action: #selector(TopicsController.textFieldDidChange(_:)), for: .editingChanged)
    }
}
