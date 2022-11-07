//
//  UserprofileController.swift
//  ThinkWhat
//
//  Created by Pavel Bukharov on 22.09.2022.
//  Copyright © 2022 Pavel Bukharov. All rights reserved.
//

import UIKit
import Combine
import Agrume
import SafariServices

class UserprofileController: UIViewController {
    
    // MARK: - Overridden properties
    
    
    
    // MARK: - Public properties
    var controllerOutput: UserprofileControllerOutput?
    var controllerInput: UserprofileControllerInput?
    //Logic
    public private(set) var userprofile: Userprofile
    
    
    // MARK: - Private properties
    private var observers: [NSKeyValueObservation] = []
    private var subscriptions = Set<AnyCancellable>()
    private var tasks: [Task<Void, Never>?] = []
    //UI
    private var isRightButtonSpinning = false {
        didSet {
            let spinner = UIActivityIndicatorView()
            spinner.color = .label
            spinner.style = .medium
            spinner.startAnimating()
            navigationItem.setRightBarButton(isRightButtonSpinning ? UIBarButtonItem(customView: spinner) : nil,
                                             animated: true)
        }
    }
    
    
    
    // MARK: - Deinitialization
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
    init(userprofile: Userprofile) {
        self.userprofile = userprofile
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Public methods
    
    
    
    // MARK: - Overridden methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let view = UserprofileView()
        let model = UserprofileModel()
               
        self.controllerOutput = view
        self.controllerOutput?
            .viewInput = self
        self.controllerInput = model
        self.controllerInput?
            .modelOutput = self
        
        self.view = view as UIView
        
        setupUI()
        setTasks()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
}

private extension UserprofileController {
    
    @MainActor
    func setupUI() {
        setBarItems()
    }
    
    func setTasks() {
        //On notifications switch server callback
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NotifyOnPublications) {
                guard let self = self,
                      let userprofile = notification.object as? Userprofile,
                      self.userprofile == userprofile
                else { return }
                
                self.isRightButtonSpinning = false
                self.setBarItems()
            }
        })
        
        //On notifications switch server failure callback
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.NotifyOnPublicationsFailure) {
                guard let self = self,
                      let userprofile = notification.object as? Userprofile,
                      self.userprofile == userprofile
                else { return }
                
                self.isRightButtonSpinning = false
                self.setBarItems()
            }
        })
        
        //Subscriptions
        tasks.append(Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsAppend) {
                guard let self = self,
                      let dict = notification.object as? [Userprofile: Userprofile],
                      let userprofile = dict.values.first,
                      self.userprofile == userprofile
                else { return }
                
                self.setBarItems()
            }
        })
        tasks.append(Task { @MainActor [weak self] in
            for await notification in NotificationCenter.default.notifications(for: Notifications.Userprofiles.SubscriptionsRemove) {
                guard let self = self,
                      let dict = notification.object as? [Userprofile: Userprofile],
                      let userprofile = dict.values.first,
                      self.userprofile == userprofile
                else { return }
                
                self.setBarItems()
            }
        })
    }
    
    @MainActor
    func setBarItems() {
        guard !isRightButtonSpinning else { return }
        
        guard userprofile.subscribedAt else {
            navigationItem.setRightBarButton(UIBarButtonItem(title: nil), animated: true)
            return
        }
        
        let notify = userprofile.notifyOnPublication ?? false
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            
            self.isRightButtonSpinning = true
            self.controllerInput?.switchNotifications(userprofile: self.userprofile,
                                                      notify: !notify)
        }
        
        navigationItem.setRightBarButton(UIBarButtonItem(title: nil,
                                                         image: UIImage(systemName: notify ? "bell.fill" : "bell.slash.fill",
                                                                        withConfiguration: UIImage.SymbolConfiguration(weight: .regular)),
                                                         primaryAction: action,
                                                         menu: nil),
                                         animated: true)
    }
}

extension UserprofileController: UserprofileViewInput {
    func onTopicSelected(_ topic: Topic) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(SurveysController(topic), animated: true)
        tabBarController?.setTabBarVisible(visible: false, animated: true)
    }
    
    func unsubscribe() {
        controllerInput?.unsubscribe(from: userprofile)
    }
    
    func subscribe() {
        controllerInput?.subscribe(to: userprofile)
    }
    
    func openImage(_ image: UIImage) {
        let agrume = Agrume(images: [image], startIndex: 0, background: .colored(.black))
        agrume.show(from: self)
    }
    
    func openURL(_ url: URL) {
        var vc: SFSafariViewController!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
}

extension UserprofileController: UserprofileModelOutput {
    // Implement methods
}
