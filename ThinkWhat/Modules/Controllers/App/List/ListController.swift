//
//  ListController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 11.03.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine

class ListController: UIViewController, TintColorable {
    
    // MARK: - Public properties
    var controllerOutput: ListControllerOutput?
    var controllerInput: ListControllerInput?
//    var surveyCategory: Survey.SurveyCategory {
//        return category
//    }
    public private(set) var category: Survey.SurveyCategory = .New {
        didSet {
            controllerOutput?.onDataSourceChanged()
//            setTitle()
        }
    }
    public var tintColor: UIColor = .clear {
        didSet {
//            setNavigationBarTintColor(tintColor)
            listSwitch.color = tintColor
        }
    }
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private var isOnScreen = true
    private lazy var titleStack: UIStackView = {
        let opaque = UIView()
        opaque.backgroundColor = .clear
        
        let instance = UIStackView(arrangedSubviews: [
            opaque,
            listSwitch
        ])
        instance.axis = .horizontal
        instance.spacing = 0

        return instance
    }()
    private lazy var listSwitch: ListSwitch = {
        let instance = ListSwitch()
        instance.widthAnchor.constraint(equalTo: instance.heightAnchor, multiplier: 4).isActive = true
        instance.statePublisher
            .sink { [weak self] in
                guard let self = self,
                      let state = $0
                else { return }
                
                switch state {
                case .New:
                    self.category = .New
                case .Top:
                    self.category = .Top
                case .Watching:
                    self.category = .Favorite
                case .Own:
                    self.category = .Own
                }
            }
            .store(in: &subscriptions)
        
        return instance
    }()
//    private lazy var titleLabel: UILabel = {
//       let instance = UILabel()
//        instance.font = UIFont(name: Fonts.Bold,
//                               size: 32)
//        instance.textAlignment = .left
//        instance.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .label
//
//        return instance
//    }()
    

    
    // MARK: - Overridden methods
    override func viewDidLoad() {
        super.viewDidLoad()

        let model = ListModel()
               
        self.controllerOutput = view as? ListView
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        ProtocolSubscriptions.subscribe(self)
        setupUI()
        setTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false//true
        navigationItem.largeTitleDisplayMode = .never//.always
        
        setNavigationBarTintColor(tintColor)
        titleStack.alpha = 1
        tabBarController?.setTabBarVisible(visible: true, animated: true)
        
        guard let main = tabBarController as? MainController else { return }
        
        main.toggleLogo(on: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIView.animate(withDuration: 0.1) {
            self.titleStack.alpha = 0
        }
    }
//
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
//        titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .secondaryLabel : .label
//    }
}



// MARK: - View Input
extension ListController: ListViewInput {
    func openSettings() {
        tabBarController?.selectedIndex = 4
    }
    
    func unsubscribe(from userprofile: Userprofile) {
        controllerInput?.unsubscribe(from: userprofile)
    }
    
    func subscribe(to userprofile: Userprofile) {
        controllerInput?.subscribe(to: userprofile)
    }
    
    func openUserprofile(_ userprofile: Userprofile) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(UserprofileController(userprofile: userprofile), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func share(_ surveyReference: SurveyReference) {
        // Setting description
        let firstActivityItem = surveyReference.title
        
        // Setting url
        let queryItems = [URLQueryItem(name: "hash", value: surveyReference.shareHash), URLQueryItem(name: "enc", value: surveyReference.shareEncryptedString)]
        var urlComps = URLComponents(string: API_URLS.Surveys.share!.absoluteString)!
        urlComps.queryItems = queryItems
        
        let secondActivityItem: URL = urlComps.url!
        
        // If you want to use an image
        let image : UIImage = UIImage(named: "anon")!
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = false
        self.present(activityViewController,
                     animated: true,
                     completion: nil)
    }
    
    func claim(surveyReference: SurveyReference, claim: Claim) {
        controllerInput?.claim(surveyReference: surveyReference, claim: claim)
    }
    
    func addFavorite(_ surveyReference: SurveyReference) {
        controllerInput?.addFavorite(surveyReference: surveyReference)
    }
    
    func updateSurveyStats(_ instances: [SurveyReference]) {
        guard isOnScreen else { return }
        
        controllerInput?.updateSurveyStats(instances)
    }
    
    func onSurveyTapped(_ instance: SurveyReference) {
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(PollController(surveyReference: instance, showNext: false), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
        
        guard let main = tabBarController as? MainController else { return }
        
        main.toggleLogo(on: false)
    }
    
    func onDataSourceRequest(source: Survey.SurveyCategory, topic: Topic?) {
        guard isOnScreen else { return }
        
        controllerInput?.onDataSourceRequest(source: source, topic: topic)
    }
}

private extension ListController {
    func setTasks() {
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.System.Tab) {
                guard let self = self,
                      let tab = notification.object as? Tab
                else { return }
                
                self.isOnScreen = tab == .Feed
            }
        })
    }
    
    @MainActor
    func setupUI() {
        navigationItem.title = ""
        navigationController?.navigationBar.prefersLargeTitles = false//deviceType == .iPhoneSE ? false : true
        
        guard let navigationBar = self.navigationController?.navigationBar else { return }

        navigationBar.addSubview(titleStack)
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStack.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            titleStack.heightAnchor.constraint(equalToConstant: 40),
            titleStack.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 10),
            titleStack.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -10)
        ])
//
//        //-10 is card padding
//        setTitle(animated: false)
//
//        //        titleStack.place(inside: navigationBar,
//        //        insets: UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10))
    }
    
//    @MainActor
//    func setTitle(animated: Bool = true) {
//        var text = ""
//
//        switch category {
//        case .New:
//            text =  "new".localized
//        case .Top:
//            text = "top".localized
//        case .Favorite:
//            text = "watching".localized
//        case .Own:
//            text = "own".localized
//        default:
//#if DEBUG
//            print("")
//#endif
//        }
//
//        guard animated else {
//            titleLabel.text = text
//            return
//        }
//
//
//        UIView.transition(with: titleLabel,
//                          duration: 0.15,
//                          options: .transitionCrossDissolve) { [weak self] in
//            guard let self = self else { return }
//
//            self.titleLabel.text = text
//        }
//
//    }
}

extension ListController: ListModelOutput {
//    func onAddFavoriteCallback(_ result: Result<Bool, Error>) {
//        controllerOutput?.onAddFavoriteCallback(result)
//    }
    
    func onRequestCompleted(_ result: Result<Bool, Error>) {
        controllerOutput?.onRequestCompleted(result)
//        switch result {
//
//        case .success:
//            controllerOutput?.onRequestCompleted(result)
//        case .failure(let error):
//#if DEBUG
//            error.printLocalized(class: type(of: self), functionName: #function)
//#endif
//        }
    }
}

extension ListController: DataObservable {
    func onDataLoaded() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
